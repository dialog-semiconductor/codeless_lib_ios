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

#import "CodelessPowerLevelConfigCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@interface CodelessPowerLevelConfigCommand ()

@property BOOL notSupported;
/// <code>true</code> if the command has arguments, <code>false</code> for no arguments.
@property BOOL hasArguments;

@end

@implementation CodelessPowerLevelConfigCommand

static NSString* const TAG = @"PowerLevelConfigCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"PWRLVL";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_PWRLVL;

static NSString* PATTERN_STRING = @"^PWRLVL(?:=(\\d+))?$"; // <level>
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessPowerLevelConfigCommand.class)
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

- (instancetype) initWithManager:(CodelessManager*)manager powerLevel:(int)powerLevel {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.powerLevel = powerLevel;
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
    return self.hasArguments ? @(self.powerLevel).stringValue : nil;
}

- (BOOL) requiresArguments {
    return true;
}

- (BOOL) checkArgumentsCount {
    int count = [CodelessProfile countArguments:self.command split:@","] == 1;
    return count == 0 || count == 1;
}

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    if (self.responseLine == 1) {
        if (![response isEqualToString:CODELESS_COMMAND_OUTPUT_POWER_LEVEL_NOT_SUPPORTED]) {
            NSScanner* scanner = [NSScanner scannerWithString:response];
            int num;
            if ([scanner scanInt:&num]) {
                self.powerLevel = num;
            } else {
                self.invalid = true;
            }
            if (self.invalid)
                CodelessLog(TAG, "Received invalid power level: %@", response);
            else
                CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "Power level: %d", self.powerLevel);
        } else {
            CodelessLog(TAG, "Power level not supported");
            self.notSupported = true;
        }
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid)
        [self sendEvent:CodelessLibEvent.PowerLevel object:[[CodelessPowerLevelEvent alloc] initWithCommand:self]];
}

- (NSString*) parseArguments {
    if (![CodelessProfile hasArguments:self.command])
        return nil;
    self.hasArguments = true;

    NSNumber* num = [self decodeNumberArgument:1];
    int value = num.intValue;
    if (!num || ![self validPowerLevel:value])
        return @"Invalid power level";
    _powerLevel = value;

    return nil;
}

/// Sets the Bluetooth output power level {@link CodelessProfile#CODELESS_COMMAND_OUTPUT_POWER_LEVEL index} argument.
- (void) setPowerLevel:(int)powerLevel {
    _powerLevel = powerLevel;
    if (![self validPowerLevel:powerLevel])
        self.invalid = true;
}

/// Checks if a Bluetooth output power level index is valid.
- (BOOL) validPowerLevel:(int)powerLevel {
    return (powerLevel == CODELESS_COMMAND_OUTPUT_POWER_LEVEL_MINUS_19_POINT_5_DBM
            || powerLevel == CODELESS_COMMAND_OUTPUT_POWER_LEVEL_MINUS_13_POINT_5_DBM
            || powerLevel == CODELESS_COMMAND_OUTPUT_POWER_LEVEL_MINUS_10_DBM
            || powerLevel == CODELESS_COMMAND_OUTPUT_POWER_LEVEL_MINUS_7_DBM
            || powerLevel == CODELESS_COMMAND_OUTPUT_POWER_LEVEL_MINUS_5_DBM
            || powerLevel == CODELESS_COMMAND_OUTPUT_POWER_LEVEL_MINUS_3_POINT_5_DBM
            || powerLevel == CODELESS_COMMAND_OUTPUT_POWER_LEVEL_MINUS_2_DBM
            || powerLevel == CODELESS_COMMAND_OUTPUT_POWER_LEVEL_MINUS_1_DBM
            || powerLevel == CODELESS_COMMAND_OUTPUT_POWER_LEVEL_0_DBM
            || powerLevel == CODELESS_COMMAND_OUTPUT_POWER_LEVEL_1_DBM
            || powerLevel == CODELESS_COMMAND_OUTPUT_POWER_LEVEL_1_POINT_5_DBM
            || powerLevel == CODELESS_COMMAND_OUTPUT_POWER_LEVEL_2_POINT_5_DBM);
}

@end
