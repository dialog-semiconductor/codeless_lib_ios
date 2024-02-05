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

#import "CodelessUtil.h"

static const char HEX_DIGITS_LC[] = "0123456789abcdef";
static const char HEX_DIGITS_UC[] = "0123456789ABCDEF";
static NSDictionary<NSNumber*, NSNumber*>* HEX_DIGITS_MAP;
static NSRegularExpression* BLUETOOTH_ADDRESS;

@implementation CodelessUtil

+ (void) initialize {
    if (self != CodelessUtil.class)
        return;

    NSMutableDictionary<NSNumber*, NSNumber*>* hexDigitsMap = [NSMutableDictionary dictionary];
    for (int i = 0; i < 16; ++i) {
        hexDigitsMap[@(HEX_DIGITS_LC[i])] = @(i);
        hexDigitsMap[@(HEX_DIGITS_UC[i])] = @(i);
    }
    HEX_DIGITS_MAP = [NSDictionary dictionaryWithDictionary:hexDigitsMap];

    NSString* pattern = @"^(?:[0-9A-F]{2}:){5}[0-9A-F]{2}$";
    BLUETOOTH_ADDRESS = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
}

+ (NSString*) hex:(NSData*)v uppercase:(BOOL)uppercase {
    if (!v)
        return @"<null>";
    NSString* hexFormat = uppercase ? @"%02X" : @"%02x";
    NSMutableString* buffer = [NSMutableString stringWithCapacity:v.length * 2];
    const uint8_t* b = v.bytes;
    for (int i = 0; i < v.length; ++i) {
        [buffer appendFormat:hexFormat, b[i]];
    }
    return buffer;
}

+ (NSString*) hex:(NSData*)v {
    return [self hex:v uppercase:true];
}

+ (NSString*) hexArray:(NSData*)v uppercase:(BOOL)uppercase brackets:(BOOL)brackets {
    if (!v)
        return @"[]";
    NSString* hexFormat = uppercase ? @"%02X " : @"%02x ";
    NSMutableString* buffer = [NSMutableString stringWithCapacity:v.length * 3 + 3];
    if (brackets)
        [buffer appendString:@"[ "];
    const uint8_t* b = v.bytes;
    for (int i = 0; i < v.length; ++i) {
        [buffer appendFormat:hexFormat, b[i]];
    }
    if (brackets)
        [buffer appendString:@"]"];
    else if (buffer.length)
        [buffer deleteCharactersInRange:NSMakeRange(buffer.length - 1, 1)];
    return buffer;
}

+ (NSString*) hexArray:(NSData*)v {
    return [self hexArray:v uppercase:true brackets:false];
}

+ (NSString*) hexArrayLog:(NSData*)v {
    return [self hexArray:v uppercase:false brackets:true];
}

