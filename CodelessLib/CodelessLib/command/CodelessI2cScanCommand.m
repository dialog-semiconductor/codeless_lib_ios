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

#import "CodelessI2cScanCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@implementation I2cDevice

- (instancetype) init {
    self = [super init];
    if (!self)
        return nil;
    self.registerZero = -1;
    return self;
}

- (instancetype) initWithAddress:(int)address {
    self = [self init];
    if (!self)
        return nil;
    self.address = address;
    return self;
}

- (instancetype) initWithAddress:(int)address registerZero:(int)registerZero {
    self = [self initWithAddress:address];
    if (!self)
        return nil;
    self.registerZero = registerZero;
    return self;
}

- (BOOL) hasRegisterZero {
    return self.registerZero != -1;
}

- (NSString*) addressString {
    return [NSString stringWithFormat:@"0x%x", self.address];
}

- (NSString*) description {
    return [[self addressString] stringByAppendingString:(self.hasRegisterZero ? [NSString stringWithFormat:@"(0x%x)", self.registerZero] : @"")];
}

@end

@implementation CodelessI2cScanCommand

static NSString* const TAG = @"I2cScanCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"I2CSCAN";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_I2CSCAN;

static NSString* PATTERN_STRING = @"^I2CSCAN$";
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessI2cScanCommand.class)
        return;

    NAME = [CodelessProfile.PREFIX_LOCAL stringByAppendingString:COMMAND];

    NSError* error = nil;
    PATTERN = [NSRegularExpression regularExpressionWithPattern:PATTERN_STRING options:0 error:&error];
}

+ (NSString*) COMMAND {
    return COMMAND;
}

+ (NSString*) NAME {
    return NAME;
}

+ (int) ID {
    return ID;
}

+ (NSString*) PATTERN_STRING {
    return PATTERN_STRING;
}

+ (NSRegularExpression*) PATTERN {
    return PATTERN;
}

- (instancetype) init {
    self = [super init];
    if (!self)
        return nil;
    self.devices = [NSMutableArray array];
    return self;
}

- (NSString*) TAG {
    return TAG;
}

- (NSString*) ID {
    return COMMAND;
}

- (NSString*) name {
    return NAME;
}

- (int) commandID {
    return ID;
}

- (NSRegularExpression*) pattern {
    return PATTERN;
}

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    NSArray<NSString*>* scanResults = [response componentsSeparatedByString:@","];
    for (NSString* result in scanResults) {
        NSRange index = [result rangeOfString:@":"];
        NSScanner* scanner = [NSScanner scannerWithString:NSEqualRanges(index, NSMakeRange(NSNotFound, 0)) ? result : [result substringToIndex:index.location]];
        unsigned int address;
        if (![scanner scanHexInt:&address]) {
            self.invalid = true;
            CodelessLog(TAG, "Received invalid I2C scan results: %@", response);
            return;
        }
        I2cDevice* device = [[I2cDevice alloc] initWithAddress:address];
        if (!NSEqualRanges(index, NSMakeRange(NSNotFound, 0))) {
            scanner = [NSScanner scannerWithString:[result substringFromIndex:index.location + 1]];
            unsigned int registerZero;
            if (![scanner scanHexInt:&registerZero]) {
                self.invalid = true;
                CodelessLog(TAG, "Received invalid I2C scan results: %@", response);
                return;
            }
            device.registerZero = registerZero;
        }
        [self.devices addObject:device];
    }
    CodelessLogOpt(CodelessLibLog.COMMAND, TAG, @"I2C scan results: %@", self.devices);
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid) {
        if (CodelessLibLog.COMMAND && !self.devices.count)
            CodelessLog(TAG, "No I2C devices found");
        [self sendEvent:CodelessLibEvent.I2cScan object:[[CodelessI2cScanEvent alloc] initWithCommand:self]];
    }
}

@end
