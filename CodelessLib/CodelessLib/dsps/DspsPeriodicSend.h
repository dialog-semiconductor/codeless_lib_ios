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
 * DSPS periodic send operation.
 *
 * ## Usage ##
 * There are two types of periodic send operations.
 *
 * For both types, if {@link CodelessLibConfig#DSPS_STATS statistics} are enabled, a {@link CodelessLibEvent#DspsStats DspsStats}
 * event is generated every {@link CodelessLibConfig#DSPS_STATS_INTERVAL}.
 *
 * ### Data packet periodic send ###
 * In this type of  periodic send, the data to send are specified initially and remain the same for all packets.
 * Each packet may be split into chunks if its size exceeds the specified {@link #chunkSize chunk size}.
 * Every {@link #period}, a packet (with all its chunks) is enqueued to be sent to the peer device.
 *
 * Use one of the constructors to initialize the operation. Use {@link #start} to start the periodic operation,
 * which will run until {@link #stop} is called.
 *
 * ### Pattern packet periodic send ###
 * In this type of periodic send, the packet to send consists of a prefix, which is read from the start of the specified file,
 * and a number suffix which changes for each packet. The packet size is equal to the specified {@link #chunkSize chunk size}
 * (unless the file size is less than that). The number suffix has a constant length of {@link CodelessLibConfig#DSPS_PATTERN_DIGITS}.
 * {@link CodelessLibConfig#DSPS_PATTERN_SUFFIX} can be used to add extra data after the number (for example, a new line character).
 * The number suffix counts all numbers from 0 to the maximum allowed by its length and wraps around.
 * Every {@link #period}, a packet (single chunk) with the next suffix is enqueued to be sent to the peer device.
 *
 * Use one of the {@link CodelessManager#sendPattern:chunkSize:period: sendPattern} methods to create and {@link #start} the operation,
 * which will run until {@link #stop} is called. If the pattern fails to load, a {@link CodelessLibEvent#DspsPatternFileError DspsPatternFileError}
 * event is generated. A {@link CodelessLibEvent#DspsPatternChunk DspsPatternChunk} event is generated for each packet that is sent to the peer device.
 *
 * For example, if the pattern file contains the text "abcdefgh" and 4 digits with end of line are used,
 * the pattern will be the following, with one packet sent per line:
 * <blockquote><pre>
 * abcdefgh0000
 * abcdefgh0001
 * abcdefgh0002
 * ...
 * abcdefgh9998
 * abcdefgh9999
 * abcdefgh0000
 * ...</pre></blockquote>
 *
 * @see CodelessManager
 */
@interface DspsPeriodicSend : NSObject

@property (class, readonly) NSString* TAG;

/// The associated manager.
@property (weak, readonly) CodelessManager* manager;
/// The period of the periodic send operation (ms).
@property (readonly) int period;
/// The data packet that is sent periodically.
/// <p> When a pattern is used, this contains the last packet that was enqueued, which has the latest number suffix.
@property (readonly) NSData* data;
/// The chunk size.
@property (readonly) int chunkSize;
/// <code>true</code> if the operation is active.
@property (readonly) BOOL active;
/// The counter of periodic packets that have been enqueued or sent.
@property (readonly) int count;
/// <code>true</code> if this is a pattern operation.
@property (readonly) BOOL pattern;
/// The maximum value of the pattern counter.
/// <p> The pattern counter will wrap around to 0 after the maximum is reached.
@property (readonly) int patternMaxCount;
/// The pattern counter of the last sent packet.
/// <p> Set by the library when a pattern packet is sent to the peer device.
@property int patternSentCount;
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
 * Creates a DSPS periodic send operation, which sends a data packet periodically to the peer device.
 * @param manager   the associated manager
 * @param period    the packet enqueueing period (ms)
 * @param data      the data packet
 * @param chunkSize the chunk size to use when splitting the packet
 */
- (instancetype) initWithManager:(CodelessManager*)manager period:(int)period data:(NSData*)data chunkSize:(int)chunkSize;
/**
 * Creates a DSPS periodic send operation, which sends a data packet periodically to the peer device,
 * using the manager's chunk size.
 * @param manager   the associated manager
 * @param period    the packet enqueueing period (ms)
 * @param data      the data packet
 */
- (instancetype) initWithManager:(CodelessManager*)manager period:(int)period data:(NSData*)data;
/**
 * Creates a DSPS periodic send operation, which sends a text packet periodically to the peer device.
 * @param manager   the associated manager
 * @param period    the packet enqueueing period (ms)
 * @param text      the text packet
 * @param chunkSize the chunk size to use when splitting the packet
 */
- (instancetype) initWithManager:(CodelessManager*)manager period:(int)period text:(NSString*)text chunkSize:(int)chunkSize;
/**
 * Creates a DSPS periodic send operation, which sends a text packet periodically to the peer device,
 * using the manager's chunk size.
 * @param manager   the associated manager
 * @param period    the packet enqueueing period (ms)
 * @param text      the text packet
 */
- (instancetype) initWithManager:(CodelessManager*)manager period:(int)period text:(NSString*)text;
/**
 * Creates a DSPS periodic send operation, which sends a pattern packet periodically to the peer device.
 * @param manager   the associated manager
 * @param file      the file containing the pattern prefix
 * @param chunkSize the pattern packet size
 * @param period    the packet enqueueing period (ms)
 */
- (instancetype) initWithManager:(CodelessManager*)manager file:(NSString*)file chunkSize:(int)chunkSize period:(int)period;
/**
 * Creates a DSPS periodic send operation, which sends a pattern packet periodically to the peer device,
 * using the manager's chunk size.
 * @param manager   the associated manager
 * @param file      the file containing the pattern prefix
 * @param period    the packet enqueueing period (ms)
 */
- (instancetype) initWithManager:(CodelessManager*)manager file:(NSString*)file period:(int)period;

/**
 * Sets the counter from which the operation will resume.
 * <p> Used by the library to resume the operation after it was paused.
 * @param count the resume counter
 */
- (void) setResumeCount:(int)count;
/**
 * Returns the current pattern counter, which is used as the packet number suffix.
 * <p> Current pattern counter is the counter that was used for the last packet that was enqueued.
 */
- (int) getPatternCount;
/**
 * Returns the calculated average speed for the duration of the periodic send operation.
 * <p> Available only if {@link CodelessLibConfig#DSPS_STATS statistics} are enabled.
 */
- (int) averageSpeed;
/**
 * Updates the byte counters used in statistics calculations.
 * @param bytes the number of sent bytes
 */
- (void) updateBytesSent:(int)bytes;
/// Checks if the pattern is loaded properly.
- (BOOL) isLoaded;
/**
 * Starts the periodic send operation.
 * <p> The operation will continue until {@link #stop} is called.
 * @see CodelessManager#sendPattern:chunkSize:period:
 */
- (void) start;
/// Stops the periodic send operation.
- (void) stop;
/// Enqueues the next packet for sending, called every {@link #period}.
- (void) sendData;

@end

NS_ASSUME_NONNULL_END
