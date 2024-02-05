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

@class CodelessLine;

NS_ASSUME_NONNULL_BEGIN

/**
 * CodeLess log file.
 *
 * Used by the library to log the CodeLess communication between the devices,
 * if log is {@link CodelessLibConfig#CODELESS_LOG enabled}.
 * @see CodelessManager
 */
@interface CodelessLogFile : CodelessLogFileBase

@property (class, readonly) NSString* TAG;

/**
 * Creates a CodeLess log file.
 * @param manager the associated manager
 */
- (instancetype) initWithManager:(CodelessManager*)manager;

/**
 * Appends a line to the log file.
 * @param line the line to append
 */
- (void) log:(NSString*)line;
/**
 * Logs a {@link CodelessLine} using a different prefix for incoming and outgoing messages.
 * @param line the line to log
 */
- (void) logLine:(CodelessLine*)line;
/**
 * Logs some text.
 * @param text the text to log
 */
- (void) logText:(NSString*)text;

@end

NS_ASSUME_NONNULL_END
