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

#import "CodelessEventHandlerCommand.h"
#import "CodelessManager.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@interface CodelessEventHandlerCommand ()

/// <code>true</code> if the command has arguments, <code>false</code> for no arguments.
@property BOOL hasArguments;

@end

@implementation CodelessEventHandlerCommand

static NSString* const TAG = @"EventHandlerCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"HNDL";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_HNDL;

static NSString* PATTERN_STRING = @"^HNDL(?:=(\\d+)(?:,((?:[^;]+;?)*))?)?$"; // <event> <command>
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessEventHandlerCommand.class)
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

- (instancetype) initWithManager:(CodelessManager*)manager event:(int)event commands:(NSMutableArray<CodelessCommand*>*)commands {
    self = [self initWithManager:manager event:event];
    if (!self)
        return nil;
    self.eventHandler.commands = commands;
    return self;
}

- (instancetype) initWithManager:(CodelessManager*)manager event:(int)event commandString:(NSString*)commandString {
    self = [self initWithManager:manager event:event];
    if (!self)
        return nil;
    self.eventHandler.commands = [self parseCommandString:commandString];
    return self;
}

- (instancetype) initWithManager:(CodelessManager*)manager event:(int)event {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.eventHandler = [[CodelessEventHandler alloc] init];
    [self setEvent:event];
    self.eventHandler.commands = [NSMutableArray array];
    self.hasArguments = true;
    return self;
}

- (instancetype) initWithManager:(CodelessManager*)manager eventHandler:(CodelessEventHandler*)eventHandler {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.eventHandler = eventHandler;
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
    if (!self.hasArguments)
        return nil;
    if (self.eventHandler.commands.count > 0)
        return [NSString stringWithFormat:@"%d,%@", self.eventHandler.event, [self packCommandList:self.eventHandler.commands]];
    return @(self.eventHandler.event).stringValue;
}

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    if (!self.eventHandlerTable)
        self.eventHandlerTable = [NSMutableArray array];
    NSString* errorMsg = [NSString stringWithFormat:@"Received invalid Event Handler response: %@", response];
    CodelessEventHandler* eventHandler = [[CodelessEventHandler alloc] init];
    NSRange splitRange = [response rangeOfString:@","];
    if (NSEqualRanges(splitRange, NSMakeRange(NSNotFound, 0))) {
        self.invalid = true;
        CodelessLog(TAG, "%@", errorMsg);
        return;
    }
    NSScanner* scanner = [NSScanner scannerWithString:[response substringToIndex:splitRange.location]];
    int num;
    if (![scanner scanInt:&num] || num != CODELESS_COMMAND_CONNECTION_EVENT_HANDLER && num != CODELESS_COMMAND_DISCONNECTION_EVENT_HANDLER && num != CODELESS_COMMAND_WAKEUP_EVENT_HANDLER) {
        self.invalid = true;
        CodelessLog(TAG, "%@", errorMsg);
        return;
    }
    eventHandler.event = num;

    NSString* commandString = [response substringFromIndex:splitRange.location + 1];
    eventHandler.commands = [self parseCommandString:[commandString isEqualToString:@"<empty>"] ? @"" : commandString];
    [self.eventHandlerTable addObject:eventHandler];
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid) {
        if (self.hasArguments)
            [self sendEvent:CodelessLibEvent.EventCommands object:[[CodelessEventCommandsEvent alloc] initWithCommand:self]];
        else
            [self sendEvent:CodelessLibEvent.EventCommandsTable object:[[CodelessEventCommandsTableEvent alloc] initWithCommand:self]];
    }
}

- (BOOL) checkArgumentsCount {
    int count = [CodelessProfile countArguments:self.command split:@","];
    return count == 0 || count == 1 || count == 2;
}

- (NSString*) parseArguments {
    self.eventHandler = [[CodelessEventHandler alloc] init];
    self.eventHandler.commands = [NSMutableArray array];

    int count = [CodelessProfile countArguments:self.command split:@","];
    if (!count)
        return nil;
    self.hasArguments = true;

    NSNumber* num = [self decodeNumberArgument:1];
    int value = num.intValue;
    if (!num || value != CODELESS_COMMAND_CONNECTION_EVENT_HANDLER && value != CODELESS_COMMAND_DISCONNECTION_EVENT_HANDLER && value != CODELESS_COMMAND_WAKEUP_EVENT_HANDLER)
        return @"Invalid event";
    self.eventHandler.event = value;

    if (count == 2) {
        NSString* commandString = [self.command substringWithRange:[self.matcher rangeAtIndex:2]];
        self.eventHandler.commands = [self parseCommandString:commandString];
    }

    return nil;
}

- (int) getEvent {
    return self.eventHandler.event;
}

- (void) setEvent:(int)event {
    self.eventHandler.event = event;
    if (event != CODELESS_COMMAND_CONNECTION_EVENT_HANDLER && event != CODELESS_COMMAND_DISCONNECTION_EVENT_HANDLER && event != CODELESS_COMMAND_WAKEUP_EVENT_HANDLER)
        self.invalid = true;
}

- (NSMutableArray<CodelessCommand*>*) getCommands {
    return self.eventHandler.commands;
}

- (void) setCommands:(NSMutableArray<CodelessCommand*>*)commands {
    self.eventHandler.commands = commands;
}

- (NSString*) getCommandString {
    return [self packCommandList:self.eventHandler.commands];
}

- (void) setCommandString:(NSString*)commandString {
    self.eventHandler.commands = [self parseCommandString:commandString];
}

/**
 * Parses a handler commands text to a list of parsed commands.
 * @param commandString the handler commands text (semicolon separated)
 */
- (NSMutableArray<CodelessCommand*>*) parseCommandString:(NSString*)commandString {
    NSArray<NSString*>* commandArray = [commandString componentsSeparatedByString:@";"];
    NSMutableArray<CodelessCommand*>* commandList = [NSMutableArray array];
    for (NSString* command in commandArray) {
        if (command.length != 0)
            [commandList addObject:[self.manager parseTextCommand:command]];
    }
    return commandList;
}

/**
 * Packs a list of handler commands to the corresponding handler commands text (semicolon separated).
 * @param commands the list of handler commands
 */
- (NSString*) packCommandList:(NSMutableArray<CodelessCommand*>*)commands {
    NSMutableString* mutableString = [NSMutableString string];
    for (CodelessCommand* command in commands) {
        NSString* commandString = command.hasPrefix ? [command.prefix stringByAppendingString:command.command] : command.command;
        [mutableString appendString:mutableString.length > 0 ? [@";" stringByAppendingString:commandString] : commandString];
    }
    return mutableString;
}

@end
