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

#import "CodelessTimerStartCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibConfig.h"

@implementation CodelessTimerStartCommand

static NSString* const TAG = @"TimerStartCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"TMRSTART";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_TMRSTART;

static NSString* PATTERN_STRING = @"^TMRSTART=(\\d+),(\\d+),(\\d+)$"; // <timer> <command> <delay>
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessTimerStartCommand.class)
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

- (instancetype) initWithManager:(CodelessManager*)manager timerIndex:(int)timerIndex commandIndex:(int)commandIndex delay:(int)delay {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.timerIndex = timerIndex;
    self.commandIndex = commandIndex;
    self.delay = delay;
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

- (BOOL) hasArguments {
    return true;
}

- (NSString*) getArguments {
    return [NSString stringWithFormat:@"%d,%d,%d", self.timerIndex, self.commandIndex, self.delay];
}

- (BOOL) requiresArguments {
    return true;
}

- (BOOL) checkArgumentsCount {
    return [CodelessProfile countArguments:self.command split:@","] == 3;
}

- (NSString*) parseArguments {
    NSNumber* num = [self decodeNumberArgument:1];
    int value = num.intValue;
    if (!num || CodelessLibConfig.CHECK_TIMER_INDEX && (value < CodelessLibConfig.TIMER_INDEX_MIN || value > CodelessLibConfig.TIMER_INDEX_MAX))
        return @"Invalid timer index";
    _timerIndex = value;

    num = [self decodeNumberArgument:2];
    value = num.intValue;
    if (!num  || CodelessLibConfig.CHECK_COMMAND_INDEX && (value < CodelessLibConfig.COMMAND_INDEX_MIN || value > CodelessLibConfig.COMMAND_INDEX_MAX))
        return @"Invalid command index";
    _commandIndex = value;

    num = [self decodeNumberArgument:3];
    if (!num)
        return @"Invalid delay";
    _delay = num.intValue;

    return nil;
}

/// Sets the timer index argument (0-3).
- (void) setTimerIndex:(int)timerIndex {
    _timerIndex = timerIndex;
    if (CodelessLibConfig.CHECK_TIMER_INDEX) {
        if (timerIndex < CodelessLibConfig.TIMER_INDEX_MIN || timerIndex > CodelessLibConfig.TIMER_INDEX_MAX)
            self.invalid = true;
    }
}

/// Sets the command slot index argument (0-3).
- (void) setCommandIndex:(int)commandIndex {
    _commandIndex = commandIndex;
    if (CodelessLibConfig.CHECK_COMMAND_INDEX) {
        if (commandIndex < CodelessLibConfig.COMMAND_INDEX_MIN || commandIndex > CodelessLibConfig.COMMAND_INDEX_MAX)
            self.invalid = true;
    }
}

- (int) calculatedDelay {
    return self.delay * 10;
}

- (void) setDelay:(int)delay {
    _delay = delay / 10;
    if (delay % 10 != 0)
        _delay++;
}

@end
