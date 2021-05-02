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

- (instancetype)initWithEnv:(JNIEnv *)env obj:(jobject)obj {
    self = [super init];
    
    if (self == nil) {
        @throw [NSException exceptionWithName:@"InitException"
                                       reason:@"Could not initialize native server."
                                     userInfo:nil];
    }
    
    self->env = env;
    connectionManager = [[ConnectionManager alloc] initWithEnv:env obj:obj];
    return self;
}

- (void)openWithUuid:(jstring)uuidJStr {
    const char *uuidCStr = (*env)->GetStringUTFChars(env, uuidJStr, nil);
    NSString *uuidStr = [NSString stringWithUTF8String:uuidCStr];
    NSUUID *uuid = [[NSUUID UUID] initWithUUIDString:uuidStr];
    uuid_t uuidBytes;
    [uuid getUUIDBytes:uuidBytes];
    
    NSDictionary *properties = @{
        @"0000 - ServiceRecordHandle":@686723,
        @"0001 - Service UUID":@[ [IOBluetoothSDPUUID dataWithBytes:uuidBytes length:16] ],
        @"0004 - ProtocolDescriptorList":@[
                @[
                    [IOBluetoothSDPUUID dataWithBytes:"\x00\x03" length:2],
                    @3
                ]
        ],
        @"0100 - Service Name":@"Remote Numpad",
    };
    
    IOBluetoothSDPServiceRecord *serviceRecord = [IOBluetoothSDPServiceRecord publishedServiceRecordWithDictionary:properties];
    
    if (serviceRecord == nil) {
        @throw [NSException exceptionWithName:@"SDPException"
                                       reason:@"Could not register SDP service"
                                     userInfo:nil];
    }

    BluetoothRFCOMMChannelID channelID;
    [serviceRecord getRFCOMMChannelID:&channelID];

    while (connectionManager != nil) {
        [connectionManager startListeningToChannel:channelID];
    }

    if (serviceRecord != nil)
        [serviceRecord removeServiceRecord];
}

- (void)close {
    volatile ConnectionManager *connectionManager = self->connectionManager;
    self->connectionManager = nil;
    [connectionManager stopListening];
}

@end
