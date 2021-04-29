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

#import "com_guillaumepayet_remotenumpadserver_connection_bluetooth_NativeServer.h"

#import "CocoaNativeServer.h"


static CocoaNativeServer *server = nil;


JNIEXPORT jboolean JNICALL Java_com_guillaumepayet_remotenumpadserver_connection_bluetooth_NativeServer_open
(JNIEnv *env, jobject obj, jstring uuid) {
    @autoreleasepool {
        server = [[CocoaNativeServer alloc] initWithEnv:env obj:obj];
        
        @try {
            [server openWithUuid:uuid];
        } @catch (NSException *exception) {
            fprintf(stderr, "%s", exception.reason.UTF8String);
            return 0;
        } @catch (NSError *error) {
            fprintf(stderr, "%s", error.localizedFailureReason.UTF8String);
            return 0;
        }
    }

    return 1;
}

JNIEXPORT void JNICALL Java_com_guillaumepayet_remotenumpadserver_connection_bluetooth_NativeServer_close
(JNIEnv *env, jobject obj) {
    @autoreleasepool {
        [server close];
        server = nil;
    }
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
