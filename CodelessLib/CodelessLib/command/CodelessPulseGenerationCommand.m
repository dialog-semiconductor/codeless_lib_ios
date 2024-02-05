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

#import "CodelessPulseGenerationCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibConfig.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@interface CodelessPulseGenerationCommand ()

/// <code>true</code> if the command has arguments, <code>false</code> for no arguments.
@property BOOL hasArguments;

@end

@implementation CodelessPulseGenerationCommand

static NSString* const TAG = @"PulseGenerationCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"PWM";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_PWM;

static NSString* PATTERN_STRING = @"^PWM(?:=(\\d+),(\\d+),(\\d+))?$"; // <frequency> <cycle> <duration>
static NSRegularExpression* PATTERN;

static NSString* RESPONSE_PATTERN_STRING = @"^(\\d+).(\\d+).(\\d+)?$";
static NSRegularExpression* RESPONSE_PATTERN;

+ (void) initialize {
    if (self != CodelessPulseGenerationCommand.class)
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

- (instancetype) initWithManager:(CodelessManager*)manager frequency:(int)frequency dutyCycle:(int)dutyCycle duration:(int)duration {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.frequency = frequency;
    self.dutyCycle = dutyCycle;
    self.duration = duration;
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
    return self.hasArguments ? [NSString stringWithFormat:@"%d,%d,%d", self.frequency, self.dutyCycle, self.duration] : nil;
}

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    if (self.responseLine == 1) {
        NSString* errorMsg = [NSString stringWithFormat:@"Received invalid PWM parameters: %@", response];
        NSTextCheckingResult* matcher = [RESPONSE_PATTERN firstMatchInString:response options:0 range:NSMakeRange(0, response.length)];
        if (matcher) {
            NSScanner* scanner = [NSScanner scannerWithString:[response substringWithRange:[matcher rangeAtIndex:1]]];
            int num;
            if (![scanner scanInt:&num] || CodelessLibConfig.CHECK_PWM_FREQUENCY && (num < CodelessLibConfig.PWM_FREQUENCY_MIN || num > CodelessLibConfig.PWM_FREQUENCY_MAX)) {
                self.invalid = true;
                CodelessLog(TAG, "%@", errorMsg);
                return;
            }
            _frequency = num;

            scanner = [NSScanner scannerWithString:[response substringWithRange:[matcher rangeAtIndex:2]]];
            if (![scanner scanInt:&num] || CodelessLibConfig.CHECK_PWM_DUTY_CYCLE && (num < CodelessLibConfig.PWM_DUTY_CYCLE_MIN || num > CodelessLibConfig.PWM_DUTY_CYCLE_MAX)) {
                self.invalid = true;
                CodelessLog(TAG, "%@", errorMsg);
                return;
            }
            _dutyCycle = num;

            scanner = [NSScanner scannerWithString:[response substringWithRange:[matcher rangeAtIndex:3]]];
            if (![scanner scanInt:&num] || CodelessLibConfig.CHECK_PWM_DURATION && (num < CodelessLibConfig.PWM_DURATION_MIN || num > CodelessLibConfig.PWM_DURATION_MAX)) {
                self.invalid = true;
                CodelessLog(TAG, "%@", errorMsg);
                return;
            }
            _duration = num;
            CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "PWM parameters: frequency=%d dc=%d duration=%d", self.frequency, self.dutyCycle, self.duration);
        } else {
            self.invalid = true;
            CodelessLog(TAG, "%@", errorMsg);
        }
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid) {
        if (!self.hasArguments)
            [self sendEvent:CodelessLibEvent.PwmStatus object:[[CodelessPwmStatusEvent alloc] initWithCommand:self]];
        else
            [self sendEvent:CodelessLibEvent.PwmStart object:[[CodelessPwmStartEvent alloc] initWithCommand:self]];
    }
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
    if (!num || CodelessLibConfig.CHECK_PWM_FREQUENCY && (value < CodelessLibConfig.PWM_FREQUENCY_MIN || value > CodelessLibConfig.PWM_FREQUENCY_MAX))
        return @"Invalid pulse frequency";
    _frequency = value;

    num = [self decodeNumberArgument:2];
    value = num.intValue;
    if (!num || CodelessLibConfig.CHECK_PWM_DUTY_CYCLE && (value < CodelessLibConfig.PWM_DUTY_CYCLE_MIN || value > CodelessLibConfig.PWM_DUTY_CYCLE_MAX))
        return @"Invalid pulse duty cycle";
    _dutyCycle = value;

    num = [self decodeNumberArgument:3];
    value = num.intValue;
    if (!num || CodelessLibConfig.CHECK_PWM_DURATION && (value < CodelessLibConfig.PWM_DURATION_MIN || value > CodelessLibConfig.PWM_DURATION_MAX))
        return @"Invalid pulse duration";
    _duration = value;

    return nil;
}

/// Sets the frequency of the pulse argument (Hz).
- (void) setFrequency:(int)frequency {
    _frequency = frequency;
    if (CodelessLibConfig.CHECK_PWM_FREQUENCY) {
        if (frequency < CodelessLibConfig.PWM_FREQUENCY_MIN || frequency > CodelessLibConfig.PWM_FREQUENCY_MAX)
            self.invalid = true;
    }
}

/// Sets the duty cycle of the pulse argument.
- (void) setDutyCycle:(int)dutyCycle {
    _dutyCycle = dutyCycle;
    if (CodelessLibConfig.CHECK_PWM_DUTY_CYCLE) {
        if (dutyCycle < CodelessLibConfig.PWM_DUTY_CYCLE_MIN || dutyCycle > CodelessLibConfig.PWM_DUTY_CYCLE_MAX)
            self.invalid = true;
    }
}

/// Sets the duration of the pulse argument (ms).
- (void) setDuration:(int)duration {
    _duration = duration;
    if (CodelessLibConfig.CHECK_PWM_DURATION) {
        if (duration < CodelessLibConfig.PWM_DURATION_MIN || duration > CodelessLibConfig.PWM_DURATION_MAX)
            self.invalid = true;
    }
}

@end
