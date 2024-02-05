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

#import "CodelessBondingEntryTransferCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibConfig.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"
#import "CodelessUtil.h"

@implementation CodelessBondingEntryTransferCommand

static NSString* const TAG = @"BondingEntryTransferCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"IEBNDE";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_IEBNDE;

static NSString* PATTERN_STRING = @"^IEBNDE=(\\d+)(?:,([0-9a-fA-F]{54};[0-9a-fA-F]{50};[0-9a-fA-F]{32};[0-9a-fA-F]{2};[0-9a-fA-F]{8}))?$"; // <index> <entry>
static NSRegularExpression* PATTERN;

static NSString* ENTRY_ARGUMENT_PATTERN_STRING = @"^[0-9a-fA-F]{54};[0-9a-fA-F]{50};[0-9a-fA-F]{32};[0-9a-fA-F]{2};[0-9a-fA-F]{8}$";
static NSRegularExpression* ENTRY_ARGUMENT_PATTERN;

+ (void) initialize {
    if (self != CodelessBondingEntryTransferCommand.class)
        return;

    NAME = [CodelessProfile.PREFIX_LOCAL stringByAppendingString:COMMAND];

    NSError* patternError = nil;
    PATTERN = [NSRegularExpression regularExpressionWithPattern:PATTERN_STRING options:0 error:&patternError];

    NSError* argumentPatternError = nil;
    ENTRY_ARGUMENT_PATTERN = [NSRegularExpression regularExpressionWithPattern:ENTRY_ARGUMENT_PATTERN_STRING options:0 error:&argumentPatternError];
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

+ (NSString*) ENTRY_ARGUMENT_PATTERN_STRING {
    return ENTRY_ARGUMENT_PATTERN_STRING;
}

+ (NSRegularExpression*) ENTRY_ARGUMENT_PATTERN {
    return ENTRY_ARGUMENT_PATTERN;
}

+ (BOOL) validData:(NSString*)data {
    return [ENTRY_ARGUMENT_PATTERN firstMatchInString:data options:0 range:NSMakeRange(0, data.length)] != nil;
}

- (instancetype) initWithManager:(CodelessManager*)manager index:(int)index {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.index = index;
    return self;
}

- (instancetype) initWithManager:(CodelessManager*)manager index:(int)index bondingEntry:(CodelessBondingEntry*)bondingEntry {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.index = index;
    self.bondingEntry = bondingEntry;
    return self;
}

- (instancetype) initWithManager:(CodelessManager*)manager index:(int)index entry:(NSString*)entry {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.index = index;
    self.entry = entry;
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
    if (self.entry)
        return [NSString stringWithFormat:@"%d,%@", self.index, self.entry];
    return @(self.index).stringValue;
}

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    if (self.responseLine == 1) {
        if ([CodelessBondingEntryTransferCommand validData:response]) {
            _entry = response;
            [self parseEntry:response];
        } else {
            self.invalid = true;
        }
        if (self.invalid)
            CodelessLog(TAG, "Received invalid bonding entry: %@", response);
        else
            CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "Bonding entry: LTK:%@ EDIV:%04X(%d) Rand:%@ Key size:%02X(%d) CSRK:%@ Bluetooth address:%@ Address type:%02X(%d) Authentication level:%02X(%d) Bonding database slot:%02X(%d) IRK:%@ Persistence status:%02X(%d) Timestamp:%@",
                           [CodelessUtil hexArray:self.bondingEntry.ltk], self.bondingEntry.ediv, self.bondingEntry.ediv, [CodelessUtil hexArray:self.bondingEntry.rand], self.bondingEntry.keySize, self.bondingEntry.keySize, [CodelessUtil hexArray:self.bondingEntry.csrk], [CodelessUtil hexArray:self.bondingEntry.bluetoothAddress], self.bondingEntry.addressType, self.bondingEntry.addressType,
                           self.bondingEntry.authenticationLevel, self.bondingEntry.authenticationLevel, self.bondingEntry.bondingDatabaseSlot, self.bondingEntry.bondingDatabaseSlot, [CodelessUtil hexArray:self.bondingEntry.irk], self.bondingEntry.persistenceStatus, self.bondingEntry.persistenceStatus, [CodelessUtil hexArray:self.bondingEntry.timestamp]);
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid)
        [self sendEvent:CodelessLibEvent.BondingEntry object:[[CodelessBondingEntryEvent alloc] initWithCommand:self]];
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
    if (!num || CodelessLibConfig.CHECK_BONDING_DATABASE_INDEX && (value < CodelessLibConfig.BONDING_DATABASE_INDEX_MIN || value > CodelessLibConfig.BONDING_DATABASE_INDEX_MAX))
        return @"Invalid bonding database index";
    _index = value;

    if ([CodelessProfile countArguments:self.command split:@","] == 1)
        return nil;
    NSString* entry = [self.command substringWithRange:[self.matcher rangeAtIndex:2]];
    if ([CodelessBondingEntryTransferCommand validData:entry]) {
        _entry = entry;
        [self parseEntry:entry];
    } else {
        return @"Invalid database entry";
    }

    return nil;
}

