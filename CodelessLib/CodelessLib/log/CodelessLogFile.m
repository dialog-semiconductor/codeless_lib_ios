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

#import "CodelessLogFile.h"
#import "CodelessProfile.h"
#import "CodelessLibConfig.h"

@implementation CodelessLogFile

static NSString* const TAG = @"CodelessLogFile";
+ (NSString*) TAG {
    return TAG;
}

- (instancetype) initWithManager:(CodelessManager*)manager {
    return self = [super initWithManager:manager prefix:CodelessLibConfig.CODELESS_LOG_FILE_PREFIX];
}

- (NSString*) TAG {
    return TAG;
}

- (void) log:(NSString*)line {
    if (self.closed)
        return;
    if (!self.file && ![self create])
        return;
    [self.file writeData:[[line stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    if (CodelessLibConfig.CODELESS_LOG_FLUSH) {
        if (@available(ios 13, *))
            [self.file synchronizeAndReturnError:nil];
        else
            [self.file synchronizeFile];
    }
}

- (void) logLine:(CodelessLine*)line {
    [self log:[(line.isOutbound ? CodelessLibConfig.CODELESS_LOG_PREFIX_OUTBOUND : CodelessLibConfig.CODELESS_LOG_PREFIX_INBOUND) stringByAppendingString:line.text]];

}

- (void) logText:(NSString*)text {
    [self log:[CodelessLibConfig.CODELESS_LOG_PREFIX_TEXT stringByAppendingString:text]];
}

@end
