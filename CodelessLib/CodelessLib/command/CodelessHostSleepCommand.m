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

#import "CodelessHostSleepCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@interface CodelessHostSleepCommand ()

/// <code>true</code> if the command has arguments, <code>false</code> for no arguments.
@property BOOL hasArguments;

@end

@implementation CodelessHostSleepCommand

static NSString* const TAG = @"HostSleepCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"HOSTSLP";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_HOSTSLP;

static NSString* PATTERN_STRING = @"^HOSTSLP(?:=(\\d+),(\\d+),(\\d+),(\\d+))?$"; // <hst_slp_mode> <wkup_byte> <wkup_retry_interval> <wkup_retry_times>
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessHostSleepCommand.class)
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

- (instancetype) initWithManager:(CodelessManager*)manager hostSleepMode:(int)hostSleepMode wakeupByte:(int)wakeupByte wakeupRetryInterval:(int)wakeupRetryInterval wakeupRetryTimes:(int)wakeupRetryTimes {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.hostSleepMode = hostSleepMode;
    self.wakeupByte = wakeupByte;
    self.wakeupRetryInterval = wakeupRetryInterval;
    self.wakeupRetryTimes = wakeupRetryTimes;
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
    return self.hasArguments ? [NSString stringWithFormat:@"%d,%d,%d,%d", self.hostSleepMode, self.wakeupByte, self.wakeupRetryInterval, self.wakeupRetryTimes] : nil;
}

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    if (self.responseLine == 1) {
        NSArray<NSString*>* parameters = [response componentsSeparatedByString:@" "];
        NSString* errorMsg = [NSString stringWithFormat:@"Received invalid host sleep response: %@", response];
        if (parameters.count != 4) {
            self.invalid = true;
            CodelessLog(TAG, "%@", errorMsg);
            return;
        }

        NSScanner* scanner = [NSScanner scannerWithString:parameters[0]];
        int num;
        if (![scanner scanInt:&num] || num != CODELESS_COMMAND_HOST_SLEEP_MODE_0 && num != CODELESS_COMMAND_HOST_SLEEP_MODE_1) {
            self.invalid = true;
            CodelessLog(TAG, "%@", errorMsg);
            return;
        }
        _hostSleepMode = num;

        scanner = [NSScanner scannerWithString:parameters[1]];
        if (![scanner scanInt:&num]) {
            self.invalid = true;
            CodelessLog(TAG, "%@", errorMsg);
            return;
        }
        _wakeupByte = num;

        scanner = [NSScanner scannerWithString:parameters[2]];
        if (![scanner scanInt:&num]) {
            self.invalid = true;
            CodelessLog(TAG, "%@", errorMsg);
            return;
        }
        _wakeupRetryInterval = num;

        scanner = [NSScanner scannerWithString:parameters[3]];
        if (![scanner scanInt:&num]) {
            self.invalid = true;
            CodelessLog(TAG, "%@", errorMsg);
            return;
        }
        _wakeupRetryTimes = num;

        CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "Host sleep mode:%d wakeup byte:%d wakeup retry interval:%d wakeup retry times:%d", self.hostSleepMode, self.wakeupByte, self.wakeupRetryInterval, self.wakeupRetryTimes);
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid)
        [self sendEvent:CodelessLibEvent.HostSleep object:[[CodelessHostSleepEvent alloc] initWithCommand:self]];
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
    if (!num || value != CODELESS_COMMAND_HOST_SLEEP_MODE_0 && value != CODELESS_COMMAND_HOST_SLEEP_MODE_1)
        return @"Invalid host sleep mode";
    _hostSleepMode = value;

    num = [self decodeNumberArgument:2];
    value = num.intValue;
    if (!num)
        return @"Invalid wakeup byte";
    self.wakeupByte = value;

    num = [self decodeNumberArgument:3];
    value = num.intValue;
    if (!num)
        return @"Invalid wakeup retry interval";
    self.wakeupRetryInterval = value;

    num = [self decodeNumberArgument:4];
    value = num.intValue;
    if (!num)
        return @"Invalid wakeup retry times";
    self.wakeupRetryTimes = value;

    return nil;
}

/// Sets the host sleep mode argument.
- (void) setHostSleepMode:(int)hostSleepMode {
    _hostSleepMode = hostSleepMode;
    if (hostSleepMode != CODELESS_COMMAND_HOST_SLEEP_MODE_0 && hostSleepMode != CODELESS_COMMAND_HOST_SLEEP_MODE_1)
        self.invalid = true;
}

@end
