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

#import "CodelessSecurityModeCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@interface CodelessSecurityModeCommand ()

/// <code>true</code> if the command has arguments, <code>false</code> for no arguments.
@property BOOL hasArguments;

@end

@implementation CodelessSecurityModeCommand

static NSString* const TAG = @"SecurityModeCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"SEC";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_SEC;

static NSString* PATTERN_STRING = @"^SEC(?:=(\\d+))?$"; // <mode>
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessSecurityModeCommand.class)
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

- (instancetype) initWithManager:(CodelessManager*)manager mode:(int)mode {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.mode = mode;
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
    return self.hasArguments ? @(self.mode).stringValue : nil;
}

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    if (self.responseLine == 1) {
        NSScanner* scanner = [NSScanner scannerWithString:response];
        int num;
        if (![scanner scanInt:&num] || num != CODELESS_COMMAND_SECURITY_MODE_0 && num != CODELESS_COMMAND_SECURITY_MODE_1 && num != CODELESS_COMMAND_SECURITY_MODE_2 && num != CODELESS_COMMAND_SECURITY_MODE_3) {
            self.invalid = true;
            CodelessLog(TAG, "Received invalid security mode: %@", response);
            return;
        }
        _mode = num;
        CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "Security mode: %d", self.mode);
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid)
        [self sendEvent:CodelessLibEvent.SecurityMode object:[[CodelessSecurityModeEvent alloc] initWithCommand:self]];
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
    if (!num || value != CODELESS_COMMAND_SECURITY_MODE_0 && value != CODELESS_COMMAND_SECURITY_MODE_1 && value != CODELESS_COMMAND_SECURITY_MODE_2 && value != CODELESS_COMMAND_SECURITY_MODE_3)
        return @"Invalid security mode";
    _mode = value;

    return nil;
}

/// Sets the security {@link CodelessProfile#CODELESS_COMMAND_SECURITY_MODE mode} argument.
- (void) setMode:(int)mode {
    _mode = mode;
    if (mode != CODELESS_COMMAND_SECURITY_MODE_0 && mode != CODELESS_COMMAND_SECURITY_MODE_1 && mode != CODELESS_COMMAND_SECURITY_MODE_2 && mode != CODELESS_COMMAND_SECURITY_MODE_3)
        self.invalid = true;
}

@end
