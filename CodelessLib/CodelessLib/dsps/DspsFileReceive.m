/*
 **********************************************************************************
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Copyright (c) 2022-2024 Renesas Electronics Corporation and/or its affiliates
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

#import "DspsFileReceive.h"
#import "CodelessManager.h"
#import "CodelessLibLog.h"
#import "CodelessLibEvent.h"
#import "CodelessLibConfig.h"
#import "DspsRxLogFile.h"
#import <zlib.h>

#define CodelessLogPrefix(TAG, fmt, ...) CodelessLog(TAG, "%@" fmt, self.manager.logPrefix, ##__VA_ARGS__)
#define CodelessLogPrefixOpt(enabled, TAG, fmt, ...) CodelessLogOpt(enabled, TAG, "%@" fmt, self.manager.logPrefix, ##__VA_ARGS__)

@interface DspsFileReceive ()

@property (weak) CodelessManager* manager;
@property NSMutableData* header;
@property NSString* name;
@property int size;
@property int64_t crc;
@property DspsRxLogFile* file;
@property int bytesReceived;
@property uint64_t crc32;
@property BOOL started;
@property BOOL complete;
@property NSTimeInterval startTime;
@property NSTimeInterval endTime;
@property NSTimeInterval lastInterval;
@property int bytesReceivedInterval;
@property int currentSpeed;

@end

@implementation DspsFileReceive

static NSString* const TAG = @"DspsFileReceive";
+ (NSString*) TAG {
    return TAG;
}

- (instancetype) initWithManager:(CodelessManager*)manager {
    self = [super init];
    if (!self)
        return nil;
    self.manager = manager;
    self.crc = -1;
    self.currentSpeed = CodelessManager.SPEED_INVALID;
    return self;
}

- (BOOL) hasCrc {
    return self.crc != -1;
}

- (BOOL) crcOk {
    return self.crc != -1 && self.crc == self.crc32;
}

- (int) averageSpeed {
    NSTimeInterval elapsed = (self.complete ? self.endTime : [NSDate date].timeIntervalSince1970) - self.startTime;
    if (elapsed == 0)
        elapsed = 0.001;
    return (int) (self.bytesReceived / elapsed);
}

/**
 * Performs statistics calculations, called every {@link CodelessLibConfig#DSPS_STATS_INTERVAL}.
 * <p> A {@link CodelessLibEvent#DspsStats DspsStats} event is generated.
 */
- (void) updateStats {
    if (self.complete)
        return;
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    if (now == self.lastInterval)
        now += 0.001;
    self.currentSpeed = (int) (self.bytesReceivedInterval / (now - self.lastInterval));
    self.lastInterval = now;
    self.bytesReceivedInterval = 0;
    [self performSelector:@selector(updateStats) withObject:nil afterDelay:CodelessLibConfig.DSPS_STATS_INTERVAL / 1000.];
    [self sendEvent:CodelessLibEvent.DspsStats object:[[DspsStatsEvent alloc] initWithManager:self.manager operation:self currentSpeed:self.currentSpeed averageSpeed:self.averageSpeed]];
}

- (void) start {
    if (self.started)
        return;
    self.started = true;
    CodelessLogPrefixOpt(CodelessLibLog.DSPS, TAG, "Start file receive");
    [self.manager startFileReceive:self];
}

- (void) stop {
    CodelessLogPrefixOpt(CodelessLibLog.DSPS, TAG, "Stop file receive");
    self.endTime = [NSDate date].timeIntervalSince1970;
    if (self.file)
        [self.file close];
    if (CodelessLibConfig.DSPS_STATS) {
        [NSTimer cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateStats) object:nil];
    }
    [self.manager stopFileReceive:self];
}

