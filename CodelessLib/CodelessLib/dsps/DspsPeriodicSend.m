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

#import "DspsPeriodicSend.h"
#import "CodelessManager.h"
#import "CodelessLibConfig.h"
#import "CodelessLibLog.h"
#import "CodelessUtil.h"
#import "CodelessLibEvent.h"

#define CodelessLogPrefixOpt(enabled, TAG, fmt, ...) CodelessLogOpt(enabled, TAG, "%@" fmt, self.manager.logPrefix, ##__VA_ARGS__)

@interface DspsPeriodicSend ()

@property (weak) CodelessManager* manager;
@property int period;
@property NSData* data;
@property int chunkSize;
@property BOOL active;
@property int count;
@property BOOL pattern;
@property int patternMaxCount;
@property NSString* patternFormat;
@property NSTimeInterval startTime;
@property NSTimeInterval endTime;
@property int bytesSent;
@property NSTimeInterval lastInterval;
@property int bytesSentInterval;
@property int currentSpeed;

@end

@implementation DspsPeriodicSend

static NSString* const TAG = @"DspsPeriodicSend";
+ (NSString*) TAG {
    return TAG;
}

- (instancetype) initWithManager:(CodelessManager*)manager period:(int)period data:(NSData*)data chunkSize:(int)chunkSize {
    self = [super init];
    if (!self)
        return nil;
    self.manager = manager;
    self.period = period;
    self.data = data;
    self.chunkSize = chunkSize;
    self.currentSpeed = CodelessManager.SPEED_INVALID;
    return self;
}

- (instancetype) initWithManager:(CodelessManager*)manager period:(int)period data:(NSData*)data {
    return self = [self initWithManager:manager period:period data:data chunkSize:manager.dspsChunkSize];
}

- (instancetype) initWithManager:(CodelessManager*)manager period:(int)period text:(NSString*)text chunkSize:(int)chunkSize {
    return self = [self initWithManager:manager period:period data:[text dataUsingEncoding:CodelessLibConfig.CHARSET] chunkSize:chunkSize];
}

- (instancetype) initWithManager:(CodelessManager*)manager period:(int)period text:(NSString*)text {
    return self = [self initWithManager:manager period:period text:text chunkSize:manager.dspsChunkSize];
}

- (instancetype) initWithManager:(CodelessManager*)manager file:(NSString*)file chunkSize:(int)chunkSize period:(int)period {
    self = [super init];
    if (!self)
        return nil;
    self.manager = manager;
    self.chunkSize = MAX(MIN(chunkSize, manager.dspsChunkSize), CodelessLibConfig.DSPS_PATTERN_DIGITS + (int) (CodelessLibConfig.DSPS_PATTERN_SUFFIX ? CodelessLibConfig.DSPS_PATTERN_SUFFIX.length : 0));
    self.period = period;
    self.currentSpeed = CodelessManager.SPEED_INVALID;
    self.pattern = true;
    self.patternMaxCount = (int) pow(10, CodelessLibConfig.DSPS_PATTERN_DIGITS);
    self.patternFormat = [NSString stringWithFormat:@"%%0%dd", CodelessLibConfig.DSPS_PATTERN_DIGITS];
    [self loadPattern:file];
    return self;
}

- (instancetype) initWithManager:(CodelessManager*)manager file:(NSString*)file period:(int)period {
    return self = [self initWithManager:manager file:file chunkSize:manager.dspsChunkSize period:period];
}

- (void) setResumeCount:(int)count {
    self.count = count - 1;
}

- (int) getPatternCount {
    return (self.count - 1) % self.patternMaxCount;
}

- (int) averageSpeed {
    NSTimeInterval elapsed = (!self.active ? self.endTime : [NSDate date].timeIntervalSince1970) - self.startTime;
    if (elapsed == 0)
        elapsed = 0.001;
    return (int) (self.bytesSent / elapsed);
}

- (void) updateBytesSent:(int)bytes {
    self.bytesSent += bytes;
    self.bytesSentInterval += bytes;
}

/**
 * Performs statistics calculations, called every {@link CodelessLibConfig#DSPS_STATS_INTERVAL}.
 * <p> A {@link CodelessLibEvent#DspsStats DspsStats} event is generated.
 */
- (void) updateStats {
    if (!self.active)
        return;
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    if (now == self.lastInterval)
        now += 0.001;
    self.currentSpeed = (int) (self.bytesSentInterval / (now - self.lastInterval));
    self.lastInterval = now;
    self.bytesSentInterval = 0;
    [self performSelector:@selector(updateStats) withObject:nil afterDelay:CodelessLibConfig.DSPS_STATS_INTERVAL / 1000.];
    [self sendEvent:CodelessLibEvent.DspsStats object:[[DspsStatsEvent alloc] initWithManager:self.manager operation:self currentSpeed:self.currentSpeed averageSpeed:self.averageSpeed]];
}

