//
//  ConnectionManager.m
//  CocoaNativeServer
//
//  Created by Guillaume Payet on 1/05/21.
//  Copyright © 2021 Guillaume Payet. All rights reserved.
//

#import "ConnectionManager.h"

const IOBluetoothUserNotificationChannelDirection DIRECTION = kIOBluetoothUserNotificationChannelDirectionIncoming;

@implementation ConnectionManager

- (instancetype)initWithEnv:(JNIEnv _Nonnull *_Nonnull)env obj:(jobject) obj {
    self = [super init];
    firstTime = YES;
    statusManager = [[StatusManager alloc] initWithEnv:env obj:obj];
    delegate = [[RFCOMMChannelDelegate alloc] initWithEnv:env obj:obj];
    lock = dispatch_semaphore_create(0);
    return self;
}

- (void)startListeningToChannel:(BluetoothRFCOMMChannelID)channelID {
    openNotification = [IOBluetoothRFCOMMChannel registerForChannelOpenNotifications:self
                                                                            selector:@selector(onChannelOpened:channel:)
                                                                       withChannelID:channelID
                                                                           direction:DIRECTION];

    if (firstTime) {
        [statusManager changeConnectionStatus:"SERVER_READY"];
        firstTime = NO;
    }

    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    
    if (closeNotification != nil) {
        [statusManager changeConnectionStatus:"CLIENT_CONNECTED"];
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        [statusManager changeConnectionStatus:"CLIENT_DISCONNECTED"];
    }
}

- (void)stopListening {
    if (channel != nil) {
        [channel closeChannel];
        channel = nil;
    }

    if (closeNotification != nil) {
        [closeNotification unregister];
        closeNotification = nil;
    }

    if (openNotification != nil) {
        [openNotification unregister];
        openNotification = nil;
    }
    
    dispatch_semaphore_signal(lock);
}

- (void)onChannelOpened:(IOBluetoothUserNotification *)notification
                channel:(IOBluetoothRFCOMMChannel *)channel {
    openNotification = nil;
    self->channel = channel;
    [notification unregister];
    [channel setDelegate:delegate];
    
    closeNotification = [channel registerForChannelCloseNotification:self
                                                            selector:@selector(onChannelClosed:channel:)];
    
    dispatch_semaphore_signal(lock);
}

- (void)onChannelClosed:(IOBluetoothUserNotification *)notification
                channel:(IOBluetoothRFCOMMChannel *)channel {
    closeNotification = nil;
    self->channel = nil;
    [notification unregister];
    [channel closeChannel];
    dispatch_semaphore_signal(lock);
}

@end
