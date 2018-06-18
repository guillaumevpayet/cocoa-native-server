//
//  CocoaNativeServer.m
//  CocoaNativeServer
//
//  Created by Guillaume Payet on 1/03/18.
//  Copyright © 2018 Guillaume Payet. All rights reserved.
//

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


- (instancetype)init {
    self = [super init];

    if (self) {
        encoding = [NSString defaultCStringEncoding];
        lock = dispatch_semaphore_create(0);
    }

    return self;
}

- (void)setEnv:(JNIEnv *)env obj:(jobject)obj {
    self->env = env;
    self->thisObj = obj;

    jclass thisClass = (*env)->GetObjectClass(env, thisObj);

    connectionStatusChanged = (*env)->GetMethodID(env,
                                                  thisClass,
                                                  "connectionStatusChanged",
                                                  "(Ljava/lang/String;)V");

    stringReceived = (*env)->GetMethodID(env,
                                         thisClass,
                                         "stringReceived",
                                         "(Ljava/lang/String;)V");
}

- (void)openWithUuid:(jstring)uuidJStr {
    NSString *file = [[NSString alloc] initWithUTF8String:serviceDictionaryFile];
    NSDictionary *properties = [NSDictionary dictionaryWithContentsOfFile:file];

    if (properties) {
        const char *uuidCStr = (*env)->GetStringUTFChars(env, uuidJStr, nil);
        NSString *uuidStr = [[NSString alloc] initWithUTF8String:uuidCStr];
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidStr];
        uuid_t uuidBytes;
        [uuid getUUIDBytes:uuidBytes];
        NSData *data = [NSData dataWithBytes:uuidBytes length:16];

        properties[@"0001 - ServiceClassIDList"][0] = data;
        properties[@"0009 - BluetoothProfileDescriptorList"][0][0] = data;
        serviceRecord = [IOBluetoothSDPServiceRecord publishedServiceRecordWithDictionary:properties];
    }

    if (!serviceRecord) {
        @throw [NSException exceptionWithName:@"SDPException"
                                       reason:@"Could not register SDP service"
                                     userInfo:nil];
    }

    BluetoothRFCOMMChannelID channelID;
    [serviceRecord getRFCOMMChannelID:&channelID];

    SEL selector = @selector(channelOpenedNotification:channel:);
    IOBluetoothUserNotificationChannelDirection direction = kIOBluetoothUserNotificationChannelDirectionIncoming;
    [self changeConnectionStatus:"SERVER_READY"];

    while (serviceRecord) {
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
    if (notifOut) {
        [notifOut unregister];
        notifOut = nil;
    }

    if (notifIn) {
        [notifIn unregister];
        notifIn = nil;
    }

    if (serviceRecord) {
        [serviceRecord removeServiceRecord];
        serviceRecord = nil;
    }

    dispatch_semaphore_signal(lock);
}

- (void)channelOpenedNotification:(IOBluetoothUserNotification *)notification
                          channel:(IOBluetoothRFCOMMChannel *)channel {
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
    ((char *)dataPointer)[dataLength - 1] = 0;
    [self receiveString:dataPointer];
}


- (jobject)statusFromStatusClass:(jclass)statusClass
                   statusCString:(const char *)statusCStr
          statusSignatureCString:(const char *)statusSigCStr {
    jfieldID statusID = (*env)->GetStaticFieldID(env,
                                                 statusClass,
                                                 statusCStr,
                                                 statusSigCStr);

    return (*env)->GetStaticObjectField(env, statusClass, statusID);
}

- (void)changeConnectionStatus:(const char *)statusCStr {
    jstring statusJStr = (*env)->NewStringUTF(env, statusCStr);
    (*env)->CallVoidMethod(env, thisObj, connectionStatusChanged, statusJStr);
}

- (void)receiveString:(const char *)cStr {
    jstring jStr = (*env)->NewStringUTF(env, cStr);
    (*env)->CallVoidMethod(env, thisObj, stringReceived, jStr);
}

@end
