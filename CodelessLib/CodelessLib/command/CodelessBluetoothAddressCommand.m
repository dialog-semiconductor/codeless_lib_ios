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

#import "CodelessBluetoothAddressCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@implementation CodelessBluetoothAddressCommand

static NSString* const TAG = @"BluetoothAddressCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"BDADDR";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_BDADDR;

static NSString* PATTERN_STRING = @"^BDADDR$";
static NSRegularExpression* PATTERN;

static NSString* RESPONSE_PATTERN_STRING = @"^((?:[0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2})(?:,([PR]))?$"; // <address> <type>
static NSRegularExpression* RESPONSE_PATTERN;

+ (void) initialize {
    if (self != CodelessBluetoothAddressCommand.class)
        return;

    NAME = [CodelessProfile.PREFIX_LOCAL stringByAppendingString:COMMAND];

    NSError* patternError = nil;
    PATTERN = [NSRegularExpression regularExpressionWithPattern:PATTERN_STRING options:0 error:&patternError];

    NSError* responsePatternError = nil;
    RESPONSE_PATTERN = [NSRegularExpression regularExpressionWithPattern:RESPONSE_PATTERN_STRING options:0 error:&responsePatternError];
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
        if (matcher) {
            self.address = [response substringWithRange:[matcher rangeAtIndex:1]];
            NSString* log = [NSString stringWithFormat:@"BD address: %@", self.address];
            if (!NSEqualRanges([matcher rangeAtIndex:2], NSMakeRange(NSNotFound, 0))) {
                self.random = [[response substringWithRange:[matcher rangeAtIndex:2]] isEqualToString:@"R"];
                log = [log stringByAppendingString:self.random ? @" (random)" : @" (public)"];
            }
            CodelessLogOpt(CodelessLibLog.COMMAND, TAG, @"%@", log);
        } else {
            CodelessLog(TAG, "Received invalid BD address: %@", response);
            self.invalid = true;
        }
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid)
        [self sendEvent:CodelessLibEvent.BluetoothAddress object:[[CodelessBluetoothAddressEvent alloc] initWithCommand:self]];
}

- (BOOL) isPublic {
    return !self.random;
}

- (void) processInbound {
    // Not available on iOS
    [self sendError:@"BD address not available"];
}

@end
