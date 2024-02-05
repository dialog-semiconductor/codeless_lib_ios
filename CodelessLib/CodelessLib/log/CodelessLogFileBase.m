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

#import "CodelessLogFileBase.h"
#import "CodelessManager.h"
#import "CodelessLibConfig.h"
#import "CodelessLibLog.h"
#import "DspsFileReceive.h"

@implementation CodelessLogFileBase

static NSString* const TAG = @"CodelessLogFileBase";
+ (NSString*) TAG {
    return TAG;
}

- (instancetype) initWithManager:(CodelessManager*)manager prefix:(NSString*)prefix {
    self = [super init];
    if (!self)
        return nil;

    self.name = [prefix stringByAppendingString:[CodelessLibConfig.LOG_FILE_DATE stringFromDate:[NSDate date]]];
    if (CodelessLibConfig.LOG_FILE_ADDRESS_SUFFIX)
        self.name = [[self.name stringByAppendingString:@"_"] stringByAppendingString:manager.device.identifier.UUIDString];
    self.name = [self.name stringByAppendingString:CodelessLibConfig.LOG_FILE_EXTENSION];

    NSFileManager* fileManager = NSFileManager.defaultManager;
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path = [paths[0] stringByAppendingPathComponent:CodelessLibConfig.LOG_FILE_PATH];
    self.path = [path stringByAppendingPathComponent:self.name];
    NSError* error;
    if (![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
        CodelessLog(self.TAG, "Failed to create log path: %@ %@", path, error);
        self.closed = true;
    }

    return self;
}

- (instancetype) initWithFileReceive:(DspsFileReceive*)dspsFileReceive {
    self = [super init];
    if (!self)
        return nil;

    self.name = dspsFileReceive.name;

    NSFileManager* fileManager = NSFileManager.defaultManager;
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path = [paths[0] stringByAppendingPathComponent:CodelessLibConfig.DSPS_RX_FILE_PATH];
    self.path = [path stringByAppendingPathComponent:self.name];
    NSError* error;
    if (![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
        CodelessLog(self.TAG, "Failed to create DSPS RX file path: %@ %@", path, error);
        self.closed = true;
    }

    return self;
}

- (NSString*) TAG {
    return TAG;
}

- (BOOL) create {
    if (![NSFileManager.defaultManager createFileAtPath:self.path contents:nil attributes:nil]) {
        self.closed = true;
    } else {
        self.file = [NSFileHandle fileHandleForWritingAtPath:self.path];
        if (!self.file)
            self.closed = true;
    }
    return !self.closed;
}

- (void) close {
    if (self.file) {
        if (@available(ios 13, *))
            [self.file closeAndReturnError:nil];
        else
            [self.file closeFile];
    }
    self.closed = true;
}

@end