- (void) onDspsData:(NSData*)data {
    if (!self.started)
        return;

    // Check for header
    if (!self.file) {
        if (!self.header) {
            self.header = data.mutableCopy;
        } else {
            [self.header appendData:data];
        }
        NSString* headerText = [[NSString alloc] initWithData:self.header encoding:NSASCIIStringEncoding];
        __block NSData* headerData = nil;
        [CodelessLibConfig.DSPS_RX_FILE_HEADER_PATTERN enumerateMatchesInString:headerText options:NSMatchingReportCompletion range:NSMakeRange(0, headerText.length) usingBlock:^(NSTextCheckingResult* result, NSMatchingFlags flags, BOOL* stop) {
            if (result) {
                *stop = true;
                self.name = [headerText substringWithRange:[result rangeAtIndex:2]];
                self.size = [headerText substringWithRange:[result rangeAtIndex:3]].intValue;
                NSString* crcText = [result rangeAtIndex:4].location != NSNotFound ? [headerText substringWithRange:[result rangeAtIndex:4]] : nil;
                if (crcText) {
                    uint32_t crcValue;
                    NSScanner* scanner = [NSScanner scannerWithString:crcText];
                    if ([scanner scanHexInt:&crcValue])
                        self.crc = crcValue;
                }
                int start = [result rangeAtIndex:1].location + [result rangeAtIndex:1].length;
                int end = [result rangeAtIndex:5].location;

                headerData = [self.header subdataWithRange:NSMakeRange(end, self.header.length - end)];
                self.header = [self.header subdataWithRange:NSMakeRange(start, end - start)];

                CodelessLogPrefixOpt(CodelessLibLog.DSPS, TAG, "File receive: %@ size=%d crc=%@", self.name, self.size, self.crc != -1 ? crcText : @"N/A");
                self.startTime = [NSDate date].timeIntervalSince1970;
                if (CodelessLibConfig.DSPS_STATS) {
                    self.lastInterval = self.startTime;
                    [self performSelector:@selector(updateStats) withObject:nil afterDelay:CodelessLibConfig.DSPS_STATS_INTERVAL / 1000.];
                }

                self.file = [[DspsRxLogFile alloc] initWithFileReceive:self];
                [self sendEvent:CodelessLibEvent.DspsRxFileData object:[[DspsRxFileDataEvent alloc] initWithManager:self.manager operation:self size:self.size bytesReceived:self.bytesReceived]];
            } else if ((flags & NSMatchingHitEnd) == 0) {
                self.header = nil;
            }
        }];

        if (headerData)
            data = headerData;
    }

    if (!self.file || data.length == 0)
        return;

    // Write data to file
    if (data.length > self.size - self.bytesReceived)
        data = [NSData dataWithBytes:data.bytes length:self.size - self.bytesReceived];
    self.bytesReceived += data.length;
    self.bytesReceivedInterval += data.length;

    CodelessLogPrefixOpt(CodelessLibLog.DSPS_FILE_CHUNK, TAG, "File receive: %@ %d of %d", self.name, self.bytesReceived, self.size);
    [self.file log:data];
    if (self.crc != -1)
        self.crc32 = crc32(self.crc32, data.bytes, data.length);

    if (self.bytesReceived == self.size) {
        CodelessLogPrefixOpt(CodelessLibLog.DSPS, TAG, "File received: %@", self.name);
        self.complete = true;
        self.endTime = [NSDate date].timeIntervalSince1970;
        if (CodelessLibConfig.DSPS_STATS) {
            [NSTimer cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateStats) object:nil];
            [self sendEvent:CodelessLibEvent.DspsStats object:[[DspsStatsEvent alloc] initWithManager:self.manager operation:self currentSpeed:self.currentSpeed averageSpeed:self.averageSpeed]];
        }
        [self.file close];
        [self.manager stopFileReceive:self];
    }

    [self sendEvent:CodelessLibEvent.DspsRxFileData object:[[DspsRxFileDataEvent alloc] initWithManager:self.manager operation:self size:self.size bytesReceived:self.bytesReceived]];
    if (self.complete && self.crc != -1) {
        BOOL ok = self.crc == self.crc32;
        CodelessLogPrefix(TAG, "Received file CRC %@: %@", ok ? @"OK" : @"error", self.name);
        [self sendEvent:CodelessLibEvent.DspsRxFileCrc object:[[DspsRxFileCrcEvent alloc] initWithManager:self.manager operation:self ok:ok]];
    }
}

- (void) sendEvent:(NSString*)event object:(CodelessEvent*)object {
    [NSNotificationCenter.defaultCenter postNotificationName:event object:self.manager userInfo:@{ @"event" : object }];
}

@end