- (void) start {
    if (self.active)
        return;
    self.active = true;
    CodelessLogPrefixOpt(CodelessLibLog.DSPS, TAG, "Start periodic send%@: period=%dms %@", self.pattern ? @" (pattern)" : @"", self.period, [CodelessUtil hexArrayLog:self.data]);
    self.count = 0;
    self.startTime = [NSDate date].timeIntervalSince1970;
    if (CodelessLibConfig.DSPS_STATS) {
        self.lastInterval = self.startTime;
        [self performSelector:@selector(updateStats) withObject:nil afterDelay:CodelessLibConfig.DSPS_STATS_INTERVAL / 1000.];
    }
    [self.manager startPeriodic:self];
}

- (void) stop {
    self.active = false;
    CodelessLogPrefixOpt(CodelessLibLog.DSPS, TAG, "Stop periodic send%@: period=%dms %@", self.pattern ? @" (pattern)" : @"", self.period, [CodelessUtil hexArrayLog:self.data]);
    self.endTime = [NSDate date].timeIntervalSince1970;
    if (CodelessLibConfig.DSPS_STATS) {
        [NSTimer cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateStats) object:nil];
    }
    [self.manager stopPeriodic:self];
}

- (void) sendData {
    self.count++;
    if (self.pattern) {
        NSData* patternBytes = [[NSString stringWithFormat:self.patternFormat, [self getPatternCount]] dataUsingEncoding:CodelessLibConfig.CHARSET];
        int position = self.data.length - CodelessLibConfig.DSPS_PATTERN_DIGITS - (CodelessLibConfig.DSPS_PATTERN_SUFFIX ? CodelessLibConfig.DSPS_PATTERN_SUFFIX.length : 0);
        memcpy((uint8_t*)((NSMutableData*)self.data).mutableBytes + position, patternBytes.bytes, CodelessLibConfig.DSPS_PATTERN_DIGITS);
    }
    CodelessLogPrefixOpt(CodelessLibLog.DSPS_PERIODIC_CHUNK, TAG, "Queue periodic data (%d): %@", self.count, [CodelessUtil hexArrayLog:self.data]);
    [self.manager sendPeriodicData:self];
    [self performSelector:@selector(sendData) withObject:nil afterDelay:self.period / 1000.];
}

/**
 * Loads the pattern prefix from the selected file.
 * <p> If the pattern fails to load, a {@link CodelessLibEvent#DspsPatternFileError DspsPatternFileError} event is generated.
 * @param file  the selected file
 */
- (void) loadPattern:(NSString*)file {
    CodelessLogOpt(CodelessLibLog.DSPS, TAG, "Load pattern: %@", file);

    NSError* error;
    NSData* pattern = [NSData dataWithContentsOfFile:file options:0 error:&error];
    if (error) {
        CodelessLog(TAG, "Failed to load file: %@ %@", file, error);
        [self sendEvent:CodelessLibEvent.DspsPatternFileError object:[[DspsPatternFileErrorEvent alloc] initWithManager:self.manager operation:self file:file]];
        return;
    }

    int suffixLength = CodelessLibConfig.DSPS_PATTERN_SUFFIX ? CodelessLibConfig.DSPS_PATTERN_SUFFIX.length : 0;
    pattern = [NSData dataWithBytes:pattern.bytes length:MIN(pattern.length, self.chunkSize - CodelessLibConfig.DSPS_PATTERN_DIGITS - suffixLength)];

    self.data = [NSMutableData dataWithLength:pattern.length + CodelessLibConfig.DSPS_PATTERN_DIGITS + suffixLength];
    self.chunkSize = self.data.length;
    uint8_t* data = ((NSMutableData*)self.data).mutableBytes;
    memcpy(data, pattern.bytes, pattern.length);
    if (CodelessLibConfig.DSPS_PATTERN_SUFFIX)
        memcpy(data + self.data.length - suffixLength, CodelessLibConfig.DSPS_PATTERN_SUFFIX.bytes, suffixLength);
}

- (BOOL) isLoaded {
    return self.data != nil;
}

- (void) sendEvent:(NSString*)event object:(CodelessEvent*)object {
    [NSNotificationCenter.defaultCenter postNotificationName:event object:self.manager userInfo:@{ @"event" : object }];
}

@end
