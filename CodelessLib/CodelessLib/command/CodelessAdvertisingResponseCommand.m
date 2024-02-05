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

#import "CodelessAdvertisingResponseCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"
#import "CodelessUtil.h"

@implementation CodelessAdvertisingResponseCommand

static NSString* const TAG = @"AdvertisingResponseCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"ADVRESP";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_ADVRESP;

static NSString* PATTERN_STRING;
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessAdvertisingResponseCommand.class)
        return;

    NAME = [CodelessProfile.PREFIX_LOCAL stringByAppendingString:COMMAND];

    PATTERN_STRING = [NSString stringWithFormat:@"^ADVRESP(?:=((?:%@)?))?$", CodelessAdvertisingDataBaseCommand.DATA_PATTERN_STRING]; // <data>
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
        if (self.invalid)
            CodelessLog(TAG, "Received invalid scan response data: %@", response);
        else
            CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "Scan response data: %@", [CodelessUtil hexArrayLog:self.data]);
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid) {
        if (!self.data) {
            self.data = [NSData data];
            CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "No response data");
        }
        [self sendEvent:CodelessLibEvent.ScanResponseData object:[[CodelessScanResponseDataEvent alloc] initWithCommand:self]];
    }
}

@end
