/*
 **********************************************************************************
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Copyright (c) 2020-2024 Renesas Electronics Corporation and/or its affiliates
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of Renesas nor the names of its contributors may be
 *    used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY RENESAS "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY, NONINFRINGEMENT, AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL RENESAS OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 **********************************************************************************
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Utility and helper methods.
@interface CodelessUtil : NSObject

/**
 * Converts a byte array to a hex string.
 * @param v         the byte array to convert
 * @param uppercase <code>true</code> for uppercase hex characters, <code>false</code> for lowercase
 * @return the hex string
 */
+ (NSString*) hex:(NSData*)v uppercase:(BOOL)uppercase;

/**
 * Converts a byte array to an uppercase hex string.
 * @param v the byte array to convert
 * @return the hex string
 */
+ (NSString*) hex:(NSData*)v;

/**
 * Converts a byte array to a hex string with spaces between bytes, optionally contained in brackets.
 * @param v         the byte array to convert
 * @param uppercase <code>true</code> for uppercase hex characters, <code>false</code> for lowercase
 * @param brackets  <code>true</code> for adding brackets, <code>false</code> for no brackets
 * @return the hex string
 */
+ (NSString*) hexArray:(NSData*)v uppercase:(BOOL)uppercase brackets:(BOOL)brackets;

/**
 * Converts a byte array to an uppercase hex string with spaces between bytes.
 * @param v the byte array to convert
 * @return the hex string
 */
+ (NSString*) hexArray:(NSData*)v;

/**
 * Converts a byte array to an lowercase hex string contained in brackets with spaces between bytes.
 * <p> Used by the library to log data byte arrays.
 * @param v the byte array to convert
 * @return the hex string
 */
+ (NSString*) hexArrayLog:(NSData*)v;

/**
 * Converts a hex string to a byte array.
 * <p> Any non-hex characters and "0x" prefix are ignored.
 * @param s the hex string to convert (its length must be even)
 * @return the byte array
 */
+ (NSData*) hex2bytes:(NSString*)s;

/**
 * Checks if a Bluetooth address string is valid.
 * @param address the Bluetooth address string
 * @return <code>true</code> if the Bluetooth address string is valid
 */
+ (BOOL) checkBluetoothAddress:(NSString*)address;

@end


/// Byte buffer implementation with API similar to java.nio.ByteBuffer
@interface CodelessByteBuffer : NSObject

/// Byte order for multi-byte values.
enum {
    /// Big-endian byte order (default).
    CodelessByteBufferBigEndian,
    /// Little-endian byte order.
    CodelessByteBufferLittleEndian,
};

/// The byte buffer data.
@property NSData* data;
/// The byte buffer order.
@property int order;
/// The byte buffer current read position.
@property NSUInteger position;

/**
 * Creates a byte buffer with the specified capacity.
 * @param capacity the buffer capacity
 */
- (instancetype) initWithCapacity:(NSUInteger)capacity;
/**
 * Creates a byte buffer from an existing byte array.
 * @param data the byte array
 */
- (instancetype) initWithBuffer:(NSData*)data;

/**
 * Creates a byte buffer with the specified capacity.
 * @param capacity the buffer capacity
 */
+ (instancetype) allocate:(NSUInteger)capacity;
/**
 * Creates a byte buffer with the specified capacity.
 * @param capacity  the buffer capacity
 * @param order     the byte order
 */
+ (instancetype) allocate:(NSUInteger)capacity order:(int)order;
/**
 * Creates a byte buffer from an existing byte array.
 * @param data the byte array
 */
+ (instancetype) wrap:(NSData*)data;
/**
 * Creates a byte buffer from an existing byte array.
 * @param data      the byte array
 * @param order     the byte order
 */
+ (instancetype) wrap:(NSData*)data order:(int)order;
/**
 * Creates a byte buffer from an existing byte array.
 * @param data      the byte array
 * @param offset    the offset of the data in the byte array
 * @param length    the length of the data in the byte array
 * @param order     the byte order
 */
+ (instancetype) wrap:(NSData*)data offset:(NSUInteger)offset length:(NSUInteger)length order:(int)order;

/// Writes a byte to the buffer.
- (void) put:(uint8_t)v;
/// Writes a 16-bit value to the buffer.
- (void) putShort:(uint16_t)v;
/// Writes a 32-bit value to the buffer.
- (void) putInt:(uint32_t)v;
/// Writes a 64-bit value to the buffer.
- (void) putLong:(uint64_t)v;
/// Writes a byte array to the buffer.
- (void) putData:(NSData*)v;
/// Writes a byte array to the buffer.
- (void) put:(const uint8_t*)v length:(NSUInteger)length;

/// Reads a byte from the buffer (read position is updated).
- (uint8_t) get;
/// Reads a 16-bit value from the buffer (read position is updated).
- (uint16_t) getShort;
/// Reads a 32-bit value from the buffer (read position is updated).
- (uint32_t) getInt;
/// Reads a 64-bit value from the buffer (read position is updated).
- (uint64_t) getLong;
/// Reads a byte array from the buffer (read position is updated).
- (NSData*) getData:(NSUInteger)length;

/// Reads a byte from the buffer at the specified position.
- (uint8_t) get:(NSUInteger)position;
/// Reads a 16-bit value from the buffer at the specified position.
- (uint16_t) getShort:(NSUInteger)position;
/// Reads a 32-bit value from the buffer at the specified position.
- (uint32_t) getInt:(NSUInteger)position;
/// Reads a 64-bit value from the buffer at the specified position.
- (uint64_t) getLong:(NSUInteger)position;
/// Reads a byte array from the buffer at the specified position.
- (NSData*) getData:(NSUInteger)position length:(NSUInteger)length;

/// Returns the remaining number of bytes that may be read from the buffer.
- (NSUInteger) remaining;
/// Checks if there are bytes available to read in the buffer.
- (BOOL) hasRemaining;

@end

NS_ASSUME_NONNULL_END
