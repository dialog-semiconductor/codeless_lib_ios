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
 * <code>AT+DLEEN</code> command implementation.
 * @see CodelessLibEvent#DataLengthEnable
 * @see <a href="https://lpccs-docs.renesas.com/UM-140-DA145x-CodeLess/index.html">AT commands documentation</a>
 */
@interface CodelessDataLengthEnableCommand : CodelessCommand

@property (class, readonly) NSString* TAG;

@property (class, readonly) NSString* COMMAND;
@property (class, readonly) NSString* NAME;
@property (class, readonly) int ID;

@property (class, readonly) NSString* PATTERN_STRING;
@property (class, readonly) NSRegularExpression* PATTERN;

@property (class, readonly) NSString* RESPONSE_PATTERN_STRING;
@property (class, readonly) NSRegularExpression* RESPONSE_PATTERN;

/// The DLE configuration argument/response (<code>true</code> for enabled, <code>false</code> for disabled).
@property BOOL enabled;
/// The DLE TX packet length argument/response.
@property (nonatomic) int txPacketLength;
/// The DLE RX packet length argument/response.
@property (nonatomic) int rxPacketLength;

/**
 * Creates an <code>AT+DLEEN</code> command.
 * @param manager           the associated manager
 * @param enabled           the DLE configuration argument (<code>true</code> for enabled, <code>false</code> for disabled)
 * @param txPacketLength    the DLE TX packet length argument
 * @param rxPacketLength    the DLE RX packet length argument
 */
- (instancetype) initWithManager:(CodelessManager*)manager enabled:(BOOL)enabled txPacketLength:(int)txPacketLength rxPacketLength:(int)rxPacketLength;

/**
 * Creates an <code>AT+DLEEN</code> command.
 * @param manager   the associated manager
 * @param enabled   the DLE configuration argument (<code>true</code> for enabled, <code>false</code> for disabled)
 */
- (instancetype) initWithManager:(CodelessManager*)manager enabled:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
