//
//  CocoaNativeServer.h
//  CocoaNativeServer
//
//  Created by Guillaume Payet on 1/03/18.
//  Copyright © 2018 Guillaume Payet. All rights reserved.
//

#import <IOBluetooth/IOBluetooth.h>

#import <jni.h>


@interface CocoaNativeServer : NSObject<IOBluetoothRFCOMMChannelDelegate> {
@private
    JNIEnv *env;
    jobject thisObj;
    jmethodID connectionStatusChanged, stringReceived;
    NSStringEncoding encoding;
    volatile dispatch_semaphore_t lock;
    volatile IOBluetoothSDPServiceRecord *serviceRecord;
    volatile IOBluetoothUserNotification *notifIn;
    volatile IOBluetoothUserNotification *notifOut;
}

+ (const char *)serviceDictionary;
+ (void)setServiceDictionary:(const char *)serviceDictionary;

- (instancetype)init;

- (void)setEnv:(JNIEnv *)env obj:(jobject)obj;
- (void)openWithUuid:(jstring)uuidJStr;
- (void)close;

- (void)channelOpenedNotification:(IOBluetoothUserNotification *)notification
                          channel:(IOBluetoothRFCOMMChannel *)channel;
- (void)channelClosedNotification:(IOBluetoothUserNotification *)notification
                          channel:(IOBluetoothRFCOMMChannel *)channel;

- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel*)rfcommChannel
                     data:(void *)dataPointer
                   length:(size_t)dataLength;


- (jobject)statusFromStatusClass:(jclass)statusClass
                   statusCString:(const char *)statusCStr
          statusSignatureCString:(const char *)statusSigCStr;

- (void)changeConnectionStatus:(const char *)statusCStr;
- (void)receiveString:(const char *)cStr;

@end
