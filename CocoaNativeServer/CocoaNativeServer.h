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

#import "ConnectionManager.h"

@interface CocoaNativeServer : NSObject {
@private
    JNIEnv *env;
    volatile ConnectionManager *connectionManager;
}

- (instancetype)initWithEnv:(JNIEnv *)env obj:(jobject)obj;

- (void)openWithUuid:(jstring)uuidJStr;
- (void)close;

@end
