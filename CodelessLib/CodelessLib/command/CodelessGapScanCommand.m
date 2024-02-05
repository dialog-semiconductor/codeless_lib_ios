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

#import "CodelessGapScanCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@implementation CodelessGapScanCommand

static NSString* const TAG = @"GapScanCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"GAPSCAN";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_GAPSCAN;

static NSString* RESPONSE_PATTERN_STRING = @"^\\( \\) ((?:[0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}),([PR]), Type: (\\bADV\\b|\\bRSP\\b), RSSI:(-?\\d+)$"; // <address> <type> <typeScan> <rssi>
static NSRegularExpression* RESPONSE_PATTERN;

static NSString* PATTERN_STRING = @"^GAPSCAN$";
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessGapScanCommand.class)
        return;

    NAME = [CodelessProfile.PREFIX_LOCAL stringByAppendingString:COMMAND];

    NSError* responsePatternError = nil;
    RESPONSE_PATTERN = [NSRegularExpression regularExpressionWithPattern:RESPONSE_PATTERN_STRING options:0 error:&responsePatternError];

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

+ (NSString*) RESPONSE_PATTERN_STRING {
    return RESPONSE_PATTERN_STRING;
}

+ (NSRegularExpression*) RESPONSE_PATTERN {
    return RESPONSE_PATTERN;
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
    if (!self.devices)
        self.devices = [NSMutableArray array];
    CodelessGapScannedDevice* device = [[CodelessGapScannedDevice alloc] init];
    NSTextCheckingResult* matcher = [RESPONSE_PATTERN firstMatchInString:response options:0 range:NSMakeRange(0, response.length)];
    if (![response containsString:@"Scanning"] && ![response containsString:@"Scan Completed"] && !matcher) {
        self.invalid = true;
    } else if (![response containsString:@"Scanning"] && ![response containsString:@"Scan Completed"]) {
        device.address = [response substringWithRange:[matcher rangeAtIndex:1]];
        device.addressType = [[response substringWithRange:[matcher rangeAtIndex:2]] isEqualToString:CODELESS_COMMAND_GAP_ADDRESS_TYPE_PUBLIC_STRING] ? CODELESS_COMMAND_GAP_ADDRESS_TYPE_PUBLIC : CODELESS_COMMAND_GAP_ADDRESS_TYPE_RANDOM;
        device.type = [[response substringWithRange:[matcher rangeAtIndex:3]] isEqualToString:CODELESS_COMMAND_GAP_SCAN_TYPE_ADV_STRING] ? CODELESS_COMMAND_GAP_SCAN_TYPE_ADV : CODELESS_COMMAND_GAP_SCAN_TYPE_RSP;
        NSScanner* scanner = [NSScanner scannerWithString:[response substringWithRange:[matcher rangeAtIndex:4]]];
        int num;
        if (![scanner scanInt:&num]) {
            self.invalid = true;
        } else {
            device.rssi = num;
            [self.devices addObject:device];
        }
    }
    if (self.invalid)
        CodelessLog(TAG, "Received invalid scan response: %@", response);
    else
        CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "Scanned device: Address:%@ Address type:%@ Type:%@ RSSI:%d", device.address, (device.addressType == CODELESS_COMMAND_GAP_ADDRESS_TYPE_PUBLIC ? CODELESS_COMMAND_GAP_ADDRESS_TYPE_PUBLIC_STRING : CODELESS_COMMAND_GAP_ADDRESS_TYPE_RANDOM_STRING), (device.type == CODELESS_COMMAND_GAP_SCAN_TYPE_ADV ? CODELESS_COMMAND_GAP_SCAN_TYPE_ADV_STRING : CODELESS_COMMAND_GAP_SCAN_TYPE_RSP_STRING), device.rssi);
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid)
        [self sendEvent:CodelessLibEvent.GapScanResult object:[[CodelessGapScanResultEvent alloc] initWithCommand:self]];
}

@end
