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

#import <Foundation/Foundation.h>

@class CodelessManager;

NS_ASSUME_NONNULL_BEGIN

/**
 * DSPS file send operation.
 *
 * ## Usage ##
 * Use one of the {@link CodelessManager#sendFile:chunkSize:period: sendFile} methods to create and {@link #start}
 * a DSPS file send operation.
 *
 * The file is split into chunks based on the specified {@link #chunkSize chunk size}.
 * The chunk size must not exceed the value (MTU - 3), otherwise chunks will be truncated when sent.
 * The chunks are enqueued to be sent, one every the specified {@link #period}.
 * If the period is 0, all chunks are enqueued at once, which may be slower for large files.
 *
 * If the file fails to load, a {@link CodelessLibEvent#DspsFileError DspsFileError} event is generated.
 * A {@link CodelessLibEvent#DspsFileChunk DspsFileChunk} event is generated for each chunk that is sent to the peer device.
 * Use {@link #stop} to stop the operation. If {@link CodelessLibConfig#DSPS_STATS statistics} are enabled,
 * a {@link CodelessLibEvent#DspsStats DspsStats} event is generated every {@link CodelessLibConfig#DSPS_STATS_INTERVAL}.
 * @see CodelessManager
 */
@interface DspsFileSend : NSObject

@property (class, readonly) NSString* TAG;

/// The associated manager.
@property (weak, readonly) CodelessManager* manager;
/// The file to send.
@property (readonly) NSString* file;
/// The chunk size.
@property (readonly) int chunkSize;
/// The file chunks.
@property (readonly) NSArray<NSData*>* chunks;
/// The current chunk index (0-based).
/// <p> Current chunk is the last chunk that was enqueued.
@property int chunk;
/// The number of sent chunks.
/// <p> Set by the library when a chunk is sent to the peer device.
@property int sentChunks;
/// The total number of chunks.
@property (readonly) int totalChunks;
/// The file send operation period (ms).
@property (readonly) int period;
/// <code>true</code> if the operation has started.
@property (readonly) BOOL started;
/// <code>true</code> if the operation is complete.
@property (readonly) BOOL complete;
/// The operation start time.
@property (readonly) NSTimeInterval startTime;
/// The operation end time.
@property (readonly) NSTimeInterval endTime;
/// The total number of sent bytes.
/// <p> Available only if {@link CodelessLibConfig#DSPS_STATS statistics} are enabled.
@property (readonly) int bytesSent;
/// The calculated current speed.
/// <p> Available only if {@link CodelessLibConfig#DSPS_STATS statistics} are enabled.
@property (readonly) int currentSpeed;

/**
 * Creates a DSPS file send operation.
 * @param manager   the associated manager
 * @param file      the file to send
 * @param chunkSize the chunk size to use when splitting the file
 * @param period    the chunks enqueueing period (ms).
 *                  Set to 0 to enqueue all chunks (may be slower for large files).
 */
- (instancetype) initWithManager:(CodelessManager*)manager file:(NSString*)file chunkSize:(int)chunkSize period:(int)period;
/**
 * Creates a DSPS file send operation, using the manager's chunk size.
 * @param manager   the associated manager
 * @param file      the file to send
 * @param period    the chunks enqueueing period (ms).
 *                  Set to 0 to enqueue all chunks (may be slower for large files).
 */
- (instancetype) initWithManager:(CodelessManager*)manager file:(NSString*)file period:(int)period;
/**
 * Creates a DSPS file send operation, using the manager's chunk size.
 * <p> All chunks are enqueued at once (may be slower for large files).
 * @param manager   the associated manager
 * @param file      the file to send
 */
- (instancetype) initWithManager:(CodelessManager*)manager file:(NSString*)file;

/// Returns the current chunk.
- (NSData*) getCurrentChunk;
/**
 * Sets the chunk index (0-based) from which the operation will resume.
 * <p> Used by the library to resume the operation after it was paused.
 * @param chunk the resume chunk index
 */
- (void) setResumeChunk:(int)chunk;
/**
 * Completes the file send operation.
 * <p> Called by the library when the last chunk is sent to the peer device.
 */
- (void) setComplete;
/**
 * Returns the calculated average speed for the duration of the file send operation.
 * <p> Available only if {@link CodelessLibConfig#DSPS_STATS statistics} are enabled.
 */
- (int) averageSpeed;
/**
 * Updates the byte counters used in statistics calculations.
 * @param bytes the number of sent bytes
 */
- (void) updateBytesSent:(int)bytes;
/// Checks if the file is loaded properly.
- (BOOL) isLoaded;
/**
 * Starts the file send operation.
 * @see CodelessManager#sendFile:chunkSize:period:
 */
- (void) start;
/// Stops the file send operation.
- (void) stop;
/// Enqueues the next file chunk for sending, called every {@link period}.
- (void) sendChunk;

@end

NS_ASSUME_NONNULL_END
