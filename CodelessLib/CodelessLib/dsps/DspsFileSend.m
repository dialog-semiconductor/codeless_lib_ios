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

#import "DspsFileSend.h"
#import "CodelessManager.h"
#import "CodelessLibLog.h"
#import "CodelessLibEvent.h"
#import "CodelessLibConfig.h"

#define CodelessLogPrefixOpt(enabled, TAG, fmt, ...) CodelessLogOpt(enabled, TAG, "%@" fmt, self.manager.logPrefix, ##__VA_ARGS__)

@interface DspsFileSend ()

@property (weak) CodelessManager* manager;
@property NSString* file;
@property int chunkSize;
@property NSArray<NSData*>* chunks;
@property int totalChunks;
@property int period;
@property BOOL started;
@property BOOL complete;
@property NSTimeInterval startTime;
@property NSTimeInterval endTime;
@property int bytesSent;
@property NSTimeInterval lastInterval;
@property int bytesSentInterval;
@property int currentSpeed;

@end

@implementation DspsFileSend

static NSString* const TAG = @"DspsFileSend";
+ (NSString*) TAG {
    return TAG;
}

- (instancetype) initWithManager:(CodelessManager*)manager file:(NSString*)file chunkSize:(int)chunkSize period:(int)period {
    self = [super init];
    if (!self)
        return nil;
    self.manager = manager;
    self.file = file;
    self.chunkSize = MIN(chunkSize, manager.dspsChunkSize);
    self.period = period;
    self.currentSpeed = CodelessManager.SPEED_INVALID;
    [self loadFile];
    return self;
}

- (instancetype) initWithManager:(CodelessManager*)manager file:(NSString*)file period:(int)period {
    return self = [self initWithManager:manager file:file chunkSize:manager.dspsChunkSize period:period];
}

- (instancetype) initWithManager:(CodelessManager*)manager file:(NSString*)file {
    return self = [self initWithManager:manager file:file chunkSize:manager.dspsChunkSize period:-1];
}

- (NSData*) getCurrentChunk {
    return self.chunks[self.chunk];
}

- (void) setResumeChunk:(int)chunk {
    self.chunk = self.period > 0 ? MIN(chunk - 1, self.chunk) : chunk;
}

- (void) setComplete {
    self.complete = true;
    self.endTime = [NSDate date].timeIntervalSince1970;
    if (CodelessLibConfig.DSPS_STATS) {
        [NSTimer cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateStats) object:nil];
        [self sendEvent:CodelessLibEvent.DspsStats object:[[DspsStatsEvent alloc] initWithManager:self.manager operation:self currentSpeed:self.currentSpeed averageSpeed:self.averageSpeed]];
    }
}

- (int) averageSpeed {
    NSTimeInterval elapsed = (self.complete ? self.endTime : [NSDate date].timeIntervalSince1970) - self.startTime;
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
    if (self.complete)
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

/**
 * Loads the selected file and splits its data into chunks.
 * <p> If the file fails to load, a {@link CodelessLibEvent#DspsFileError DspsFileError} event is generated.
 */
- (void) loadFile {
    CodelessLogOpt(CodelessLibLog.DSPS, TAG, "Load file: %@", self.file);

    NSError* error;
    NSData* data = [NSData dataWithContentsOfFile:self.file options:0 error:&error];
    if (error)
        CodelessLog(TAG, "Failed to load file: %@ %@", self.file, error);
    if (!data || data.length == 0) {
        [self sendEvent:CodelessLibEvent.DspsFileError object:[[DspsFileErrorEvent alloc] initWithManager:self.manager operation:self]];
        return;
    }

    self.totalChunks = data.length / self.chunkSize + (data.length % self.chunkSize != 0 ? 1 : 0);
    NSMutableArray* chunks = [NSMutableArray arrayWithCapacity:self.totalChunks];
    for (int i = 0; i < data.length; i += self.chunkSize) {
        [chunks addObject:[NSData dataWithBytes:(uint8_t*)data.bytes + i length:MIN(self.chunkSize, data.length - i)]];
    }
    self.chunks = [NSArray arrayWithArray:chunks];
}

- (BOOL) isLoaded {
    return self.chunks != nil;
}

- (void) start {
    if (self.started)
        return;
    self.started = true;
    CodelessLogPrefixOpt(CodelessLibLog.DSPS, TAG, "Start file send: %@", self);
    self.chunk = -1;
    self.startTime = [NSDate date].timeIntervalSince1970;
    if (CodelessLibConfig.DSPS_STATS) {
        self.lastInterval = self.startTime;
        [self performSelector:@selector(updateStats) withObject:nil afterDelay:CodelessLibConfig.DSPS_STATS_INTERVAL / 1000.];
    }
    [self.manager startFile:self resume:false];
}

- (void) stop {
    CodelessLogPrefixOpt(CodelessLibLog.DSPS, TAG, "Stop file send: %@", self);
    self.endTime = [NSDate date].timeIntervalSince1970;
    if (CodelessLibConfig.DSPS_STATS) {
        [NSTimer cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateStats) object:nil];
    }
    [self.manager stopFile:self];
}

- (void) sendChunk {
    self.chunk++;
    CodelessLogPrefixOpt(CodelessLibLog.DSPS_FILE_CHUNK, TAG, "Queue file chunk: %@ %d of %d", self, self.chunk + 1, self.totalChunks);
    [self.manager sendFileData:self];
    if (self.chunk < self.totalChunks - 1)
        [self performSelector:@selector(sendChunk) withObject:nil afterDelay:self.period / 1000.];
}

- (void) sendEvent:(NSString*)event object:(CodelessEvent*)object {
    [NSNotificationCenter.defaultCenter postNotificationName:event object:self.manager userInfo:@{ @"event" : object }];
}

- (NSString*) description {
    return self.file.lastPathComponent;
}

@end
