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

@class CodelessGPIO;

NS_ASSUME_NONNULL_BEGIN

/**
 * <code>AT+FLOWCONTROL</code> command implementation.
 * @see CodelessLibEvent#FlowControl
 * @see <a href="https://lpccs-docs.renesas.com/UM-140-DA145x-CodeLess/index.html">AT commands documentation</a>
 */
@interface CodelessFlowControlCommand : CodelessCommand

@property (class, readonly) NSString* TAG;

@property (class, readonly) NSString* COMMAND;
@property (class, readonly) NSString* NAME;
@property (class, readonly) int ID;

@property (class, readonly) NSString* PATTERN_STRING;
@property (class, readonly) NSRegularExpression* PATTERN;

/// The flow control mode argument/response.
@property (nonatomic) int mode;
/// The RTS pin argument/response.
@property (nonatomic) CodelessGPIO* rtsGpio;
/// The CTS pin argument/response.
@property (nonatomic) CodelessGPIO* ctsGpio;

/**
 * Creates an <code>AT+FLOWCONTROL</code> command.
 * @param manager   the associated manager
 * @param enabled   the flow control mode argument (<code>true</code> to enable, <code>false</code> to disable)
 * @param rtsGpio   the RTS pin argument
 * @param ctsGpio   the CTS pin argument
 */
- (instancetype) initWithManager:(CodelessManager*)manager enabled:(BOOL)enabled rtsGpio:(CodelessGPIO*)rtsGpio ctsGpio:(CodelessGPIO*)ctsGpio;

/**
 * Creates an <code>AT+FLOWCONTROL</code> command.
 * @param manager   the associated manager
 * @param mode      the flow control mode argument
 * @param rtsGpio   the RTS pin argument
 * @param ctsGpio   the CTS pin argument
 */
- (instancetype) initWithManager:(CodelessManager*)manager mode:(int)mode rtsGpio:(CodelessGPIO*)rtsGpio ctsGpio:(CodelessGPIO*)ctsGpio;

/// Checks if flow control is enabled, based on the flow control mode argument/response.
- (BOOL) isEnabled;
/// Sets the flow control mode argument (<code>true</code> to enable, <code>false</code> to disable).
- (void) setEnabled:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
