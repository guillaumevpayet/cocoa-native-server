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

#import "RFCOMMChannelDelegate.h"

#import <stdlib.h>
#import <stdio.h>


@implementation RFCOMMChannelDelegate

- (instancetype)initWithEnv:(JNIEnv  _Nonnull *)env
                        obj:(jobject)obj {
    self = [super init];
    self->env = env;
    self->obj = obj;
    
    jclass clazz = (*env)->GetObjectClass(env, obj);
    
    stringReceived = (*env)->GetMethodID(env,
                                         clazz,
                                         "stringReceived",
                                         "(Ljava/lang/String;)V");
    
    return self;
}

- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel*)rfcommChannel
                     data:(void *)dataPointer
                   length:(size_t)dataLength {
    char *cStr = dataPointer;
    cStr[dataLength - 1] = 0;
    
    printf("rfcommChannelData:data:length: where data='%s'\n", cStr);
    fflush(stdout);
    
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
    CGKeyCode keyCode = 0;
    
    if (cStr[1] >= '0' && cStr[1] <= '9')
        keyCode = 0x52 + cStr[1] - '0';
    else if (strcmp(cStr + 1, "backspace") == 0)
        keyCode = 0x33;
    else if (strcmp(cStr + 1, "enter") == 0)
        keyCode = 0x4C;
    else if (strcmp(cStr + 1, "*") == 0)
        keyCode = 0x43;
    else if (strcmp(cStr + 1, "+") == 0)
        keyCode = 0x45;
    else if (strcmp(cStr + 1, "-") == 0)
        keyCode = 0x4E;
    else if (strcmp(cStr + 1, ".") == 0)
        keyCode = 0x41;
    else if (strcmp(cStr + 1, "/") == 0)
        keyCode = 0x4B;
    
    bool keyPressed = cStr[0] == '+';
    CGEventRef event = CGEventCreateKeyboardEvent(source, keyCode, keyPressed);
    
    if (event != nil) {
        CGEventPost(kCGHIDEventTap, event);
        CFRelease(event);
    }
    
    if (source != nil)
        CFRelease(source);
    
//    jstring jStr = (*env)->NewStringUTF(env, cStr);
//    (*env)->CallVoidMethod(env, thisObj, stringReceived, jStr);
}

@end
