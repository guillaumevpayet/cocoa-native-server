//
//  ConnectionStatusManager.h
//  CocoaNativeServer
//
//  Created by Guillaume Payet on 29/04/21.
//  Copyright © 2021 Guillaume Payet. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <jni.h>

NS_ASSUME_NONNULL_BEGIN

@interface StatusManager : NSObject {
@private
    JNIEnv *env;
    jobject obj;
    jmethodID connectionStatusChanged;
}

- (instancetype)initWithEnv:(JNIEnv _Nonnull *_Nonnull)env obj:(jobject)obj;

- (void)changeConnectionStatus:(const char *)statusCStr;

@end

NS_ASSUME_NONNULL_END
