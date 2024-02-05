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

#import "CodelessAdcReadCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibConfig.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@implementation CodelessAdcReadCommand

static NSString* const TAG = @"AdcReadCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"ADC";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_ADC;

static NSString* PATTERN_STRING = @"^ADC=(\\d+)$"; // <pin>
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessAdcReadCommand.class)
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

- (instancetype) initWithManager:(CodelessManager*)manager gpio:(CodelessGPIO*)gpio {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.gpio = gpio;
    return self;
}

- (instancetype) initWithManager:(CodelessManager*)manager port:(int)port pin:(int)pin {
    return [self initWithManager:manager gpio:[[CodelessGPIO alloc] initWithPort:port pin:pin]];
}

- (instancetype) initWithManager:(CodelessManager*)manager command:(NSString*)command parse:(BOOL)parse {
    self = [super initWithManager:manager command:command parse:parse];
    if (!self)
        return nil;
    if (!self.gpio)
        _gpio = [[CodelessGPIO alloc] init];
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
    return @([self.gpio getGpio]).stringValue;
}

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    if (self.responseLine == 1) {
        NSScanner* scanner = [NSScanner scannerWithString:response];
        int num;
        if (![scanner scanInt:&num]) {
            CodelessLog(TAG, "Received invalid ADC result: %@", response);
            self.invalid = true;
            return;
        }
        self.gpio.state = num;
        CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "ADC: %@ %d", self.gpio.name, self.gpio.state);
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid)
        [self sendEvent:CodelessLibEvent.AnalogRead object:[[CodelessAnalogReadEvent alloc] initWithCommand:self]];
}

- (BOOL) requiresArguments {
    return true;
}

- (BOOL) checkArgumentsCount {
    return [CodelessProfile countArguments:self.command split:@","] == 1;
}

- (NSString*) parseArguments {
    _gpio = [[CodelessGPIO alloc] init];
    NSNumber* num = [self decodeNumberArgument:1];
    int value = num.intValue;
    if (!num || CodelessLibConfig.CHECK_ANALOG_INPUT_GPIO && ![CodelessLibConfig.ANALOG_INPUT_GPIO containsObject:[[CodelessGPIO alloc] initWithPack:value]])
        return @"Invalid ADC GPIO";
    [self.gpio setGpio:value];
    return nil;
}

- (void) setGpio:(CodelessGPIO*)gpio {
    _gpio = gpio;
    self.gpio.state = CODELESS_GPIO_INVALID;
    if (CodelessLibConfig.CHECK_ANALOG_INPUT_GPIO && ![CodelessLibConfig.ANALOG_INPUT_GPIO containsObject:gpio])
        self.invalid = true;
}

- (int) getState {
    return self.gpio.state;
}

@end
