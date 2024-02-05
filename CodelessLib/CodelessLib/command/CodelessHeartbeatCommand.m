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

#import "CodelessHeartbeatCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@interface CodelessHeartbeatCommand ()

/// <code>true</code> if the command has arguments, <code>false</code> for no arguments.
@property BOOL hasArguments;

@end

@implementation CodelessHeartbeatCommand

static NSString* const TAG = @"HeartbeatCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"HRTBT";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_HRTBT;

static NSString* PATTERN_STRING = @"^HRTBT(?:=(\\d))?$"; // <heartbeat>
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessHeartbeatCommand.class)
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

- (instancetype) initWithManager:(CodelessManager*)manager enabled:(BOOL)enabled {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.enabled = enabled;
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
    return self.hasArguments ? (self.enabled ? @(CODELESS_COMMAND_HEARTBEAT_ENABLED).stringValue : @(CODELESS_COMMAND_HEARTBEAT_DISABLED).stringValue) : nil;
}

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    if (self.responseLine == 1) {
        NSScanner* scanner = [NSScanner scannerWithString:response];
        int num;
        if (![scanner scanInt:&num] || num != CODELESS_COMMAND_HEARTBEAT_ENABLED && num != CODELESS_COMMAND_HEARTBEAT_DISABLED) {
            self.invalid = true;
            CodelessLog(TAG, "Received invalid heartbeat state: %@", response);
            return;
        }
        self.enabled = num != CODELESS_COMMAND_HEARTBEAT_DISABLED;
        CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "Heartbeat state: %@", (self.enabled ? @"enabled" : @"disabled"));
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid)
        [self sendEvent:CodelessLibEvent.Heartbeat object:[[CodelessHeartbeatEvent alloc] initWithCommand:self]];
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
    if (!num || value != CODELESS_COMMAND_HEARTBEAT_ENABLED && value != CODELESS_COMMAND_HEARTBEAT_DISABLED)
        return @"Invalid heartbeat state";
    self.enabled = value != CODELESS_COMMAND_HEARTBEAT_DISABLED;

    return nil;
}

@end
