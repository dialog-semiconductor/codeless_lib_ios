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

#import <Foundation/Foundation.h>

@class CodelessManager;
@class DspsRxLogFile;

NS_ASSUME_NONNULL_BEGIN

/**
 * DSPS file receive operation.
 *
 * ## Usage ##
 * Use the {@link CodelessManager#receiveFile receiveFile} method to create and {@link #start}
 * a DSPS file receive operation. Only a single file receive operation can be active.
 *
 * After the operation is started, it constantly checks the received data for the
 * following {@link CodelessLibConfig#DSPS_RX_FILE_HEADER_PATTERN_STRING file header}:
 * <blockquote><pre>
 * Name: &lt;file_name&gt; (no whitespace)
 * Size: &lt;n&gt; (bytes)
 * CRC: &lt;hex&gt; (CRC-32, optional)
 * END (header end mark)
 * ... &lt;n&gt; bytes of data ...</pre></blockquote>
 * When the header is detected, the {@link DspsRxLogFile output file} with the specified name is created in
 * the configured output path. After that, and until the file size specified in the header is reached, all
 * incoming data are saved to the output file. A {@link CodelessLibEvent#DspsRxFileData DspsRxFileData} event
 * is generated for each received data packet.
 *
 * After all the data are received, if the header contained a CRC value, the file data CRC is validated and
 * a {@link CodelessLibEvent#DspsRxFileCrc DspsRxFileCrc} event is generated.
 *
 * NOTE: A single null byte may also be used as the header end mark. The file data start immediately after.
 * @see CodelessManager
 */
@interface DspsFileReceive : NSObject

@property (class, readonly) NSString* TAG;

/// The associated manager.
@property (weak, readonly) CodelessManager* manager;
/// The file name.
@property (readonly) NSString* name;
/// The file size.
@property (readonly) int size;
/// The file data CRC, if it is set.
@property (readonly) int64_t crc;
/// The log file where the received data are saved.
@property (readonly) DspsRxLogFile* file;
/// The number of received bytes.
@property (readonly) int bytesReceived;
/// <code>true</code> if the operation has started.
@property (readonly) BOOL started;
/// <code>true</code> if the operation is complete.
@property (readonly) BOOL complete;
/// The operation start time.
@property (readonly) NSTimeInterval startTime;
/// The operation end time.
@property (readonly) NSTimeInterval endTime;
/// The calculated current speed.
/// <p> Available only if {@link CodelessLibConfig#DSPS_STATS statistics} are enabled.
@property (readonly) int currentSpeed;

/**
 * Creates a DSPS file receive operation.
 * @param manager the associated manager
 */
- (instancetype) initWithManager:(CodelessManager*)manager;

/// Checks if a CRC is set for the file data.
- (BOOL) hasCrc;
/// Checks if the file data CRC validation succeeded.
- (BOOL) crcOk;
/**
 * Returns the calculated average speed for the duration of the file receive operation.
 * <p> Available only if {@link CodelessLibConfig#DSPS_STATS statistics} are enabled.
 */
- (int) averageSpeed;
/**
 * Starts the file receive operation.
 * @see CodelessManager#receiveFile()
 */
- (void) start;
/// Stops the file receive operation.
- (void) stop;
/**
 * Called by the library when binary data are received from the peer device, if a file receive operation is active.
 *
 * It checks the received data for the file header. If the file header is detected, the {@link DspsRxLogFile output file} is
 * created and all received data after that are saved to the file, until the file size specified in the header is reached.
 * A {@link CodelessLibEvent#DspsRxFileData DspsRxFileData} event is generated for each received data packet.
 * After all the data are received, if the header contained a CRC value, the file data CRC is validated and
 * a {@link CodelessLibEvent#DspsRxFileCrc DspsRxFileCrc} event is generated.
 *
 * The file header has the following {@link CodelessLibConfig#DSPS_RX_FILE_HEADER_PATTERN_STRING format}:
 * <blockquote><pre>
 * Name: &lt;file_name&gt; (no whitespace)
 * Size: &lt;n&gt; (bytes)
 * CRC: &lt;hex&gt; (CRC-32, optional)
 * END (header end mark)
 * ... &lt;n&gt; bytes of data ...</pre></blockquote>
 * @param data the received data
 */
- (void) onDspsData:(NSData*)data;

@end

NS_ASSUME_NONNULL_END
