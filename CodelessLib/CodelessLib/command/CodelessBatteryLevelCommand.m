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

#import <UIKit/UIKit.h>
#import "CodelessBatteryLevelCommand.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"

@implementation CodelessBatteryLevelCommand

static NSString* const TAG = @"BatteryLevelCommand";
+ (NSString*) TAG {
    return TAG;
}

static NSString* COMMAND = @"BATT";
static NSString* NAME;
static const int ID = CODELESS_COMMAND_ID_BATT;

static NSString* PATTERN_STRING = @"^BATT$";
static NSRegularExpression* PATTERN;

+ (void) initialize {
    if (self != CodelessBatteryLevelCommand.class)
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
    self.level = -1;
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
        NSScanner* scanner = [NSScanner scannerWithString:response];
        int num;
        if (![scanner scanInt:&num]) {
            CodelessLog(TAG, "Received invalid battery level: %@", response);
            self.invalid = true;
            return;
        }
        self.level = num;
        CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "Battery level: %d", self.level);
    }
}

- (void) onSuccess {
    [super onSuccess];
    if (self.isValid)
        [self sendEvent:CodelessLibEvent.BatteryLevel object:[[CodelessBatteryLevelEvent alloc] initWithCommand:self]];
}

- (void) processInbound {
    if (self.level == -1)
        self.level = [self getBatteryLevel];
    if (self.level != -1) {
        CodelessLogOpt(CodelessLibLog.COMMAND, TAG, "Send battery level: %d", self.level);
        [self sendSuccess:@(self.level).stringValue];
    } else {
        CodelessLog(TAG, "Failed to retrieve battery level");
        [self sendError:@"Battery level not available"];
    }
}

/// Returns the host device battery level.
- (int) getBatteryLevel {
    BOOL batteryMonitoring = UIDevice.currentDevice.isBatteryMonitoringEnabled;
    UIDevice.currentDevice.batteryMonitoringEnabled = YES;
    int level = UIDevice.currentDevice.batteryState != UIDeviceBatteryStateUnknown ? (int) (UIDevice.currentDevice.batteryLevel * 100) : -1;
    UIDevice.currentDevice.batteryMonitoringEnabled = batteryMonitoring;
    return level;
}

@end
