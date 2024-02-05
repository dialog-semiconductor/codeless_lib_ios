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

#import "CodelessBaudRateCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@interface CodelessBaudRateCommand ()

/// <code>true</code> if the command has arguments, <code>false</code> for no arguments.
@property BOOL hasArguments;

@end

@implementation CodelessBaudRateCommand

static NSString* const TAG = @"BaudRateCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"BAUD";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_BAUD;

static NSString* PATTERN_STRING = @"^BAUD(?:=(\\d+))?$"; // <baud>
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessBaudRateCommand.class)
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

- (instancetype) initWithManager:(CodelessManager*)manager baudRate:(int)baudRate {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.baudRate = baudRate;
    self.hasArguments = true;
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

- (NSString*) getArguments {
    return self.hasArguments ? @(self.baudRate).stringValue : nil;
}

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    if (self.responseLine == 1) {
        NSScanner* scanner = [NSScanner scannerWithString:response];
        int num;
        if (![scanner scanInt:&num] || ![self validBaudRate:num]) {
            CodelessLog(TAG, "Received invalid baud rate: %@", response);
            self.invalid = true;
            return;
        }
        _baudRate = num;
        CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "Baud rate: %d", self.baudRate);
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid)
        [self sendEvent:CodelessLibEvent.BaudRate object:[[CodelessBaudRateEvent alloc] initWithCommand:self]];
}

- (BOOL) checkArgumentsCount {
    int count = [CodelessProfile countArguments:self.command split:@","];
    return count == 0 || count == 1;
}

- (NSString*) parseArguments {
    if (![CodelessProfile hasArguments:self.command])
        return nil;
    self.hasArguments = true;

    NSNumber* num = [self decodeNumberArgument:1];
    int value = num.intValue;
    if (!num || ![self validBaudRate:value])
        return @"Invalid baud rate";
    _baudRate = value;

    return nil;
}

/// Sets the baud rate argument.
- (void) setBaudRate:(int)baudRate {
    _baudRate = baudRate;
    if (![self validBaudRate:baudRate])
        self.invalid = true;
}

/// Checks if the baud rate value is valid.
- (BOOL) validBaudRate:(int)baudRate {
    return baudRate == CODELESS_COMMAND_BAUD_RATE_2400
    || baudRate == CODELESS_COMMAND_BAUD_RATE_4800
    || baudRate == CODELESS_COMMAND_BAUD_RATE_9600
    || baudRate == CODELESS_COMMAND_BAUD_RATE_19200
    || baudRate == CODELESS_COMMAND_BAUD_RATE_38400
    || baudRate == CODELESS_COMMAND_BAUD_RATE_57600
    || baudRate == CODELESS_COMMAND_BAUD_RATE_115200
    || baudRate == CODELESS_COMMAND_BAUD_RATE_230400;
}

@end