/**
 * Parses the bonding entry configuration argument/response and stores it to {@link #bondingEntry}.
 * @param entry the bonding entry configuration argument/response (packed hex data)
 */
- (void) parseEntry:(NSString*)entry {
    _bondingEntry = [[CodelessBondingEntry alloc] init];
    NSScanner* scanner;
    unsigned int value;
    self.bondingEntry.ltk = [CodelessUtil hex2bytes:[entry substringWithRange:NSMakeRange(0, 32)]];
    scanner = [NSScanner scannerWithString:[entry substringWithRange:NSMakeRange(32, 4)]];
    if (![scanner scanHexInt:&value]) {
        self.invalid = true;
        return;
    }
    self.bondingEntry.ediv = value;
    self.bondingEntry.rand = [CodelessUtil hex2bytes:[entry substringWithRange:NSMakeRange(36, 16)]];
    scanner = [NSScanner scannerWithString:[entry substringWithRange:NSMakeRange(52, 2)]];
    if (![scanner scanHexInt:&value]) {
           self.invalid = true;
           return;
    }
    self.bondingEntry.keySize = value;
    self.bondingEntry.csrk = [CodelessUtil hex2bytes:[entry substringWithRange:NSMakeRange(55, 32)]];
    self.bondingEntry.bluetoothAddress = [CodelessUtil hex2bytes:[entry substringWithRange:NSMakeRange(87, 12)]];
    scanner = [NSScanner scannerWithString:[entry substringWithRange:NSMakeRange(99, 2)]];
    if (![scanner scanHexInt:&value]) {
           self.invalid = true;
           return;
    }
    self.bondingEntry.addressType = value;
    scanner = [NSScanner scannerWithString:[entry substringWithRange:NSMakeRange(101, 2)]];
    if (![scanner scanHexInt:&value]) {
           self.invalid = true;
           return;
    }
    self.bondingEntry.authenticationLevel = value;
    scanner = [NSScanner scannerWithString:[entry substringWithRange:NSMakeRange(103, 2)]];
    if (![scanner scanHexInt:&value]) {
           self.invalid = true;
           return;
    }
    self.bondingEntry.bondingDatabaseSlot = value;
    self.bondingEntry.irk = [CodelessUtil hex2bytes:[entry substringWithRange:NSMakeRange(106, 32)]];
    scanner = [NSScanner scannerWithString:[entry substringWithRange:NSMakeRange(139, 2)]];
    if (![scanner scanHexInt:&value]) {
           self.invalid = true;
           return;
    }
    self.bondingEntry.persistenceStatus = value;
    self.bondingEntry.timestamp = [CodelessUtil hex2bytes:[entry substringWithRange:NSMakeRange(142, 8)]];
}

/**
 * Packs the bonding entry configuration argument and stores it to {@link #entry}.
 * @param bondingEntry the bonding entry configuration argument (unpacked)
 */
- (void) packEntry:(CodelessBondingEntry*)bondingEntry {
    NSMutableString* entry = [NSMutableString string];
    [entry appendString:[CodelessUtil hex:self.bondingEntry.ltk]];
    [entry appendString:[NSString stringWithFormat:@"%04X", self.bondingEntry.ediv]];
    [entry appendString:[CodelessUtil hex:self.bondingEntry.rand]];
    [entry appendString:[NSString stringWithFormat:@"%02X", self.bondingEntry.keySize]];
    [entry appendString:@";"];
    [entry appendString:[CodelessUtil hex:self.bondingEntry.csrk]];
    [entry appendString:[CodelessUtil hex:self.bondingEntry.bluetoothAddress]];
    [entry appendString:[NSString stringWithFormat:@"%02X", self.bondingEntry.addressType]];
    [entry appendString:[NSString stringWithFormat:@"%02X", self.bondingEntry.authenticationLevel]];
    [entry appendString:[NSString stringWithFormat:@"%02X", self.bondingEntry.bondingDatabaseSlot]];
    [entry appendString:@";"];
    [entry appendString:[CodelessUtil hex:self.bondingEntry.irk]];
    [entry appendString:@";"];
    [entry appendString:[NSString stringWithFormat:@"%02X", self.bondingEntry.persistenceStatus]];
    [entry appendString:@";"];
    [entry appendString:[CodelessUtil hex:self.bondingEntry.timestamp]];
    _entry = entry;
}

/// Sets the bonding entry index argument (1-5).
- (void) setIndex:(int)index {
    _index = index;
    if (CodelessLibConfig.CHECK_BONDING_DATABASE_INDEX) {
        if (index < CodelessLibConfig.BONDING_DATABASE_INDEX_MIN || index > CodelessLibConfig.BONDING_DATABASE_INDEX_MAX)
            self.invalid = true;
    }
}

/// Sets the bonding entry configuration argument (packed hex data).
- (void) setEntry:(NSString*)entry {
    _entry = entry;
    if ([CodelessBondingEntryTransferCommand validData:entry]) {
        [self parseEntry:entry];
    } else {
        self.invalid = true;
    }
}

/// Sets the bonding entry configuration argument (unpacked).
- (void) setBondingEntry:(CodelessBondingEntry*)bondingEntry {
    _bondingEntry = bondingEntry;
    [self packEntry:bondingEntry];
}

@end
