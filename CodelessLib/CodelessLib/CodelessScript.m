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

#import "CodelessScript.h"
#import "CodelessProfile.h"
#import "CodelessCommand.h"
#import "CodelessManager.h"
#import "CodelessLibLog.h"
#import "CodelessLibEvent.h"

@interface CodelessScript ()

@property (weak) CodelessManager* manager;
@property BOOL invalid;
@property BOOL custom;
@property BOOL started;
@property BOOL stopped;
@property BOOL complete;

@end

@implementation CodelessScript

static NSString* const TAG = @"CodelessScript";
+ (NSString*) TAG {
    return TAG;
}

static int nextScriptId;

- (instancetype) init {
    self = [super init];
    if (!self)
        return nil;
    self.id = nextScriptId++;
    _script = @[];
    _commands = @[];
    self.stopOnError = true;
    return self;
}

- (instancetype) initWithManager:(CodelessManager*)manager {
    self = [self init];
    if (!self)
        return nil;
    self.manager = manager;
    return self;
}

- (instancetype) initWithManager:(CodelessManager*)manager text:(NSString*)text {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    [self setText:text];
    return self;
}

- (instancetype) initWithManager:(CodelessManager*)manager script:(NSArray<NSString*>*)script {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.script = script;
    return self;
}

- (instancetype) initWithName:(NSString*)name manager:(CodelessManager*)manager {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.name = name;
    return self;
}

- (instancetype) initWithName:(NSString*)name manager:(CodelessManager*)manager text:(NSString*)text {
    self = [self initWithManager:manager text:text];
    if (!self)
        return nil;
    self.name = name;
    return self;
}

- (instancetype) initWithName:(NSString*)name manager:(CodelessManager*)manager script:(NSArray<NSString*>*)script {
    self = [self initWithManager:manager script:script];
    if (!self)
        return nil;
    self.name = name;
    return self;
}

/// Initializes the script by parsing the script text to a list of {@link CodelessCommand} objects.
- (void) initScript {
    NSMutableArray<CodelessCommand*>* commands = [NSMutableArray arrayWithCapacity:self.script.count];
    for (NSString* text in self.script) {
        CodelessCommand* command = [self.manager parseTextCommand:text];
        command.script = self;
        [commands addObject:command];
        if (!command.isValid)
            self.invalid = true;
        if (command.commandID == CODELESS_COMMAND_ID_CUSTOM)
            self.custom = true;
    }
    _commands = [NSArray arrayWithArray:commands];
}

- (void) start {
    if (self.started)
        return;
    self.started = true;
    CodelessLogOpt(CodelessLibLog.SCRIPT, TAG, "Script start: %@", self);
    [self.manager addScript:self];
    [self sendEvent:CodelessLibEvent.ScriptStart object:[[CodelessScriptStartEvent alloc] initWithScript:self]];
    _current = -1;
    [self sendNextCommand];
}

- (void) stop {
    CodelessLogOpt(CodelessLibLog.SCRIPT, TAG, "Script stopped: %@", self);
    self.stopped = true;
    self.complete = true;
    [self.manager removeScript:self];
}

- (void) onSuccess:(CodelessCommand*)command {
    CodelessLogOpt(CodelessLibLog.SCRIPT, TAG, "Script command success: %@ %@", self, command);
    [self sendEvent:CodelessLibEvent.ScriptCommand object:[[CodelessScriptCommandEvent alloc] initWithScript:self command:command]];
    [self sendNextCommand];
}

- (void) onError:(CodelessCommand*)command {
    CodelessLogOpt(CodelessLibLog.SCRIPT, TAG, "Script command error: %@ %@ %@", self, command, command.error);
    [self sendEvent:CodelessLibEvent.ScriptCommand object:[[CodelessScriptCommandEvent alloc] initWithScript:self command:command]];
    if (!self.stopOnError) {
        [self sendNextCommand];
    } else {
        [self stop];
        [self sendEvent:CodelessLibEvent.ScriptEnd object:[[CodelessScriptEndEvent alloc] initWithScript:self error:true]];
    }
}

/**
 * Continues the script execution with the next command.
 * <p> If there are no commands left, a {@link CodelessLibEvent#ScriptEnd ScriptEnd} event is generated.
 */
- (void) sendNextCommand {
    if (self.stopped)
        [self sendEvent:CodelessLibEvent.ScriptEnd object:[[CodelessScriptEndEvent alloc] initWithScript:self error:false]];
    if (self.complete)
        return;
    _current++;
    if (self.current < self.commands.count) {
        CodelessCommand* command = [self getCurrentCommand];
        CodelessLogOpt(CodelessLibLog.SCRIPT, TAG, "Script command: %@[%d] %@", self, self.current +  1, command);
        [self.manager sendCommand:command];
    } else {
        self.complete = true;
        [self.manager removeScript:self];
        CodelessLogOpt(CodelessLibLog.SCRIPT, TAG, "Script end: %@", self);
        [self sendEvent:CodelessLibEvent.ScriptEnd object:[[CodelessScriptEndEvent alloc] initWithScript:self error:false]];
    }
}

/**
 * Sets the script text and parses it to a list of {@link CodelessCommand} objects.
 * @param script the script text (one command per line)
 */
- (void) setScript:(NSArray<NSString*>*)script {
    if (self.started)
        return;
    _script = script;
    [self initScript];
}

- (void) setText:(NSString*)text {
    if (self.started)
        return;
    NSMutableArray* script = [NSMutableArray array];
    for (__strong NSString* line in [text componentsSeparatedByString:@"\n"]) {
        line = [line stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        if (line.length)
            [script addObject:line];
    }
    self.script = [NSArray arrayWithArray:script];
}

- (NSString*) getText {
    if (!self.script.count)
        return @"";
    NSMutableString* text = [NSMutableString string];
    for (NSString* command in self.script) {
        [text appendString:command];
        [text appendString:@"\n"];
    }
    return [NSString stringWithString:text];
}

/**
 * Sets the script commands to a list of prepared {@link CodelessCommand} objects.
 * <p> The corresponding script text is also created.
 * @param commands the script commands
 */
- (void) setCommands:(NSArray<CodelessCommand*>*)commands {
    if (self.started)
        return;
    _commands = commands;
    NSMutableArray* script = [NSMutableArray arrayWithCapacity:commands.count];
    for (CodelessCommand* command in commands) {
        if (!command.parsed)
            [command packCommand];
        NSString* text = command.command;
        if (!command.isValid)
            self.invalid = true;
        if (command.commandID == CODELESS_COMMAND_ID_CUSTOM)
            self.custom = true;
        else if (command.hasPrefix)
            text = [command.prefix stringByAppendingString:text];
        [script addObject:text];
    }
    _script = script;
}

- (CodelessCommand*) getCurrentCommand {
    return self.commands[self.current];
}

- (NSString*) getCurrentCommandText {
    return self.script[self.current];
}

- (int) getCommandIndex:(CodelessCommand*)command {
    return [self.commands indexOfObject:command];
}

/**
 * Sets the current command index, if the script is not running.
 * @param current the command index (0-based). This is the first command that will be executed when the script is started.
 */
- (void) setCurrent:(int)current {
    if (!self.started)
        _current = current;
}

- (void) sendEvent:(NSString*)event object:(CodelessEvent*)object {
    [NSNotificationCenter.defaultCenter postNotificationName:event object:self.manager userInfo:@{ @"event" : object }];
}

- (NSString*) description {
    return [NSString stringWithFormat:@"[%@]", self.name ? self.name : [@"Script " stringByAppendingString:@(self.id).stringValue]];
}

@end
