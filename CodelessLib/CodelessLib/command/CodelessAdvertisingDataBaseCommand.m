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

#import "CodelessAdvertisingDataBaseCommand.h"
#import "CodelessProfile.h"
#import "CodelessUtil.h"

@interface CodelessAdvertisingDataBaseCommand ()

/// <code>true</code> if the command has arguments, <code>false</code> for no arguments.
@property BOOL hasArguments;

@end

@implementation CodelessAdvertisingDataBaseCommand

static NSString* DATA_PATTERN_STRING = @"(?:[0-9a-fA-F]{2}:)*[0-9a-fA-F]{2}";

static NSString* RESPONSE_PATTERN_STRING;
static NSRegularExpression* RESPONSE_PATTERN;

static NSString* DATA_ARGUMENT_PATTERN_STRING;
static NSRegularExpression* DATA_ARGUMENT_PATTERN;

+ (void) initialize {
    if (self != CodelessAdvertisingDataBaseCommand.class)
        return;

    RESPONSE_PATTERN_STRING = [NSString stringWithFormat:@"^(%@)$", DATA_PATTERN_STRING]; // <data>
    NSError* responseError = nil;
    RESPONSE_PATTERN = [NSRegularExpression regularExpressionWithPattern:RESPONSE_PATTERN_STRING options:0 error:&responseError];

    DATA_ARGUMENT_PATTERN_STRING = [NSString stringWithFormat:@"^(?:%@)$", DATA_PATTERN_STRING];
    NSError* dataArgumentError = nil;
    DATA_ARGUMENT_PATTERN = [NSRegularExpression regularExpressionWithPattern:DATA_ARGUMENT_PATTERN_STRING options:0 error:&dataArgumentError];
}

+ (NSString*) DATA_PATTERN_STRING {
    return DATA_PATTERN_STRING;
}

+ (NSString*) RESPONSE_PATTERN_STRING {
    return RESPONSE_PATTERN_STRING;
}

+ (NSRegularExpression*) RESPONSE_PATTERN {
    return RESPONSE_PATTERN;
}

+ (NSString*) DATA_ARGUMENT_PATTERN_STRING {
    return DATA_ARGUMENT_PATTERN_STRING;
}

+ (NSRegularExpression*) DATA_ARGUMENT_PATTERN {
    return DATA_ARGUMENT_PATTERN;
}

+ (BOOL) validData:(NSString*)data {
    return [DATA_ARGUMENT_PATTERN firstMatchInString:data options:0 range:NSMakeRange(0, data.length)] != nil;
}

- (instancetype) initWithManager:(CodelessManager*)manager data:(NSData*)data {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.data = data;
    self.hasArguments = true;
    return self;
}

- (NSString*) getArguments {
    return self.hasArguments ? [[CodelessUtil hexArray:self.data uppercase:true brackets:false] stringByReplacingOccurrencesOfString:@" " withString:@":"] : nil;
}

- (void) parseResponse:(NSString*)response {
    [super parseResponse:response];
    if (self.responseLine == 1) {
        NSTextCheckingResult* matcher = [RESPONSE_PATTERN firstMatchInString:response options:0 range:NSMakeRange(0, response.length)];
        if (matcher) {
            self.data = [CodelessUtil hex2bytes:response];
            if (!self.data)
                self.invalid = true;
        } else {
            self.invalid = true;
        }
    }
}

- (BOOL) checkArgumentsCount {
    int count = [CodelessProfile countArguments:self.command split:@","];
    return count == 0 || count == 1;
}

- (NSString*) parseArguments {
    if (![CodelessProfile hasArguments:self.command])
        return nil;
    self.hasArguments = true;

    NSString* value = [self.command substringWithRange:[self.matcher rangeAtIndex:1]];
    if ([DATA_ARGUMENT_PATTERN firstMatchInString:value options:0 range:NSMakeRange(0, value.length)]) {
        self.data = [CodelessUtil hex2bytes:value];
        return nil;
    } else {
        return @"Invalid advertising data";
    }

    return nil;
}

- (NSString*) getDataString {
    return [CodelessUtil hexArray:self.data uppercase:true brackets:false];
}

@end
