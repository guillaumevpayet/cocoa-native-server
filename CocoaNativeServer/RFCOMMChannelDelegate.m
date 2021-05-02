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

@implementation RFCOMMChannelDelegate

- (instancetype)initWithEnv:(JNIEnv _Nonnull *_Nonnull)env obj:(jobject)obj {
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
    char *key = cStr + 1;
    
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
    CGKeyCode keyCode = 0;
    
    if (*key >= '0' && *key <= '7')
        keyCode = 0x52 + *key - '0';
    else if (strchr("89", *key))
        keyCode = 0x5B + *key - '8';
    else if (strcmp(key, "backspace") == 0)
        keyCode = 0x33;
    else if (strcmp(key, "enter") == 0)
        keyCode = 0x4C;
    else if (strcmp(key, "*") == 0)
        keyCode = 0x43;
    else if (strcmp(key, "+") == 0)
        keyCode = 0x45;
    else if (strcmp(key, "-") == 0)
        keyCode = 0x4E;
    else if (strcmp(key, ".") == 0)
        keyCode = 0x41;
    else if (strcmp(key, "/") == 0)
        keyCode = 0x4B;
    
    if (keyCode == 0)
        return;
    
    bool keyPressed = *cStr == '+';
    CGEventRef event = CGEventCreateKeyboardEvent(source, keyCode, keyPressed);
    
    if (event != nil) {
        CGEventPost(kCGHIDEventTap, event);
        CFRelease(event);
    }
    
    if (source != nil)
        CFRelease(source);
    
//    jstring jStr = (*env)->NewStringUTF(env, cStr);
//    (*env)->CallVoidMethod(env, obj, stringReceived, jStr);
}

@end
