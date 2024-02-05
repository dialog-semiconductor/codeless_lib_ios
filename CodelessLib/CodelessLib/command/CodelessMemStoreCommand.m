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

#import "CodelessMemStoreCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibConfig.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@implementation CodelessMemStoreCommand

static NSString* const TAG = @"MemStoreCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"MEM";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_MEM;

static NSString* PATTERN_STRING = @"^MEM=(\\d+)(?:,(.*))?$"; // <index> <text>
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessMemStoreCommand.class)
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

- (instancetype) initWithManager:(CodelessManager*)manager memIndex:(int)memIndex {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.memIndex = memIndex;
    return self;
}

- (instancetype) initWithManager:(CodelessManager*)manager memIndex:(int)memIndex text:(NSString*)text {
    self = [self initWithManager:manager memIndex:memIndex];
    if (!self)
        return nil;
    self.text = text;
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
    if (self.text)
        return [NSString stringWithFormat:@"%d,%@", self.memIndex, self.text];
    return @(self.memIndex).stringValue;
}

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    if (self.responseLine == 1) {
        _text = response;
        CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "Memory index: %d contains: %@", self.memIndex, self.text);
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid)
        [self sendEvent:CodelessLibEvent.MemoryTextContent object:[[CodelessMemoryTextContentEvent alloc] initWithCommand:self]];
}

- (BOOL) requiresArguments {
    return true;
}

- (BOOL) checkArgumentsCount {
    int count = [CodelessProfile countArguments:self.command split:@","];
    return count == 1 || count == 2;
}

- (NSString*) parseArguments {
    NSNumber* num = [self decodeNumberArgument:1];
    int value = num.intValue;
    if (!num || CodelessLibConfig.CHECK_MEM_INDEX && (value < CodelessLibConfig.MEM_INDEX_MIN || value > CodelessLibConfig.MEM_INDEX_MAX))
        return @"Invalid memory index";
    _memIndex = value;

    if ([CodelessProfile countArguments:self.command split:@","] == 1)
        return nil;
    NSString* text = [self.command substringWithRange:[self.matcher rangeAtIndex:2]];
    if (CodelessLibConfig.CHECK_MEM_CONTENT_SIZE && text.length > CodelessLibConfig.MEM_MAX_CHAR_COUNT)
        return @"Text exceeds max character number";
    _text = text;

    return nil;
}

/// Sets the memory slot index argument (0-3).
- (void) setMemIndex:(int)memIndex {
    _memIndex = memIndex;
    if (CodelessLibConfig.CHECK_MEM_INDEX) {
        if (memIndex < CodelessLibConfig.MEM_INDEX_MIN || memIndex > CodelessLibConfig.MEM_INDEX_MAX)
            self.invalid = true;
    }
}

/// Sets the stored text argument.
- (void) setText:(NSString*)text {
    _text = text;
    if (CodelessLibConfig.CHECK_MEM_CONTENT_SIZE && text.length > CodelessLibConfig.MEM_MAX_CHAR_COUNT)
        self.invalid = true;
}

@end
