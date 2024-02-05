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

#import "CodelessCmdGetCommand.h"
#import "CodelessManager.h"
#import "CodelessProfile.h"
#import "CodelessLibConfig.h"
#import "CodelessLibEvent.h"

@implementation CodelessCmdGetCommand

static NSString* const TAG = @"CmdGetCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"CMD";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_CMD;

static NSString* PATTERN_STRING = @"^CMD=(\\d+)$"; // <index>
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessCmdGetCommand.class)
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

- (instancetype) init {
    self = [super init];
    if (!self)
        return nil;
    self.commands = [NSMutableArray array];
    return self;
}

- (instancetype) initWithManager:(CodelessManager*)manager index:(int)index {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.index = index;
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
    return @(self.index).stringValue;
}

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    if (self.responseLine == 1) {
        self.commandString = response;
        NSArray<NSString*>* commandArray = [response componentsSeparatedByString:@";"];
        for (NSString* commandString in commandArray)
            [self.commands addObject:[self.manager parseTextCommand:commandString]];
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid)
        [self sendEvent:CodelessLibEvent.StoredCommands object:[[CodelessStoredCommandsEvent alloc] initWithCommand:self]];
}

- (BOOL) requiresArguments {
    return true;
}

- (BOOL) checkArgumentsCount {
    return [CodelessProfile countArguments:self.command split:@","] == 1;
}

- (NSString*) parseArguments {
    NSNumber* num = [self decodeNumberArgument:1];
    int value = num.intValue;
    if (!num || CodelessLibConfig.CHECK_COMMAND_STORE_INDEX && (value < CodelessLibConfig.COMMAND_STORE_INDEX_MIN || value > CodelessLibConfig.COMMAND_STORE_INDEX_MAX))
        return @"Invalid index";
    _index = value;
    return nil;
}

/// Sets the command slot index argument (0-3).
- (void) setIndex:(int)index {
    _index = index;
    if (CodelessLibConfig.CHECK_COMMAND_STORE_INDEX) {
        if (index < CodelessLibConfig.COMMAND_STORE_INDEX_MIN || index > CodelessLibConfig.COMMAND_STORE_INDEX_MAX)
            self.invalid = true;
    }
}

@end
