/*
 * Cocoa Native Server - a JNI server for Bluetooth interfacing for the Remote Numpad Server
 * Copyright (C) 2016-2021 Guillaume Payet
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#import "CocoaNativeServer.h"

#import <stdlib.h>
#import <stdio.h>


@implementation CocoaNativeServer


static const char *serviceDictionaryFile = nil;

+ (const char *)serviceDictionary {
    @synchronized(self) {
        return serviceDictionaryFile;
    }
}

+ (void)setServiceDictionary:(const char *)serviceDictionary {
    @synchronized(self) {
        serviceDictionaryFile = serviceDictionary;
    }
}


- (instancetype)initWithEnv:(JNIEnv *)env obj:(jobject)obj {
    printf("initWithEnv:obj:\n");
    fflush(stdout);
    
    self = [super init];
    
    if (self == nil) {
        @throw [NSException exceptionWithName:@"InitException"
                                       reason:@"Could not initialize native server."
                                     userInfo:nil];
    }
    
    self->env = env;
    self->thisObj = obj;
    
    lock = dispatch_semaphore_create(0);

    jclass thisClass = (*env)->GetObjectClass(env, thisObj);
    
    connectionStatusChanged = (*env)->GetMethodID(env,
                                                  thisClass,
                                                  "connectionStatusChanged",
                                                  "(Ljava/lang/String;)V");
    
    stringReceived = (*env)->GetMethodID(env,
                                         thisClass,
                                         "stringReceived",
                                         "(Ljava/lang/String;)V");
    
    return self;
}

- (void)openWithUuid:(jstring)uuidJStr {
    printf("openWithUuid:\n");
    fflush(stdout);
    
    NSString *file = [NSString stringWithUTF8String:serviceDictionaryFile];
    NSURL *url = [NSURL fileURLWithPath:file];
    NSError *error;
    NSDictionary *properties = [NSDictionary dictionaryWithContentsOfURL:url error:&error];
    
    if (properties == nil) {
        @throw error;
    }
    
    const char *uuidCStr = (*env)->GetStringUTFChars(env, uuidJStr, nil);
    NSString *uuidStr = [NSString stringWithUTF8String:uuidCStr];
    NSUUID *uuid = [[NSUUID UUID] initWithUUIDString:uuidStr];
    uuid_t uuidBytes;
    [uuid getUUIDBytes:uuidBytes];
    NSData *data = [NSData dataWithBytes:uuidBytes length:16];

    properties[@"0001 - ServiceClassIDList"][0] = data;
    properties[@"0009 - BluetoothProfileDescriptorList"][0][0] = data;
    serviceRecord = [IOBluetoothSDPServiceRecord publishedServiceRecordWithDictionary:properties];

    if (serviceRecord == nil) {
        @throw [NSException exceptionWithName:@"SDPException"
                                       reason:@"Could not register SDP service"
                                     userInfo:nil];
    }

    BluetoothRFCOMMChannelID channelID;
    [serviceRecord getRFCOMMChannelID:&channelID];

    SEL selector = @selector(channelOpenedNotification:channel:);
    IOBluetoothUserNotificationChannelDirection direction = kIOBluetoothUserNotificationChannelDirectionIncoming;
    [self changeConnectionStatus:"SERVER_READY"];

    while (serviceRecord != nil) {
        notifIn = [IOBluetoothRFCOMMChannel registerForChannelOpenNotifications:self
                                                                       selector:selector
                                                                  withChannelID:channelID
                                                                      direction:direction];

        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);

        if (notifOut != nil) {
            [self changeConnectionStatus:"CLIENT_CONNECTED"];
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            [self changeConnectionStatus:"CLIENT_DISCONNECTED"];
        }
    }
}

- (void)close {
    printf("close\n");
    fflush(stdout);
    
    if (notifOut != nil) {
        [notifOut unregister];
        notifOut = nil;
    }

    if (notifIn != nil) {
        [notifIn unregister];
        notifIn = nil;
    }

    if (serviceRecord != nil) {
        [serviceRecord removeServiceRecord];
        serviceRecord = nil;
    }

    dispatch_semaphore_signal(lock);
}

- (void)channelOpenedNotification:(IOBluetoothUserNotification *)notification
                          channel:(IOBluetoothRFCOMMChannel *)channel {
    printf("channelOpenedNotification:channel:\n");
    fflush(stdout);
    
    if ([notification isEqual:notifIn])
        notifIn = nil;

    [notification unregister];
    [channel setDelegate:self];
    SEL selector = @selector(channelClosedNotification:channel:);

    notifOut = [channel registerForChannelCloseNotification:self
                                                   selector:selector];

    dispatch_semaphore_signal(lock);
}

- (void)channelClosedNotification:(IOBluetoothUserNotification *)notification
                          channel:(IOBluetoothRFCOMMChannel *)channel {
    printf("channelClosedNotification:channel:\n");
    fflush(stdout);
    
    if ([notification isEqual:notifOut])
        notifOut = nil;

    [notification unregister];
    [channel setDelegate:nil];
    [channel closeChannel];

    dispatch_semaphore_signal(lock);
}


- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel *)rfcommChannel
                     data:(void *)dataPointer
                   length:(size_t)dataLength {
    printf("rfcommChannelData:data:length:\n");
    
    char *cStr = (char *)dataPointer;
    cStr[dataLength - 1] = 0;
    
    printf("Received '%s'\n", cStr);
    fflush(stdout);
}


- (void)changeConnectionStatus:(const char *)statusCStr {
    jstring statusJStr = (*env)->NewStringUTF(env, statusCStr);
    (*env)->CallVoidMethod(env, thisObj, connectionStatusChanged, statusJStr);
}

@end
