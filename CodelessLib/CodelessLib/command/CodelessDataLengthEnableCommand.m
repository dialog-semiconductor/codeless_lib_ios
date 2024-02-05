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

#import "CodelessDataLengthEnableCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@interface CodelessDataLengthEnableCommand ()

/// <code>true</code> if the command has arguments, <code>false</code> for no arguments.
@property BOOL hasArguments;

@end

@implementation CodelessDataLengthEnableCommand

static NSString* const TAG = @"DataLengthEnableCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"DLEEN";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_DLEEN;

static NSString* PATTERN_STRING = @"^DLEEN(?:=(\\d),(\\d+),(\\d+))?$"; // <enable> <tx> <rx>
static NSRegularExpression* PATTERN;

static NSString* RESPONSE_PATTERN_STRING = @"^(\\d).(\\d+).(\\d+)$"; // <enable> <tx> <rx>
static NSRegularExpression* RESPONSE_PATTERN;

+ (void) initialize {
    if (self != CodelessDataLengthEnableCommand.class)
        return;

    NAME = [CodelessProfile.PREFIX_LOCAL stringByAppendingString:COMMAND];

    NSError* patternError = nil;
    PATTERN = [NSRegularExpression regularExpressionWithPattern:PATTERN_STRING options:0 error:&patternError];

    NSError* responsePatternError = nil;
    RESPONSE_PATTERN = [NSRegularExpression regularExpressionWithPattern:RESPONSE_PATTERN_STRING options:0 error:&responsePatternError];
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

+ (NSString*) RESPONSE_PATTERN_STRING {
    return RESPONSE_PATTERN_STRING;
}

+ (NSRegularExpression*) RESPONSE_PATTERN {
    return RESPONSE_PATTERN;
}

- (instancetype) initWithManager:(CodelessManager*)manager enabled:(BOOL)enabled txPacketLength:(int)txPacketLength rxPacketLength:(int)rxPacketLength {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.enabled = enabled;
    self.txPacketLength = txPacketLength;
    self.rxPacketLength = rxPacketLength;
    self.hasArguments = true;
    return self;
}

- (instancetype) initWithManager:(CodelessManager*)manager enabled:(BOOL)enabled {
    return [self initWithManager:manager enabled:enabled txPacketLength:CODELESS_COMMAND_DLE_PACKET_LENGTH_DEFAULT rxPacketLength:CODELESS_COMMAND_DLE_PACKET_LENGTH_DEFAULT];
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
    return self.hasArguments ? [NSString stringWithFormat:@"%d,%d,%d", self.enabled ? CODELESS_COMMAND_DLE_ENABLED : CODELESS_COMMAND_DLE_DISABLED, self.txPacketLength, self.rxPacketLength] : nil;
}

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    if (self.responseLine == 1) {
        NSString* errorMsg = [NSString stringWithFormat:@"Received invalid DLE parameters: %@", response];
        NSTextCheckingResult* matcher = [RESPONSE_PATTERN firstMatchInString:response options:0 range:NSMakeRange(0, response.length)];
        if (matcher) {
            NSScanner* scanner = [NSScanner scannerWithString:[response substringWithRange:[matcher rangeAtIndex:1]]];
            int num;
            if (![scanner scanInt:&num] || num != CODELESS_COMMAND_DLE_DISABLED && num != CODELESS_COMMAND_DLE_ENABLED) {
                self.invalid = true;
                CodelessLog(TAG, "%@", errorMsg);
                return;
            }
            _enabled = num != CODELESS_COMMAND_DLE_DISABLED;

            scanner = [NSScanner scannerWithString:[response substringWithRange:[matcher rangeAtIndex:2]]];
            if (![scanner scanInt:&num] || num < CODELESS_COMMAND_DLE_PACKET_LENGTH_MIN || num > CODELESS_COMMAND_DLE_PACKET_LENGTH_MAX) {
                self.invalid = true;
                CodelessLog(TAG, "%@", errorMsg);
                return;
            }
            _txPacketLength = num;

            scanner = [NSScanner scannerWithString:[response substringWithRange:[matcher rangeAtIndex:3]]];
            if (![scanner scanInt:&num] || num < CODELESS_COMMAND_DLE_PACKET_LENGTH_MIN || num > CODELESS_COMMAND_DLE_PACKET_LENGTH_MAX) {
                self.invalid = true;
                CodelessLog(TAG, "%@", errorMsg);
                return;
            }
            _rxPacketLength = num;
            CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "DLE: %@ tx=%d rx=%d", (self.enabled ? @"enabled" : @"disabled"), self.txPacketLength, self.rxPacketLength);
        } else {
            self.invalid = true;
            CodelessLog(TAG, "%@", errorMsg);
        }
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid)
        [self sendEvent:CodelessLibEvent.DataLengthEnable object:[[CodelessDataLengthEnableEvent alloc] initWithCommand:self]];
}

- (BOOL) checkArgumentsCount {
    int count = [CodelessProfile countArguments:self.command split:@","];
    return count == 0 || count == 3;
}

- (NSString*) parseArguments {
    if (![CodelessProfile hasArguments:self.command])
        return nil;
    self.hasArguments = true;

    NSNumber* num = [self decodeNumberArgument:1];
    int value = num.intValue;
    if (!num || value != CODELESS_COMMAND_DLE_DISABLED && value != CODELESS_COMMAND_DLE_ENABLED)
        return @"Enable must be 0 or 1";
    _enabled = value != CODELESS_COMMAND_DLE_DISABLED;

    num = [self decodeNumberArgument:2];
    value = num.intValue;
    if (!num || value < CODELESS_COMMAND_DLE_PACKET_LENGTH_MIN || value > CODELESS_COMMAND_DLE_PACKET_LENGTH_MAX)
        return @"Invalid TX packet length";
    _txPacketLength = value;

    num = [self decodeNumberArgument:3];
    value = num.intValue;
    if (!num || value < CODELESS_COMMAND_DLE_PACKET_LENGTH_MIN || value > CODELESS_COMMAND_DLE_PACKET_LENGTH_MAX)
        return @"Invalid RX packet length";
    _rxPacketLength = value;

    return nil;
}

/// Sets the DLE TX packet length argument.
- (void) setTxPacketLength:(int)txPacketLength {
    _txPacketLength = txPacketLength;
    if (txPacketLength < CODELESS_COMMAND_DLE_PACKET_LENGTH_MIN || txPacketLength > CODELESS_COMMAND_DLE_PACKET_LENGTH_MAX)
        self.invalid = true;
}

/// Sets the DLE RX packet length argument.
- (void) setRxPacketLength:(int)rxPacketLength {
    _rxPacketLength = rxPacketLength;
    if (rxPacketLength < CODELESS_COMMAND_DLE_PACKET_LENGTH_MIN || rxPacketLength > CODELESS_COMMAND_DLE_PACKET_LENGTH_MAX)
        self.invalid = true;
}

@end
