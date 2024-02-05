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

#import "CodelessFlowControlCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@interface CodelessFlowControlCommand ()

/// <code>true</code> if the command has arguments, <code>false</code> for no arguments.
@property BOOL hasArguments;

@end

@implementation CodelessFlowControlCommand

static NSString* const TAG = @"FlowControlCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"FLOWCONTROL";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_FLOWCONTROL;

static NSString* PATTERN_STRING = @"^FLOWCONTROL(?:=(\\d),(\\d+),(\\d+))?$"; // <fc_mode> <rts_pin> <cts_pin>
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessFlowControlCommand.class)
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

- (instancetype) initWithManager:(CodelessManager*)manager enabled:(BOOL)enabled rtsGpio:(CodelessGPIO*)rtsGpio ctsGpio:(CodelessGPIO*)ctsGpio {
    return [self initWithManager:manager mode:enabled ? CODELESS_COMMAND_ENABLE_UART_FLOW_CONTROL : CODELESS_COMMAND_DISABLE_UART_FLOW_CONTROL rtsGpio:rtsGpio ctsGpio:ctsGpio];
}

- (instancetype) initWithManager:(CodelessManager*)manager mode:(int)mode rtsGpio:(CodelessGPIO*)rtsGpio ctsGpio:(CodelessGPIO*)ctsGpio {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.mode = mode;
    self.rtsGpio = rtsGpio;
    self.ctsGpio = ctsGpio;
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
    return self.hasArguments ? [NSString stringWithFormat:@"%d,%d,%d", self.mode, [self.rtsGpio getGpio], [self.ctsGpio getGpio]] : nil;
}

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    if (self.responseLine == 1) {
        NSString* errorMsg = [NSString stringWithFormat:@"Received invalid flow control response: %@", response];
        NSArray<NSString*>* values = [response componentsSeparatedByString:@" "];
        if (values.count != 3) {
            self.invalid = true;
            CodelessLog(TAG, "%@", errorMsg);
            return;
        }

        NSScanner* scanner = [NSScanner scannerWithString:values[0]];
        int num;
        if (![scanner scanInt:&num] || num != CODELESS_COMMAND_DISABLE_UART_FLOW_CONTROL && num != CODELESS_COMMAND_ENABLE_UART_FLOW_CONTROL) {
            self.invalid = true;
            CodelessLog(TAG, "%@", errorMsg);
            return;
        }
        _mode = num;

        scanner = [NSScanner scannerWithString:values[1]];
        if (![scanner scanInt:&num]) {
            self.invalid = true;
            CodelessLog(TAG, "%@", errorMsg);
            return;
        }
        _rtsGpio = [[CodelessGPIO alloc] initWithPack:num];
        self.rtsGpio.function = CODELESS_COMMAND_GPIO_FUNCTION_UART_RTS;

        scanner = [NSScanner scannerWithString:values[2]];
        if (![scanner scanInt:&num]) {
            self.invalid = true;
            CodelessLog(TAG, "%@", errorMsg);
            return;
        }
        _ctsGpio = [[CodelessGPIO alloc] initWithPack:num];
        self.ctsGpio.function = CODELESS_COMMAND_GPIO_FUNCTION_UART_CTS;
        CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "Flow control: %@ RTS=%@ CTS=%@", self.mode == CODELESS_COMMAND_ENABLE_UART_FLOW_CONTROL ? @"Enabled" : @"Disabled", self.rtsGpio.name, self.ctsGpio.name);
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid)
        [self sendEvent:CodelessLibEvent.FlowControl object:[[CodelessFlowControlEvent alloc] initWithCommand:self]];
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
    if (!num || value != CODELESS_COMMAND_DISABLE_UART_FLOW_CONTROL && value != CODELESS_COMMAND_ENABLE_UART_FLOW_CONTROL)
        return @"Invalid mode";
    _mode = value;

    num = [self decodeNumberArgument:2];
    if (!num)
        return @"Invalid RTS GPIO";
    _rtsGpio = [[CodelessGPIO alloc] initWithPack:num.intValue];
    self.rtsGpio.function = CODELESS_COMMAND_GPIO_FUNCTION_UART_RTS;

    num = [self decodeNumberArgument:3];
    if (!num)
        return @"Invalid CTS GPIO";
    _ctsGpio = [[CodelessGPIO alloc] initWithPack:num.intValue];
    self.ctsGpio.function = CODELESS_COMMAND_GPIO_FUNCTION_UART_CTS;

    return nil;
}

/// Sets the flow control mode argument.
- (void) setMode:(int)mode {
    _mode = mode;
    if (mode != CODELESS_COMMAND_DISABLE_UART_FLOW_CONTROL && mode != CODELESS_COMMAND_ENABLE_UART_FLOW_CONTROL)
        self.invalid = true;
}

- (BOOL) isEnabled {
    return self.mode != CODELESS_COMMAND_DISABLE_UART_FLOW_CONTROL;
}

- (void) setEnabled:(BOOL)enabled {
    _mode = enabled ? CODELESS_COMMAND_ENABLE_UART_FLOW_CONTROL : CODELESS_COMMAND_DISABLE_UART_FLOW_CONTROL;
}

/// Sets the RTS pin argument.
- (void) setRtsGpio:(CodelessGPIO*)rtsGpio {
    _rtsGpio = rtsGpio;
    if (self.rtsGpio.function != CODELESS_COMMAND_GPIO_FUNCTION_UART_RTS)
        self.invalid = true;
}

/// Sets the CTS pin argument.
- (void) setCtsGpio:(CodelessGPIO*)ctsGpio {
    _ctsGpio = ctsGpio;
    if (self.ctsGpio.function != CODELESS_COMMAND_GPIO_FUNCTION_UART_CTS)
        self.invalid = true;
}

@end
