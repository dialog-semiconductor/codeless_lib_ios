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

@class CodelessBondingEntry;

NS_ASSUME_NONNULL_BEGIN

/**
 * <code>AT+IEBNDE</code> command implementation.
 * @see CodelessLibEvent#BondingEntry
 * @see CodelessBondingEntry
 * @see <a href="https://lpccs-docs.renesas.com/UM-140-DA145x-CodeLess/index.html">AT commands documentation</a>
 */
@interface CodelessBondingEntryTransferCommand : CodelessCommand

@property (class, readonly) NSString* TAG;

@property (class, readonly) NSString* COMMAND;
@property (class, readonly) NSString* NAME;
@property (class, readonly) int ID;

@property (class, readonly) NSString* PATTERN_STRING;
@property (class, readonly) NSRegularExpression* PATTERN;

@property (class, readonly) NSString* ENTRY_ARGUMENT_PATTERN_STRING;
@property (class, readonly) NSRegularExpression* ENTRY_ARGUMENT_PATTERN;

/// The bonding entry index argument.
@property (nonatomic) int index;
/// The bonding entry configuration argument/response (packed hex data).
@property (nonatomic) NSString* entry;
/// The bonding entry configuration argument/response (unpacked).
@property (nonatomic) CodelessBondingEntry* bondingEntry;

/**
 * Checks if a bonding entry configuration argument/response has the correct format.
 * @param data the bonding entry configuration data to check (packed hex data)
 */
+ (BOOL) validData:(NSString*)data;

/**
 * Creates an <code>AT+IEBNDE</code> command.
 * @param manager   the associated manager
 * @param index     the bonding entry index argument (1-5)
 */
- (instancetype) initWithManager:(CodelessManager*)manager index:(int)index;

/**
 * Creates an <code>AT+IEBNDE</code> command.
 * @param manager       the associated manager
 * @param index         the bonding entry index argument (1-5)
 * @param bondingEntry  the bonding entry configuration argument (unpacked)
 */
- (instancetype) initWithManager:(CodelessManager*)manager index:(int)index bondingEntry:(CodelessBondingEntry*)bondingEntry;

/**
 * Creates an <code>AT+IEBNDE</code> command.
 * @param manager   the associated manager
 * @param index     the bonding entry index argument (1-5)
 * @param entry     the bonding entry configuration argument (packed hex data)
 */
- (instancetype) initWithManager:(CodelessManager*)manager index:(int)index entry:(NSString*)entry;

@end

NS_ASSUME_NONNULL_END
