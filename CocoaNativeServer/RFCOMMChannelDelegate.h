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

#import <IOBluetooth/IOBluetooth.h>

#import <jni.h>


NS_ASSUME_NONNULL_BEGIN

@interface RFCOMMChannelDelegate : NSObject<IOBluetoothRFCOMMChannelDelegate> {
@private
    JNIEnv *env;
    jobject obj;
    jmethodID stringReceived;
}

- (instancetype)initWithEnv:(JNIEnv _Nonnull *_Nonnull)env
                        obj:(jobject)obj;

- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel*)rfcommChannel
                     data:(void *)dataPointer
                   length:(size_t)dataLength;

@end

NS_ASSUME_NONNULL_END
