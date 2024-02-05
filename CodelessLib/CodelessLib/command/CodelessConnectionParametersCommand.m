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

#import "CodelessConnectionParametersCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@interface CodelessConnectionParametersCommand ()

/// <code>true</code> if the command has arguments, <code>false</code> for no arguments.
@property BOOL hasArguments;

@end

@implementation CodelessConnectionParametersCommand

static NSString* const TAG = @"ConnectionParametersCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"CONPAR";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_CONPAR;

static NSString* PATTERN_STRING = @"^CONPAR(?:=(\\d+),(\\d+),(\\d+),(\\d+))?$"; // <interval> <latency> <timeout> <action>
static NSRegularExpression* PATTERN;

static NSString* RESPONSE_PATTERN_STRING = @"^(\\d+).(\\d+).(\\d+).(\\d+)$"; // <interval> <latency> <timeout> <action>
static NSRegularExpression* RESPONSE_PATTERN;

+ (void) initialize {
    if (self != CodelessConnectionParametersCommand.class)
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

- (instancetype) initWithManager:(CodelessManager*)manager interval:(int)interval latency:(int)latency timeout:(int)timeout action:(int)action {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.interval = interval;
    self.latency = latency;
    self.timeout = timeout;
    self.action = action;
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
    return self.hasArguments ? [NSString stringWithFormat:@"%d,%d,%d,%d", self.interval, self.latency, self.timeout, self.action] : nil;
}

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    if (self.responseLine == 1) {
        NSString* errorMsg = [NSString stringWithFormat:@"Received invalid connection parameters: %@", response];
        NSTextCheckingResult* matcher = [RESPONSE_PATTERN firstMatchInString:response options:0 range:NSMakeRange(0, response.length)];
        if (matcher) {
            NSScanner* scanner = [NSScanner scannerWithString:[response substringWithRange:[matcher rangeAtIndex:1]]];
            int num;
            if (![scanner scanInt:&num] || num < CODELESS_COMMAND_CONNECTION_INTERVAL_MIN || num > CODELESS_COMMAND_CONNECTION_INTERVAL_MAX) {
                self.invalid = true;
                CodelessLog(TAG, "%@", errorMsg);
                return;
            }
            _interval = num;

            scanner = [NSScanner scannerWithString:[response substringWithRange:[matcher rangeAtIndex:2]]];
            if (![scanner scanInt:&num] || num < CODELESS_COMMAND_SLAVE_LATENCY_MIN || num > CODELESS_COMMAND_SLAVE_LATENCY_MAX) {
                self.invalid = true;
                CodelessLog(TAG, "%@", errorMsg);
                return;
            }
            _latency = num;

            scanner = [NSScanner scannerWithString:[response substringWithRange:[matcher rangeAtIndex:3]]];
            if (![scanner scanInt:&num] || num < CODELESS_COMMAND_SUPERVISION_TIMEOUT_MIN || num > CODELESS_COMMAND_SUPERVISION_TIMEOUT_MAX) {
                self.invalid = true;
                CodelessLog(TAG, "%@", errorMsg);
                return;
            }
            _timeout = num;

            scanner = [NSScanner scannerWithString:[response substringWithRange:[matcher rangeAtIndex:4]]];
            if (![scanner scanInt:&num] || num < CODELESS_COMMAND_PARAMETER_UPDATE_ACTION_MIN || num > CODELESS_COMMAND_PARAMETER_UPDATE_ACTION_MAX) {
                self.invalid = true;
                CodelessLog(TAG, "%@", errorMsg);
                return;
            }
            _action = num;
            CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "Connection parameters: ci=%d sl=%d st=%d a=%d", self.interval, self.latency, self.timeout, self.action);
        } else {
            self.invalid = true;
            CodelessLog(TAG, "%@", errorMsg);
        }
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid)
        [self sendEvent:CodelessLibEvent.ConnectionParameters object:[[CodelessConnectionParametersEvent alloc] initWithCommand:self]];
}

- (BOOL) checkArgumentsCount {
    int count = [CodelessProfile countArguments:self.command split:@","];
    return count == 0 || count == 4;
}

- (NSString*) parseArguments {
    if (![CodelessProfile hasArguments:self.command])
        return nil;
    self.hasArguments = true;

    NSNumber* num = [self decodeNumberArgument:1];
    int value = num.intValue;
    if (!num || value < CODELESS_COMMAND_CONNECTION_INTERVAL_MIN || value > CODELESS_COMMAND_CONNECTION_INTERVAL_MAX)
        return @"Invalid connection interval";
    _interval = value;

    num = [self decodeNumberArgument:2];
    value = num.intValue;
    if (!num || value < CODELESS_COMMAND_SLAVE_LATENCY_MIN || value > CODELESS_COMMAND_SLAVE_LATENCY_MAX)
        return @"Invalid slave latency";
    _latency = value;

    num = [self decodeNumberArgument:3];
    value = num.intValue;
    if (!num || value < CODELESS_COMMAND_SUPERVISION_TIMEOUT_MIN || value > CODELESS_COMMAND_SUPERVISION_TIMEOUT_MAX)
        return @"Invalid supervision timeout";
    _timeout = value;

    num = [self decodeNumberArgument:4];
    value = num.intValue;
    if (!num || value < CODELESS_COMMAND_PARAMETER_UPDATE_ACTION_MIN || value > CODELESS_COMMAND_PARAMETER_UPDATE_ACTION_MAX)
        return @"Invalid parameter update action";
    _action = value;

    return nil;
}

/// Sets the connection interval argument (multiples of 1.25 ms).
- (void) setInterval:(int)interval {
    _interval = interval;
    if (interval < CODELESS_COMMAND_CONNECTION_INTERVAL_MIN || interval > CODELESS_COMMAND_CONNECTION_INTERVAL_MAX)
        self.invalid = true;
}

/// Sets the slave latency argument.
- (void) setLatency:(int)latency {
    _latency = latency;
    if (latency < CODELESS_COMMAND_SLAVE_LATENCY_MIN || latency > CODELESS_COMMAND_SLAVE_LATENCY_MAX)
        self.invalid = true;
}

/// Sets the supervision timeout argument (multiples of 10 ms).
- (void) setTimeout:(int)timeout {
    _timeout = timeout;
    if (timeout < CODELESS_COMMAND_SUPERVISION_TIMEOUT_MIN || timeout > CODELESS_COMMAND_SUPERVISION_TIMEOUT_MAX)
        self.invalid = true;
}

/// Sets the argument that specifies how the connection parameters are applied.
- (void) setAction:(int)action {
    _action = action;
    if (action < CODELESS_COMMAND_PARAMETER_UPDATE_ACTION_MIN || action > CODELESS_COMMAND_PARAMETER_UPDATE_ACTION_MAX)
        self.invalid = true;
}

@end
