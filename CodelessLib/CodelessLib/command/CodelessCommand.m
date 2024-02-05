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

#import "CodelessCommand.h"
#import "CodelessManager.h"
#import "CodelessLibLog.h"
#import "CodelessScript.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"

@implementation CodelessCommand

static NSString* const TAG = @"CodelessCommand";
+ (NSString*) TAG {
    return TAG;
}

- (instancetype) init {
    self = [super init];
    if (!self)
        return nil;
    self.response = [NSMutableArray array];
    return self;
}

- (instancetype) initWithManager:(CodelessManager*)manager {
    self = [self init];
    if (!self)
        return nil;
    self.manager = manager;
    return self;
}

- (instancetype) initWithManager:(CodelessManager*)manager command:(NSString*)command parse:(BOOL)parse {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.command = command;
    if (parse)
        [self parseCommand:command];
    return self;
}

- (CodelessCommand*) origin:(NSObject*)origin {
    _origin = origin;
    return self;
}

- (BOOL) hasPrefix {
    return self.prefix != nil;
}

- (void) setInbound {
    self.inbound = true;
}

- (BOOL) isValid {
    return !self.invalid;
}

- (void) setPeerInvalid {
    self.peerInvalid = true;
}

- (void) setComplete {
    self.complete = true;
}

- (BOOL) failed {
    return self.error != nil;
}

- (NSString*) TAG {
    return TAG;
}

- (NSRegularExpression*) pattern {
    return nil;
}

- (NSString*) packCommand {
    return self.command = !self.hasArguments ? self.ID : [NSString stringWithFormat:@"%@=%@", self.ID, [self getArguments]];
}

- (BOOL) hasArguments {
    return false;
}

- (NSString*) getArguments {
    return nil;
}

- (BOOL) parsePartialResponse {
    return false;
}

- (void) parseResponse:(NSString*)response {
    [self.response addObject:response];
    CodelessLogOpt(CodelessLibLog.COMMAND, self.TAG, "Response: %@", response);
}

- (int) responseLine {
    return self.response.count;
}

- (void) onSuccess {
    CodelessLogOpt(CodelessLibLog.COMMAND, self.TAG, "Command succeeded");
    self.complete = true;
    [self sendEvent:CodelessLibEvent.CommandSuccess object:[[CodelessCommandSuccessEvent alloc] initWithCommand:self]];
    if (self.script)
        [self.script onSuccess:self];
}

- (void) onError:(NSString*)msg {
    CodelessLogOpt(CodelessLibLog.COMMAND, self.TAG, "Command failed: %@", msg);
    if (!self.error)
        self.error = msg;
    self.complete = true;
    [self sendEvent:CodelessLibEvent.CommandError object:[[CodelessCommandErrorEvent alloc] initWithCommand:self msg:msg]];
    if (self.script)
        [self.script onError:self];
}

- (void) setErrorCode:(int)code message:(NSString*)message {
    self.errorCode = code;
    self.error = message;
}

- (NSString*) parseCommand:(NSString*)command {
    CodelessLogOpt(CodelessLibLog.COMMAND, self.TAG, "Parse command: %@", command);
    self.command = command;
    self.parsed = true;

    if (!self.pattern) {
        CodelessLog(self.TAG, "No command pattern");
        self.invalid = true;
        return self.error = CodelessProfile.INVALID_COMMAND;
    }

    if (self.requiresArguments && ![CodelessProfile hasArguments:command]) {
        CodelessLogOpt(CodelessLibLog.COMMAND, self.TAG, "No arguments");
        self.invalid = true;
        return self.error = CodelessProfile.NO_ARGUMENTS;
    }

    if (![self checkArgumentsCount]) {
        CodelessLogOpt(CodelessLibLog.COMMAND, self.TAG, "Wrong number of arguments");
        self.invalid = true;
        return self.error = CodelessProfile.WRONG_NUMBER_OF_ARGUMENTS;
    }

    self.matcher = [self.pattern firstMatchInString:command options:0 range:NSMakeRange(0, command.length)];
    if (!self.matcher) {
        CodelessLogOpt(CodelessLibLog.COMMAND, self.TAG, "Command pattern match failed");
        self.invalid = true;
        return self.error = CodelessProfile.INVALID_ARGUMENTS;
    }

    NSString* msg = [self parseArguments];
    if (msg) {
        CodelessLogOpt(CodelessLibLog.COMMAND, self.TAG, "Invalid arguments: %@", msg);
        self.error = msg;
        self.invalid = true;
    }
    return msg;
}

- (BOOL) requiresArguments {
    return false;
}

- (BOOL) checkArgumentsCount {
    return true;
}

- (NSString*) parseArguments {
    return nil;
}

- (void) processInbound {
    [self sendSuccess];
}

- (void) sendSuccess {
    self.complete = true;
    [self.manager sendSuccess];
}

- (void) sendSuccess:(NSString*)response {
    self.complete = true;
    [self.manager sendSuccess:response];
}

- (void) sendError:(NSString*)msg {
    self.complete = true;
    self.error = msg;
    [self.manager sendError:[CodelessProfile.ERROR_PREFIX stringByAppendingString:msg]];
}

- (void) sendResponse:(NSString*)response more:(BOOL)more {
    [self.manager sendResponse:response];
    if (!more) {
        [self sendSuccess];
    }
}

- (NSNumber*) decodeNumberArgument:(int)group {
    NSRange range = [self.matcher rangeAtIndex:group];
    if (NSEqualRanges(range, NSMakeRange(NSNotFound, 0)))
        return nil;
    NSString* value = [self.command substringWithRange:range];
    NSScanner* scanner = [NSScanner scannerWithString:value];
    if ([value hasPrefix:@"0x"] || [value hasPrefix:@"0X"]) {
        uint number;
        if (![scanner scanHexInt:&number]) {
            CodelessLogOpt(CodelessLibLog.COMMAND, self.TAG, "Invalid number argument: %@", value);
            return nil;
        }
        return @(number);
    } else {
        int number;
        if (![scanner scanInt:&number]) {
            CodelessLogOpt(CodelessLibLog.COMMAND, self.TAG, "Invalid number argument: %@", value);
            return nil;
        }
        return @(number);
    }
}

- (void) sendEvent:(NSString*)event object:(CodelessCommandEvent*)object {
    [NSNotificationCenter.defaultCenter postNotificationName:event object:self.manager userInfo:@{ @"event" : object }];
}

- (void) sendEvent:(NSString*)event class:(Class)eventClass {
    if (![eventClass isSubclassOfClass:CodelessCommandEvent.class])
        return;
    id object = [eventClass alloc];
    if (![object respondsToSelector:@selector(initWithCommand:)])
        return;
    object = [object initWithCommand:self];
    [NSNotificationCenter.defaultCenter postNotificationName:event object:self.manager userInfo:@{ @"event" : object }];
}

- (NSString*) description {
    return [NSString stringWithFormat:@"[%@]", self.name];
}

@end
