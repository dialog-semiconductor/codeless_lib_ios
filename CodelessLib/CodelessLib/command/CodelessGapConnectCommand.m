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

#import "CodelessGapConnectCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@implementation CodelessGapConnectCommand

static NSString* const TAG = @"GapConnectCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"GAPCONNECT";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_GAPCONNECT;

static NSString* ADDRESS_PATTERN_STRING = @"(?:[0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}";
static NSRegularExpression* ADDRESS_PATTERN;

static NSString* PATTERN_STRING;
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessGapConnectCommand.class)
        return;

    NAME = [CodelessProfile.PREFIX_LOCAL stringByAppendingString:COMMAND];

    NSError* addressPatternError = nil;
    ADDRESS_PATTERN = [NSRegularExpression regularExpressionWithPattern:ADDRESS_PATTERN_STRING options:0 error:&addressPatternError];

    PATTERN_STRING = [NSString stringWithFormat:@"^GAPCONNECT=(%@),([PR])$", ADDRESS_PATTERN_STRING]; // <address> <type>
    NSError* patternError = nil;
    PATTERN = [NSRegularExpression regularExpressionWithPattern:PATTERN_STRING options:0 error:&patternError];
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

+ (NSString*) ADDRESS_PATTERN_STRING {
    return ADDRESS_PATTERN_STRING;
}

+ (NSRegularExpression*) ADDRESS_PATTERN {
    return ADDRESS_PATTERN;
}

+ (NSString*) PATTERN_STRING {
    return PATTERN_STRING;
}

+ (NSRegularExpression*) PATTERN {
    return PATTERN;
}

- (instancetype) initWithManager:(CodelessManager*)manager address:(NSString*)address addressType:(int)addressType {
    self = [self initWithManager:manager];
    if (!self)
        return nil;
    self.address = address;
    self.addressType = addressType;
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

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    if (![response isEqualToString:@"Connected"] && ![response isEqualToString:@"Connecting"]) {
        self.invalid = true;
    } else if ([response isEqualToString:@"Connected"]) {
        self.connected = true;
    }
    if (self.invalid) {
        CodelessLog(TAG, "Received invalid response: %@", response);
    } else {
        CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "Connect status: %@", response);
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid & self.connected)
        [self sendEvent:CodelessLibEvent.GapDeviceConnected object:[[CodelessGapDeviceConnectedEvent alloc] initWithCommand:self]];
}

- (BOOL) hasArguments {
    return true;
}

- (NSString*) getArguments {
    return [NSString stringWithFormat:@"%@,%@", self.address, (self.addressType == CODELESS_COMMAND_GAP_ADDRESS_TYPE_PUBLIC ? CODELESS_COMMAND_GAP_ADDRESS_TYPE_PUBLIC_STRING : CODELESS_COMMAND_GAP_ADDRESS_TYPE_RANDOM_STRING)];
}

- (BOOL) requiresArguments {
    return true;
}

- (BOOL) checkArgumentsCount {
    return [CodelessProfile countArguments:self.command split:@","] == 2;
}

- (NSString*) parseArguments {
    NSString* address = [self.command substringWithRange:[self.matcher rangeAtIndex:1]];
    if (![ADDRESS_PATTERN firstMatchInString:address options:0 range:NSMakeRange(0, address.length)])
        return @"Invalid address";
    _address = address;

    NSString* addressTypeString = [self.command substringWithRange:[self.matcher rangeAtIndex:2]];
    _addressType = [addressTypeString isEqualToString:CODELESS_COMMAND_GAP_ADDRESS_TYPE_PUBLIC_STRING] ? CODELESS_COMMAND_GAP_ADDRESS_TYPE_PUBLIC : CODELESS_COMMAND_GAP_ADDRESS_TYPE_RANDOM;

    return nil;
}

/// Sets the Bluetooth address argument.
- (void) setAddress:(NSString*)address {
    _address = address;
    if (![ADDRESS_PATTERN firstMatchInString:address options:0 range:NSMakeRange(0, address.length)])
        self.invalid = true;
}

/// Sets the Bluetooth address {@link CodelessProfile#CODELESS_COMMAND_GAP_ADDRESS_TYPE type} argument.
- (void) setAddressType:(int)addressType {
    _addressType = addressType;
    if (addressType != CODELESS_COMMAND_GAP_ADDRESS_TYPE_PUBLIC && addressType != CODELESS_COMMAND_GAP_ADDRESS_TYPE_RANDOM)
        self.invalid = true;
}

@end
