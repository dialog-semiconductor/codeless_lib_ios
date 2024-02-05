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

#import "CodelessBondingEntryStatusCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibConfig.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@interface CodelessBondingEntryStatusCommand ()

/// <code>true</code> if the command has arguments, <code>false</code> for no arguments.
@property BOOL hasArguments;

@end

@implementation CodelessBondingEntryStatusCommand

static NSString* const TAG = @"BondingEntryStatusCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"CHGBNDP";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_CHGBNDP;

static NSString* PATTERN_STRING = @"^CHGBNDP(?:=(0x[0-9a-fA-F]+|\\d+),(\\d))?$"; // <index> <status>
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessBondingEntryStatusCommand.class)
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

- (instancetype) initWithManager:(CodelessManager*)manager index:(int)index persistent:(BOOL)persistent {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.index = index;
    self.persistent = persistent;
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
    return self.hasArguments ? [NSString stringWithFormat:@"%d,%d", self.index, (self.persistent ? CODELESS_COMMAND_BONDING_ENTRY_PERSISTENT : CODELESS_COMMAND_BONDING_ENTRY_NON_PERSISTENT)] : nil;
}

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    if (!self.tablePersistenceStatus)
        self.tablePersistenceStatus = [NSMutableArray array];

    NSRange commaPos = [response rangeOfString:@","];
    if (commaPos.location == NSNotFound) {
        self.invalid = true;
        CodelessLog(TAG, "Received invalid bonding entry persistence status: %@", response);
        return;
    }

    NSScanner* scanner = [NSScanner scannerWithString:[response substringToIndex:commaPos.location]];
    int index;
    if (![scanner scanInt:&index] || CodelessLibConfig.CHECK_BONDING_DATABASE_INDEX && (index < CodelessLibConfig.BONDING_DATABASE_INDEX_MIN || index > CodelessLibConfig.BONDING_DATABASE_INDEX_MAX)) {
        self.invalid = true;
        CodelessLog(TAG, "Received invalid bonding entry persistence status: %@", response);
        return;
    }

    BOOL status;
    NSString* statusStr = [response substringFromIndex:commaPos.location + 1];
    if ([statusStr isEqualToString:@"<empty>"]) {
        [self.tablePersistenceStatus addObject:[NSNull null]];
        CodelessLog(TAG, "Bonding persistence status: %d, empty", index);
    } else {
        NSScanner* statusScanner = [NSScanner scannerWithString:statusStr];
        int statusInt;
        if (![statusScanner scanInt:&statusInt] || statusInt != CODELESS_COMMAND_BONDING_ENTRY_NON_PERSISTENT && statusInt != CODELESS_COMMAND_BONDING_ENTRY_PERSISTENT) {
            self.invalid = true;
            CodelessLog(TAG, "Received invalid bonding entry persistence status: %@", response);
        } else {
            status = statusInt != CODELESS_COMMAND_BONDING_ENTRY_NON_PERSISTENT;
            [self.tablePersistenceStatus addObject:@(status)];
            CodelessLog(TAG, "Bonding persistence status: %d, %@", index, (status ? @"persistent" : @"non-persistent"));
        }
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid) {
        if (self.hasArguments) {
            [self sendEvent:CodelessLibEvent.BondingEntryPersistenceStatusSet object:[[CodelessBondingEntryPersistenceStatusSetEvent alloc] initWithCommand:self]];
        } else {
            [self sendEvent:CodelessLibEvent.BondingEntryPersistenceTableStatus object:[[CodelessBondingEntryPersistenceTableStatusEvent alloc] initWithCommand:self]];
        }
    }
}

- (BOOL) checkArgumentsCount {
    int count = [CodelessProfile countArguments:self.command split:@","];
    return count == 0 || count == 2;
}

- (NSString*) parseArguments {
    if (![CodelessProfile hasArguments:self.command])
        return nil;
    self.hasArguments = true;

    NSNumber* num = [self decodeNumberArgument:1];
    int value = num.intValue;
    if (!num || CodelessLibConfig.CHECK_BONDING_DATABASE_INDEX && (value < CodelessLibConfig.BONDING_DATABASE_INDEX_MIN || value > CodelessLibConfig.BONDING_DATABASE_INDEX_MAX) && value != CodelessLibConfig.BONDING_DATABASE_ALL_VALUES)
        return @"Invalid bonding database index";
    _index = value;

    num = [self decodeNumberArgument:2];
    value = num.intValue;
    if (!num || value != CODELESS_COMMAND_BONDING_ENTRY_NON_PERSISTENT && value != CODELESS_COMMAND_BONDING_ENTRY_PERSISTENT)
        return @"Invalid bonding entry persistent status";
    _persistent = value != CODELESS_COMMAND_BONDING_ENTRY_NON_PERSISTENT;

    return nil;
}

/// Sets the bonding entry index argument (1-5, 0xFF: all entries).
- (void) setIndex:(int)index {
    _index = index;
    if (CodelessLibConfig.CHECK_BONDING_DATABASE_INDEX) {
        if ((index < CodelessLibConfig.BONDING_DATABASE_INDEX_MIN || index > CodelessLibConfig.BONDING_DATABASE_INDEX_MAX) && index != CodelessLibConfig.BONDING_DATABASE_ALL_VALUES)
            self.invalid = true;
    }
}

@end
