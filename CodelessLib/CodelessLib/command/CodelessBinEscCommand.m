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

#import "CodelessBinEscCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@interface CodelessBinEscCommand ()

/// <code>true</code> if the command has arguments, <code>false</code> for no arguments.
@property BOOL hasArguments;

@end

@implementation CodelessBinEscCommand

static NSString* const TAG = @"BinEscCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"BINESC";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_BINESC;

static NSString* PATTERN_STRING = @"^BINESC(?:=(\\d+),(0[xX][0-9a-fA-F]{1,6}|\\d+),(\\d+))?$"; // <time_prior> <seq> <time_after>
static NSRegularExpression* PATTERN;

static NSString* RESPONSE_PATTERN_STRING = @"^(\\d+).([0-9a-fA-F]{1,6}).(\\d+)$"; // <time_prior> <seq> <time_after>
static NSRegularExpression* RESPONSE_PATTERN;

+ (void) initialize {
    if (self != CodelessBinEscCommand.class)
        return;

    NAME = [CodelessProfile.PREFIX_LOCAL stringByAppendingString:COMMAND];

    NSError* error = nil;
    PATTERN = [NSRegularExpression regularExpressionWithPattern:PATTERN_STRING options:0 error:&error];
    RESPONSE_PATTERN = [NSRegularExpression regularExpressionWithPattern:RESPONSE_PATTERN_STRING options:0 error:&error];
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

- (instancetype) initWithManager:(CodelessManager*)manager sequence:(uint32_t)sequence timePrior:(uint16_t)timePrior timeAfter:(uint16_t)timeAfter {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.sequence = sequence;
    self.timePrior = timePrior;
    self.timeAfter = timeAfter;
    self.hasArguments = true;
    return self;
}

- (instancetype) initWithManager:(CodelessManager*)manager sequence:(uint32_t)sequence {
    return [self initWithManager:manager sequence:sequence timePrior:CODELESS_COMMAND_BINESC_TIME_PRIOR_DEFAULT timeAfter:CODELESS_COMMAND_BINESC_TIME_AFTER_DEFAULT];
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
    return self.hasArguments ? [NSString stringWithFormat:@"%d,%#x,%d", self.timePrior, self.sequence, self.timeAfter] : nil;
}

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    if (self.responseLine == 1) {
        NSTextCheckingResult* matcher = [RESPONSE_PATTERN firstMatchInString:response options:0 range:NSMakeRange(0, response.length)];
        if (matcher) {
            NSScanner* scanner = [NSScanner scannerWithString:[response substringWithRange:[matcher rangeAtIndex:1]]];
            int num;
            if (![scanner scanInt:&num] || num > 0xffff) {
                self.invalid = true;
            } else {
                _timePrior = num;
            }

            scanner = [NSScanner scannerWithString:[response substringWithRange:[matcher rangeAtIndex:2]]];
            uint hexNum;
            if (![scanner scanHexInt:&hexNum] || hexNum > 0xffffff) {
                self.invalid = true;
            } else {
                _sequence = hexNum;
            }

            scanner = [NSScanner scannerWithString:[response substringWithRange:[matcher rangeAtIndex:3]]];
            if (![scanner scanInt:&num] || num > 0xffff) {
                self.invalid = true;
            } else {
                _timeAfter = num;
            }
        } else {
            self.invalid = true;
        }
        if (self.invalid)
            CodelessLog(TAG, @"Received invalid escape parameters: %@", response);
        else
            CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "Escape sequence: %#x (\"%@\") time=%d,%d", self.sequence, [self getSequenceString], self.timePrior, self.timeAfter);
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid)
        [self sendEvent:CodelessLibEvent.BinEsc object:[[CodelessBinEscEvent alloc] initWithCommand:self]];
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
    uint32_t value = num.unsignedShortValue;
    if (!num || value > 0xffff)
        return @"Invalid escape time prior";
    _timePrior = value;

    num = [self decodeNumberArgument:2];
    value = num.unsignedIntValue;
    if (!num || value > 0xffffff)
        return @"Invalid escape sequence";
    _sequence = value;

    num = [self decodeNumberArgument:3];
    value = num.unsignedShortValue;
    if (!num || value > 0xffff)
        return @"Invalid escape time after";
    _timeAfter = value;

    return nil;
}

/// Returns the escape sequence argument/response as text.
- (NSString*) getSequenceString {
    int length = self.sequence > 0xffff ? 3 : self.sequence > 0xff ? 2 : 1;
    NSData* sequenceBytes = [NSData dataWithBytes:&_sequence length:length];
    return [[NSString alloc] initWithData:sequenceBytes encoding:NSASCIIStringEncoding];
}

/// Sets the 3-byte escape sequence argument (24-bit).
- (void) setSequence:(uint32_t)sequence {
    _sequence = sequence & 0xffffff;
}

@end
