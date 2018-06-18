//
//  com_guillaumepayet_remotenumpadserver_connection_bluetooth_NativeServer.m
//  CocoaNativeServer
//
//  Created by Guillaume Payet on 1/03/18.
//  Copyright © 2018 Guillaume Payet. All rights reserved.
//

#import "com_guillaumepayet_remotenumpadserver_connection_bluetooth_NativeServer.h"

#import "CocoaNativeServer.h"


static CocoaNativeServer *server;


JNIEXPORT jboolean JNICALL Java_com_guillaumepayet_remotenumpadserver_connection_bluetooth_NativeServer_open
(JNIEnv *env, jobject obj, jstring uuid) {
    @autoreleasepool {
        server = [[CocoaNativeServer alloc] init];
        [server setEnv:env obj:obj];

        @try {
            [server openWithUuid:uuid];
        } @catch (NSException *exception) {
            return 0;
        }
    }

    return 1;
}

JNIEXPORT void JNICALL Java_com_guillaumepayet_remotenumpadserver_connection_bluetooth_NativeServer_close
(JNIEnv *env, jobject obj) {
    [server close];
    server = nil;
}

JNIEXPORT void JNICALL Java_com_guillaumepayet_remotenumpadserver_connection_bluetooth_NativeServer_setProperty
(JNIEnv *env, jobject obj, jstring key, jstring value) {
    @autoreleasepool {
        const char *keyCStr = (*env)->GetStringUTFChars(env, key, nil);

        if (strcmp(keyCStr, "service_dictionary") == 0) {
            CocoaNativeServer.serviceDictionary = (*env)->GetStringUTFChars(env, value, nil);
        }
    }
}
