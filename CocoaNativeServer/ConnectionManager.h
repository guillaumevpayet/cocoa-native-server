//
//  ConnectionManager.h
//  CocoaNativeServer
//
//  Created by Guillaume Payet on 1/05/21.
//  Copyright © 2021 Guillaume Payet. All rights reserved.
//

#import "RFCOMMChannelDelegate.h"

#import "StatusManager.h"

NS_ASSUME_NONNULL_BEGIN

@class RFCOMMChannelDelegate;

@interface ConnectionManager : NSObject {
@private
    BOOL firstTime;
    StatusManager *statusManager;
    RFCOMMChannelDelegate *delegate;
    volatile dispatch_semaphore_t lock;
    volatile IOBluetoothUserNotification *openNotification;
    volatile IOBluetoothUserNotification *closeNotification;
    volatile IOBluetoothRFCOMMChannel *channel;
}

- (instancetype)initWithEnv:(JNIEnv _Nonnull *_Nonnull)env obj:(jobject) obj;

- (void)startListeningToChannel:(BluetoothRFCOMMChannelID)channelID;

- (void)stopListening;

- (void)onChannelOpened:(IOBluetoothUserNotification *)notification
                channel:(IOBluetoothRFCOMMChannel *)channel;

- (void)onChannelClosed:(IOBluetoothUserNotification *)notification
                channel:(IOBluetoothRFCOMMChannel *)channel;

@end

NS_ASSUME_NONNULL_END
