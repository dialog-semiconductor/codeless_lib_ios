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

#import "CodelessGapStatusCommand.h"
#import "CodelessManager.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@implementation CodelessGapStatusCommand

static NSString* const TAG = @"GapStatusCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"GAPSTATUS";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_GAPSTATUS;

static NSString* PATTERN_STRING = @"^GAPSTATUS$";
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessGapStatusCommand.class)
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
    _gapRole = -1;
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
    if (self.responseLine == 1) {
        NSArray<NSString*>* status = [response componentsSeparatedByString:@","];
        NSString* errorMsg = [NSString stringWithFormat:@"Received invalid GAP status response: %@", response];
        if (status.count != 2) {
            self.invalid = true;
            CodelessLog(TAG, "%@", errorMsg);
            return;
        }
        NSScanner* scanner = [NSScanner scannerWithString:status[0]];
        int num;
        if (![scanner scanInt:&num] || num != CODELESS_COMMAND_GAP_ROLE_PERIPHERAL && num != CODELESS_COMMAND_GAP_ROLE_CENTRAL) {
            self.invalid = true;
            CodelessLog(TAG, "%@", errorMsg);
            return;
        }
        _gapRole = num;

        scanner = [NSScanner scannerWithString:status[1]];
        if (![scanner scanInt:&num] || num != CODELESS_COMMAND_GAP_STATUS_DISCONNECTED && num != CODELESS_COMMAND_GAP_STATUS_CONNECTED) {
            self.invalid = true;
            CodelessLog(TAG, "%@", errorMsg);
            return;
        }
        self.connected = num != CODELESS_COMMAND_GAP_STATUS_DISCONNECTED;
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid)
        [self sendEvent:CodelessLibEvent.GapStatus object:[[CodelessGapStatusEvent alloc] initWithCommand:self]];
}

- (void) processInbound {
    if (self.gapRole == -1) {
        _gapRole = CODELESS_COMMAND_GAP_ROLE_CENTRAL;
        self.connected = self.manager.isConnected;
    }
    NSString* response = [NSString stringWithFormat:@"%d,%d", self.gapRole, self.connected ? CODELESS_COMMAND_GAP_STATUS_CONNECTED : CODELESS_COMMAND_GAP_STATUS_DISCONNECTED];
    CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "GAP status: %@", response);
    [self sendSuccess:response];
}

/// Sets the GAP role response (0: peripheral, 1: central).
- (void) setGapRole:(int)gapRole {
    _gapRole = gapRole;
    if (gapRole != CODELESS_COMMAND_GAP_ROLE_PERIPHERAL && gapRole != CODELESS_COMMAND_GAP_ROLE_CENTRAL)
        self.invalid = true;
}

@end
