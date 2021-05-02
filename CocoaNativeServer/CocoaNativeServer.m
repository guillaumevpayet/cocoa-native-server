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

    if (serviceRecord != nil) {
        IOReturn result = [serviceRecord removeServiceRecord];
        printf("Removing the service record yields a '");
        
        switch (result) {
            case kIOReturnSuccess:
                printf("kIOReturnSuccess");
                break;
            case kIOReturnError:
                printf("kIOReturnError");
                break;
            case kIOReturnNoMemory:
                printf("kIOReturnNoMemory");
                break;
            case kIOReturnNoResources:
                printf("kIOReturnNoResources");
                break;
            case kIOReturnIPCError:
                printf("kIOReturnIPCError");
                break;
            case kIOReturnNoDevice:
                printf("kIOReturnNoDevice");
                break;
            case kIOReturnNotPrivileged:
                printf("kIOReturnNotPrivileged");
                break;
            case kIOReturnBadArgument:
                printf("kIOReturnBadArgument");
                break;
            case kIOReturnLockedRead:
                printf("kIOReturnLockedRead");
                break;
            case kIOReturnLockedWrite:
                printf("kIOReturnLockedWrite");
                break;
            case kIOReturnExclusiveAccess:
                printf("kIOReturnExclusiveAccess");
                break;
            case kIOReturnBadMessageID:
                printf("kIOReturnBadMessageID");
                break;
            case kIOReturnUnsupported:
                printf("kIOReturnUnsupported");
                break;
            case kIOReturnVMError:
                printf("kIOReturnVMError");
                break;
            case kIOReturnInternalError:
                printf("kIOReturnInternalError");
                break;
            case kIOReturnIOError:
                printf("kIOReturnIOError");
                break;
            case kIOReturnCannotLock:
                printf("kIOReturnCannotLock");
                break;
            case kIOReturnNotOpen:
                printf("kIOReturnNotOpen");
                break;
            case kIOReturnNotReadable:
                printf("kIOReturnNotReadable");
                break;
            case kIOReturnNotWritable:
                printf("kIOReturnNotWritable");
                break;
            case kIOReturnNotAligned:
                printf("kIOReturnNotAligned");
                break;
            case kIOReturnBadMedia:
                printf("kIOReturnBadMedia");
                break;
            case kIOReturnStillOpen:
                printf("kIOReturnStillOpen");
                break;
            case kIOReturnRLDError:
                printf("kIOReturnRLDError");
                break;
            case kIOReturnDMAError:
                printf("kIOReturnDMAError");
                break;
            case kIOReturnBusy:
                printf("kIOReturnBusy");
                break;
            case kIOReturnTimeout:
                printf("kIOReturnTimeout");
                break;
            case kIOReturnOffline:
                printf("kIOReturnOffline");
                break;
            case kIOReturnNotReady:
                printf("kIOReturnNotReady");
                break;
            case kIOReturnNotAttached:
                printf("kIOReturnNotAttached");
                break;
            case kIOReturnNoChannels:
                printf("kIOReturnNoChannels");
                break;
            case kIOReturnNoSpace:
                printf("kIOReturnNoSpace");
                break;
            case kIOReturnPortExists:
                printf("kIOReturnPortExists");
                break;
            case kIOReturnCannotWire:
                printf("kIOReturnCannotWire");
                break;
            case kIOReturnNoInterrupt:
                printf("kIOReturnNoInterrupt");
                break;
            case kIOReturnNoFrames:
                printf("kIOReturnNoFrames");
                break;
            case kIOReturnMessageTooLarge:
                printf("kIOReturnMessageTooLarge");
                break;
            case kIOReturnNotPermitted:
                printf("kIOReturnNotPermitted");
                break;
            case kIOReturnNoPower:
                printf("kIOReturnNoPower");
                break;
            case kIOReturnNoMedia:
                printf("kIOReturnNoMedia");
                break;
            case kIOReturnUnformattedMedia:
                printf("kIOReturnUnformattedMedia");
                break;
            case kIOReturnUnsupportedMode:
                printf("kIOReturnUnsupportedMode");
                break;
            case kIOReturnUnderrun:
                printf("kIOReturnUnderrun");
                break;
            case kIOReturnOverrun:
                printf("kIOReturnOverrun");
                break;
            case kIOReturnDeviceError:
                printf("kIOReturnDeviceError");
                break;
            case kIOReturnNoCompletion:
                printf("kIOReturnNoCompletion");
                break;
            case kIOReturnAborted:
                printf("kIOReturnAborted");
                break;
            case kIOReturnNoBandwidth:
                printf("kIOReturnNoBandwidth");
                break;
            case kIOReturnNotResponding:
                printf("kIOReturnNotResponding");
                break;
            case kIOReturnIsoTooOld:
                printf("kIOReturnIsoTooOld");
                break;
            case kIOReturnIsoTooNew:
                printf("kIOReturnIsoTooNew");
                break;
            case kIOReturnNotFound:
                printf("kIOReturnNotFound");
                break;
            case kIOReturnInvalid:
                printf("kIOReturnInvalid");
                break;
            default:
                printf("Something else.");
        }
        
        printf("'.\n");
        fflush(stdout);
    }
}

- (void)close {
    volatile ConnectionManager *connectionManager = self->connectionManager;
    self->connectionManager = nil;
    [connectionManager stopListening];
}

@end
