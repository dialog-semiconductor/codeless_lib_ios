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

#import "CodelessCmdStoreCommand.h"
#import "CodelessManager.h"
#import "CodelessProfile.h"
#import "CodelessLibConfig.h"

@implementation CodelessCmdStoreCommand

static NSString* const TAG = @"CmdStoreCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"CMDSTORE";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_CMDSTORE;

static NSString* PATTERN_STRING = @"^CMDSTORE=(\\d+),((?:[^;]+;?)+)$"; // <index> <command>
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessCmdStoreCommand.class)
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

- (instancetype) initWithManager:(CodelessManager*)manager index:(int)index commands:(NSMutableArray<CodelessCommand*>*)commands {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.index = index;
    self.commands = commands;
    self.commandString = [self packCommandList:commands];
    return self;
}

- (instancetype) initWithManager:(CodelessManager*)manager index:(int)index commandString:(NSString*)commandString {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.index = index;
    self.commandString = commandString;
    self.commands = [self parseCommandString:commandString];
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
    return [NSString stringWithFormat:@"%d,%@", self.index, self.commandString];
}

- (BOOL) requiresArguments {
    return true;
}

- (BOOL) checkArgumentsCount {
    return [CodelessProfile countArguments:self.command split:@","] == 2;
}

- (NSString*) parseArguments {
    NSNumber* num = [self decodeNumberArgument:1];
    int value = num.intValue;
    if (!num || CodelessLibConfig.CHECK_COMMAND_STORE_INDEX && (value < CodelessLibConfig.COMMAND_STORE_INDEX_MIN || value > CodelessLibConfig.COMMAND_STORE_INDEX_MAX))
        return @"Invalid index";
    _index = value;

    NSString* commandString = [self.command substringWithRange:[self.matcher rangeAtIndex:2]];
    if (!commandString)
        return @"Invalid command strings";
    self.commandString = commandString;
    self.commands = [self parseCommandString:commandString];
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

/**
 * Parses a stored commands text to a list of parsed commands.
 * @param commandString the stored commands text (semicolon separated)
 */
- (NSMutableArray<CodelessCommand*>*) parseCommandString:(NSString*)commandString {
    NSArray<NSString*>* commandArray = [commandString componentsSeparatedByString:@";"];
    NSMutableArray<CodelessCommand*>* commandList = [NSMutableArray array];
    for (NSString* command in commandArray) {
        if (command.length)
            [commandList addObject:[self.manager parseTextCommand:command]];
    }
    return commandList;
}

/**
 * Packs a list of stored commands to the corresponding stored commands text (semicolon separated).
 * @param commands the list of stored commands
 */
- (NSString*) packCommandList:(NSMutableArray<CodelessCommand*>*)commands {
    NSMutableString* commandString = [NSMutableString string];
    for (CodelessCommand* command in commands) {
        NSString* commandString = command.hasPrefix ? [command.prefix stringByAppendingString:command.command] : command.command;
        [commandString stringByAppendingString:commandString.length > 0 ? [@";" stringByAppendingString:commandString] : commandString];
    }
    return commandString;
}

@end
