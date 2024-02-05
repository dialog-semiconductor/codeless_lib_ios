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

#import "CodelessSpiConfigCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibConfig.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@interface CodelessSpiConfigCommand ()

/// <code>true</code> if the command has arguments, <code>false</code> for no arguments.
@property BOOL hasArguments;

@end

@implementation CodelessSpiConfigCommand

static NSString* const TAG = @"SpiConfigCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"SPICFG";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_SPICFG;

static NSString* PATTERN_STRING = @"^SPICFG(?:=(\\d+),(\\d+),(\\d+))?$"; // <speed> <mode> <size>
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessSpiConfigCommand.class)
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

- (instancetype) initWithManager:(CodelessManager*)manager speed:(int)speed mode:(int)mode size:(int)size {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.speed = speed;
    self.mode = mode;
    self.size = size;
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
    return self.hasArguments ? [NSString stringWithFormat:@"%d,%d,%d", self.speed, self.mode, self.size] : nil;
}

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    if (self.responseLine == 1) {
        NSString* errorMsg = [NSString stringWithFormat:@"Received invalid SPI configuration: %@", response];
        NSScanner* scanner = [NSScanner scannerWithString:[response substringWithRange:[self.matcher rangeAtIndex:1]]];
        int num;
        if (![scanner scanInt:&num] || num != CODELESS_COMMAND_SPI_CLOCK_VALUE_2_MHZ && num != CODELESS_COMMAND_SPI_CLOCK_VALUE_4_MHZ && num != CODELESS_COMMAND_SPI_CLOCK_VALUE_8_MHZ) {
            self.invalid = true;
            CodelessLog(TAG, "%@", errorMsg);
            return;
        }
        _speed = num;

        scanner = [NSScanner scannerWithString:[response substringWithRange:[self.matcher rangeAtIndex:2]]];
        if (![scanner scanInt:&num] || num != CODELESS_COMMAND_SPI_MODE_0 && num != CODELESS_COMMAND_SPI_MODE_1 && num != CODELESS_COMMAND_SPI_MODE_2 && num != CODELESS_COMMAND_SPI_MODE_3) {
            self.invalid = true;
            CodelessLog(TAG, "%@", errorMsg);
            return;
        }
        _mode = num;

        scanner = [NSScanner scannerWithString:[response substringWithRange:[self.matcher rangeAtIndex:3]]];
        if (![scanner scanInt:&num] || CodelessLibConfig.CHECK_SPI_WORD_SIZE && num != CodelessLibConfig.SPI_WORD_SIZE) {
            self.invalid = true;
            CodelessLog(TAG, "%@", errorMsg);
            return;
        }
        _size = num;
        CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "SPI configuration: speed=%d mode=%d size=%d", self.speed, self.mode, self.size);
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid)
        [self sendEvent:CodelessLibEvent.SpiConfig object:[[CodelessSpiConfigEvent alloc] initWithCommand:self]];
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
    if (!num || value != CODELESS_COMMAND_SPI_CLOCK_VALUE_2_MHZ && value != CODELESS_COMMAND_SPI_CLOCK_VALUE_4_MHZ && value != CODELESS_COMMAND_SPI_CLOCK_VALUE_8_MHZ)
        return @"Invalid SPI clock value";
    _speed = value;

    num = [self decodeNumberArgument:2];
    value = num.intValue;
    if (!num || value != CODELESS_COMMAND_SPI_MODE_0 && value != CODELESS_COMMAND_SPI_MODE_1 && value != CODELESS_COMMAND_SPI_MODE_2 && value != CODELESS_COMMAND_SPI_MODE_3)
        return @"Invalid SPI mode";
    _mode = value;

    num = [self decodeNumberArgument:3];
    value = num.intValue;
    if (!num || CodelessLibConfig.CHECK_SPI_WORD_SIZE && value != CodelessLibConfig.SPI_WORD_SIZE)
        return @"Invalid SPI word size";
    _size = value;

    return nil;
}

/// Sets the SPI clock value argument (0: 2 MHz, 1: 4 MHz, 2: 8 MHz).
- (void) setSpeed:(int)speed {
    _speed = speed;
    if (speed != CODELESS_COMMAND_SPI_CLOCK_VALUE_2_MHZ && speed != CODELESS_COMMAND_SPI_CLOCK_VALUE_4_MHZ && speed != CODELESS_COMMAND_SPI_CLOCK_VALUE_8_MHZ)
        self.invalid = true;
}

/// Sets the SPI mode argument (clock polarity and phase).
- (void) setMode:(int)mode {
    _mode = mode;
    if (mode != CODELESS_COMMAND_SPI_MODE_0 && mode != CODELESS_COMMAND_SPI_MODE_1 && mode != CODELESS_COMMAND_SPI_MODE_2 && mode != CODELESS_COMMAND_SPI_MODE_3)
        self.invalid = true;
}

/// Sets the SPI word bit-count argument.
- (void) setSize:(int)size {
    _size = size;
    if (size != CodelessLibConfig.CHECK_SPI_WORD_SIZE && size != CodelessLibConfig.SPI_WORD_SIZE)
        self.invalid = true;
}

@end
