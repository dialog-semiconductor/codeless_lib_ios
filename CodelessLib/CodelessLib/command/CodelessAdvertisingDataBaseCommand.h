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

#import "CodelessCommand.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Base class with common implementation of <code>AT+ADVDATA</code> and <code>AT+ADVRESP</code> commands.
 * @see CodelessAdvertisingDataCommand
 * @see CodelessAdvertisingResponseCommand
 * @see <a href="https://lpccs-docs.renesas.com/UM-140-DA145x-CodeLess/index.html">AT commands documentation</a>
 */
@interface CodelessAdvertisingDataBaseCommand : CodelessCommand

@property (class, readonly) NSString* DATA_PATTERN_STRING;

@property (class, readonly) NSString* RESPONSE_PATTERN_STRING;
@property (class, readonly) NSRegularExpression* RESPONSE_PATTERN;

@property (class, readonly) NSString* DATA_ARGUMENT_PATTERN_STRING;
@property (class, readonly) NSRegularExpression* DATA_ARGUMENT_PATTERN;

/// The advertising or scan response data argument/response.
@property NSData* data;

/**
 * Checks if an advertising data hex string is valid.
 * @param data the advertising data hex string
 */
+ (BOOL) validData:(NSString*)data;

/**
 * Creates an <code>AT+ADVDATA</code> or <code>AT+ADVRESP</code> command.
 * @param manager   the associated manager
 * @param data      the advertising or scan response data argument
 */
- (instancetype) initWithManager:(CodelessManager*)manager data:(NSData*)data;

/// Returns the advertising or scan response data argument/response as a hex string.
- (NSString*) getDataString;

@end

NS_ASSUME_NONNULL_END