+ (NSData*) hex2bytes:(NSString*)s {
    s = [s stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    NSMutableString* m = s.mutableCopy;
    NSRegularExpression* pattern = [NSRegularExpression regularExpressionWithPattern:@"[^a-fA-F0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
    [pattern replaceMatchesInString:m options:0 range:NSMakeRange(0, m.length) withTemplate:@""];
    s = m;
    if (s.length % 2 != 0)
        return nil;
    NSMutableData* data = [NSMutableData dataWithLength:s.length / 2];
    uint8_t* b = data.mutableBytes;
    for (int i = 0; i < s.length; ++i) {
        NSNumber* d = HEX_DIGITS_MAP[@([s characterAtIndex:i])];
        if (!d)
            return nil;
        b[i / 2] |= i % 2 == 0 ? d.unsignedCharValue << 4 : d.unsignedCharValue;
    }
    return data;
}

+ (BOOL) checkBluetoothAddress:(NSString*)address {
    return [BLUETOOTH_ADDRESS numberOfMatchesInString:address options:0 range:NSMakeRange(0, address.length)] == 1;
}

@end


@implementation CodelessByteBuffer

- (instancetype) init {
    self = [super init];
    if (!self)
        return nil;
    self.order = CodelessByteBufferBigEndian;
    self.position = 0;
    return self;
}

- (instancetype) initWithCapacity:(NSUInteger)capacity {
    self = [self init];
    if (!self)
        return nil;
    self.data = [NSMutableData dataWithCapacity:capacity];
    return self;
}

- (instancetype) initWithBuffer:(NSData*)data {
    self = [self init];
    if (!self)
        return nil;
    self.data = data;
    return self;
}

+ (instancetype) allocate:(NSUInteger)capacity {
    return [(CodelessByteBuffer*)[self alloc] initWithCapacity:capacity];
}

+ (instancetype) allocate:(NSUInteger)capacity order:(int)order {
    CodelessByteBuffer* buffer = [self allocate:capacity];
    buffer.order = order;
    return buffer;
}

+ (instancetype) wrap:(NSData*)data {
    return [[self alloc] initWithBuffer:data];
}

+ (instancetype) wrap:(NSData*)data order:(int)order {
    CodelessByteBuffer* buffer = [self wrap:data];
    buffer.order = order;
    return buffer;
}

+ (instancetype) wrap:(NSData*)data offset:(NSUInteger)offset length:(NSUInteger)length order:(int)order {
    return [self wrap:[data subdataWithRange:NSMakeRange(offset ,length)] order:order];
}

- (void) put:(uint8_t)v {
    [(NSMutableData*)self.data appendBytes:&v length:1];
}

- (void) putShort:(uint16_t)v {
    v = self.order == CodelessByteBufferBigEndian ? CFSwapInt16HostToBig(v) : CFSwapInt16HostToLittle(v);
    [(NSMutableData*)self.data appendBytes:&v length:2];
}

- (void) putInt:(uint32_t)v {
    v = self.order == CodelessByteBufferBigEndian ? CFSwapInt32HostToBig(v) : CFSwapInt32HostToLittle(v);
    [(NSMutableData*)self.data appendBytes:&v length:4];
}

- (void) putLong:(uint64_t)v {
    v = self.order == CodelessByteBufferBigEndian ? CFSwapInt64HostToBig(v) : CFSwapInt64HostToLittle(v);
    [(NSMutableData*)self.data appendBytes:&v length:8];
}

- (void) putData:(NSData*)v {
    [(NSMutableData*)self.data appendData:v];
}

- (void) put:(const uint8_t*)v length:(NSUInteger)length {
    [(NSMutableData*)self.data appendBytes:v length:length];
}

- (uint8_t) get {
    uint8_t v = [self get:self.position];
    self.position += 1;
    return v;
}

- (uint16_t) getShort {
    uint16_t v = [self getShort:self.position];
    self.position += 2;
    return v;
}

- (uint32_t) getInt {
    uint32_t v = [self getInt:self.position];
    self.position += 4;
    return v;
}

- (uint64_t) getLong {
    uint64_t v = [self getLong:self.position];
    self.position += 8;
    return v;
}

- (NSData*) getData:(NSUInteger)length {
    NSData* data = [self getData:self.position length:length];
    self.position += length;
    return data;
}

- (uint8_t) get:(NSUInteger)position {
    [self checkRange:position length:1];
    return *((uint8_t*)self.data.bytes + position);
}

- (uint16_t) getShort:(NSUInteger)position {
    [self checkRange:position length:2];
    uint16_t v = *(uint16_t*)((uint8_t*)self.data.bytes + position);
    return self.order == CodelessByteBufferBigEndian ? CFSwapInt16BigToHost(v) : CFSwapInt16LittleToHost(v);
}

- (uint32_t) getInt:(NSUInteger)position {
    [self checkRange:position length:4];
    uint32_t v = *(uint32_t*)((uint8_t*)self.data.bytes + position);
    return self.order == CodelessByteBufferBigEndian ? CFSwapInt32BigToHost(v) : CFSwapInt32LittleToHost(v);
}

- (uint64_t) getLong:(NSUInteger)position {
    [self checkRange:position length:8];
    uint64_t v = *(uint64_t*)((uint8_t*)self.data.bytes + position);
    return self.order == CodelessByteBufferBigEndian ? CFSwapInt64BigToHost(v) : CFSwapInt64LittleToHost(v);
}

- (NSData*) getData:(NSUInteger)position length:(NSUInteger)length {
    [self checkRange:position length:length];
    return [self.data subdataWithRange:NSMakeRange(position, length)];
}

- (NSUInteger) remaining {
    return self.data.length - self.position;
}

- (BOOL) hasRemaining {
    return self.position < self.data.length;
}

- (void) checkRange:(NSUInteger)position length:(NSUInteger)length {
    if (position + length > self.data.length)
        @throw [NSException exceptionWithName:NSRangeException reason:@"CodelessByteBuffer range error" userInfo:nil];
}

@end
