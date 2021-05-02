//
//  ConnectionStatusManager.m
//  CocoaNativeServer
//
//  Created by Guillaume Payet on 29/04/21.
//  Copyright © 2021 Guillaume Payet. All rights reserved.
//

#import "StatusManager.h"

@implementation StatusManager

- (instancetype)initWithEnv:(JNIEnv _Nonnull *_Nonnull)env obj:(jobject)obj {
    self = [super init];
    self->env = env;
    self->obj = obj;
    
    jclass clazz = (*env)->GetObjectClass(env, obj);
    
    connectionStatusChanged = (*env)->GetMethodID(env,
                                                  clazz,
                                                  "connectionStatusChanged",
                                                  "(Ljava/lang/String;)V");
    
    return self;
}

- (void)changeConnectionStatus:(const char *)statusCStr {
    jstring statusJStr = (*env)->NewStringUTF(env, statusCStr);
    (*env)->CallVoidMethod(env, obj, connectionStatusChanged, statusJStr);
}

@end
