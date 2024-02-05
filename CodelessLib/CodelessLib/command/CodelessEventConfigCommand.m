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

#import "CodelessEventConfigCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@interface CodelessEventConfigCommand ()

/// <code>true</code> if the command has arguments, <code>false</code> for no arguments.
@property BOOL hasArguments;

@end

@implementation CodelessEventConfigCommand

static NSString* const TAG = @"EventConfigCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"EVENT";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_EVENT;

static NSString* PATTERN_STRING = @"^EVENT(?:=(\\d+),(\\d))?$"; // <event> <status>
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessEventConfigCommand.class)
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

- (instancetype) initWithManager:(CodelessManager*)manager eventType:(int)eventType status:(BOOL)status {
    return [self initWithManager:manager eventConfig:[[CodelessEventConfig alloc] initWithType:eventType status:status]];
}

- (instancetype) initWithManager:(CodelessManager*)manager eventConfig:(CodelessEventConfig*)eventConfig {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.eventConfig = eventConfig;
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
    return self.hasArguments ? [NSString stringWithFormat:@"%d,%d", self.eventConfig.type, self.eventConfig.status ? CODELESS_COMMAND_ACTIVATE_EVENT : CODELESS_COMMAND_DEACTIVATE_EVENT] : nil;
}

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    if (!self.eventStatusTable)
        self.eventStatusTable = [NSMutableArray array];
    NSString* errorMsg = [NSString stringWithFormat:@"Received invalid Event status response: %@", response];
    CodelessEventConfig* eventConfig = [[CodelessEventConfig alloc] init];
    NSArray<NSString*>* eventData = [response componentsSeparatedByString:@","];
    if (eventData.count != 2) {
        self.invalid = true;
        CodelessLog(TAG, "%@", errorMsg);
        return;
    }

    NSScanner* scanner = [NSScanner scannerWithString:eventData[0]];
    int num;
    if (![scanner scanInt:&num] || num != CODELESS_COMMAND_INITIALIZATION_EVENT && num != CODELESS_COMMAND_CONNECTION_EVENT && num != CODELESS_COMMAND_DISCONNECTION_EVENT && num != CODELESS_COMMAND_WAKEUP_EVENT) {
        self.invalid = true;
        CodelessLog(TAG, "%@", errorMsg);
        return;
    }
    eventConfig.type = num;

    scanner = [NSScanner scannerWithString:eventData[1]];
    if (![scanner scanInt:&num] || num != CODELESS_COMMAND_DEACTIVATE_EVENT && num != CODELESS_COMMAND_ACTIVATE_EVENT) {
        self.invalid = true;
        CodelessLog(TAG, "%@", errorMsg);
        return;
    }
    eventConfig.status = num == CODELESS_COMMAND_ACTIVATE_EVENT;
    [self.eventStatusTable addObject:eventConfig];
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid) {
        if (self.hasArguments)
            [self sendEvent:CodelessLibEvent.EventStatus object:[[CodelessEventStatusEvent alloc] initWithCommand:self]];
        else
            [self sendEvent:CodelessLibEvent.EventStatusTable object:[[CodelessEventStatusTableEvent alloc] initWithCommand:self]];
    }
}

- (BOOL) checkArgumentsCount {
    int count = [CodelessProfile countArguments:self.command split:@","];
    return count == 0 || count == 2;
}

- (NSString*) parseArguments {
    _eventConfig = [[CodelessEventConfig alloc] init];

    if (![CodelessProfile hasArguments:self.command])
        return nil;
    self.hasArguments = true;

    NSNumber* num = [self decodeNumberArgument:1];
    int value = num.intValue;
    if (!num || value != CODELESS_COMMAND_INITIALIZATION_EVENT && value != CODELESS_COMMAND_CONNECTION_EVENT && value != CODELESS_COMMAND_DISCONNECTION_EVENT && value != CODELESS_COMMAND_WAKEUP_EVENT)
        return @"Invalid event number";
    self.eventConfig.type = value;

    num = [self decodeNumberArgument:2];
    value = num.intValue;
    if (!num || value != CODELESS_COMMAND_DEACTIVATE_EVENT && value != CODELESS_COMMAND_ACTIVATE_EVENT)
        return @"Invalid event status";
    self.eventConfig.status = value == CODELESS_COMMAND_ACTIVATE_EVENT;

    return nil;
}

/// Sets the predefined event configuration argument.
- (void) setEventConfig:(CodelessEventConfig*)eventConfig {
    _eventConfig = eventConfig;
    if (eventConfig.type != CODELESS_COMMAND_INITIALIZATION_EVENT && eventConfig.type != CODELESS_COMMAND_CONNECTION_EVENT && eventConfig.type != CODELESS_COMMAND_DISCONNECTION_EVENT && eventConfig.type != CODELESS_COMMAND_WAKEUP_EVENT)
        self.invalid = true;
}

/// Sets the predefined event type argument.
- (void) setType:(int)type {
    self.eventConfig.type = type;
    if (type != CODELESS_COMMAND_INITIALIZATION_EVENT && type != CODELESS_COMMAND_CONNECTION_EVENT && type != CODELESS_COMMAND_DISCONNECTION_EVENT && type != CODELESS_COMMAND_WAKEUP_EVENT)
        self.invalid = true;
}

@end
