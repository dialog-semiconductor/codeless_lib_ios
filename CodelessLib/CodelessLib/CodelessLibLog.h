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

NS_ASSUME_NONNULL_BEGIN


/// Creates a log entry with a tag prefix.
#define CodelessLog(TAG, fmt, ...) NSLog(@"%@: " fmt, TAG, ##__VA_ARGS__)
/// Creates an log entry with a tag prefix, which can be disabled.
#define CodelessLogOpt(enabled, TAG, fmt, ...) do { if (enabled) NSLog(@"%@: " fmt, TAG, ##__VA_ARGS__); } while(0)


/// Log Bluetooth scan results.
#define CODELESS_LIB_LOG_SCAN_RESULT   true
/// Log GATT operations.
#define CODELESS_LIB_LOG_GATT_OPERATION   true

/// Log CodeLess operations.
#define CODELESS_LIB_LOG_CODELESS   true
/// Log command specific messages.
#define CODELESS_LIB_LOG_COMMAND   true
/// Log CodeLess script operations.
#define CODELESS_LIB_LOG_SCRIPT   true

/// Log DSPS operations. Data operations are configured separately.
#define CODELESS_LIB_LOG_DSPS   true
/// Log sent/received DSPS data.
#define CODELESS_LIB_LOG_DSPS_DATA   true
/// Log sending of DSPS data chunks.
#define CODELESS_LIB_LOG_DSPS_CHUNK   true
/// Log queueing/sending/receiving of DSPS file chunks.
#define CODELESS_LIB_LOG_DSPS_FILE_CHUNK   true
/// Log queueing/sending of DSPS periodic/pattern chunks.
#define CODELESS_LIB_LOG_DSPS_PERIODIC_CHUNK   true


/// Configuration options that configure the log output produced by the library.
@interface CodelessLibLog : NSObject

/// Log Bluetooth scan results.
@property (class, readonly) BOOL SCAN_RESULT;
/// Log GATT operations.
@property (class, readonly) BOOL GATT_OPERATION;

/// Log Bluetooth scan results.
@property (class, readonly) BOOL CODELESS;
/// Log command specific messages.
@property (class, readonly) BOOL COMMAND;
/// Log CodeLess script operations.
@property (class, readonly) BOOL SCRIPT;

/// Log DSPS operations. Data operations are configured separately.
@property (class, readonly) BOOL DSPS;
/// Log sent/received DSPS data.
@property (class, readonly) BOOL DSPS_DATA;
/// Log sending of DSPS data chunks.
@property (class, readonly) BOOL DSPS_CHUNK;
/// Log queueing/sending/receiving of DSPS file chunks.
@property (class, readonly) BOOL DSPS_FILE_CHUNK;
/// Log queueing/sending of DSPS periodic/pattern chunks.
@property (class, readonly) BOOL DSPS_PERIODIC_CHUNK;

@end

NS_ASSUME_NONNULL_END
