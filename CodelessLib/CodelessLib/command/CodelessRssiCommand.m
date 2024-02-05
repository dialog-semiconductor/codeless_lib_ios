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

#import "CodelessRssiCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@implementation CodelessRssiCommand

static NSString* const TAG = @"RssiCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"RSSI";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_RSSI;

static NSString* PATTERN_STRING = @"^RSSI$";
static NSRegularExpression* PATTERN;

static NSString* RESPONSE_PATTERN_STRING = @"^(-?\\d+).*$"; // <rssi>
static NSRegularExpression* RESPONSE_PATTERN;

+ (void) initialize {
    if (self != CodelessRssiCommand.class)
        return;

    NAME = [CodelessProfile.PREFIX_LOCAL stringByAppendingString:COMMAND];

    NSError* patternError = nil;
    PATTERN = [NSRegularExpression regularExpressionWithPattern:PATTERN_STRING options:0 error:&patternError];

    NSError* responseError = nil;
    RESPONSE_PATTERN = [NSRegularExpression regularExpressionWithPattern:RESPONSE_PATTERN_STRING options:0 error:&responseError];
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

+ (NSString*) RESPONSE_PATTERN_STRING {
    return RESPONSE_PATTERN_STRING;
}

+ (NSRegularExpression*) RESPONSE_PATTERN {
    return RESPONSE_PATTERN;
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
        NSTextCheckingResult* matcher = [RESPONSE_PATTERN firstMatchInString:response options:0 range:NSMakeRange(0, response.length)];
        if (!matcher) {
            self.invalid = true;
            CodelessLog(TAG, "Received invalid RSSI: %@", response);
            return;
        }
        NSScanner* scanner = [NSScanner scannerWithString:[response substringWithRange:[matcher rangeAtIndex:1]]];
        int num;
        if (![scanner scanInt:&num]) {
            self.invalid = true;
            CodelessLog(TAG, "Received invalid RSSI: %@", response);
            return;
        }
        self.rssi = num;
        CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "Peer RSSI: %d", self.rssi);
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid)
        [self sendEvent:CodelessLibEvent.PeerRssi object:[[CodelessPeerRssiEvent alloc] initWithCommand:self]];
}

@end
