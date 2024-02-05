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
 * <code>AT+IO</code> command implementation.
 * @see CodelessLibEvent#IoStatus
 * @see <a href="https://lpccs-docs.renesas.com/UM-140-DA145x-CodeLess/index.html">AT commands documentation</a>
 */
@interface CodelessIoStatusCommand : CodelessCommand

@property (class, readonly) NSString* TAG;

@property (class, readonly) NSString* COMMAND;
@property (class, readonly) NSString* NAME;
@property (class, readonly) int ID;

@property (class, readonly) NSString* PATTERN_STRING;
@property (class, readonly) NSRegularExpression* PATTERN;

/// The GPIO pin argument/response.
@property (nonatomic) CodelessGPIO* gpio;

/**
 * Creates an <code>AT+IO</code> command.
 * @param manager   the associated manager
 * @param gpio      the GPIO pin argument
 */
- (instancetype) initWithManager:(CodelessManager*)manager gpio:(CodelessGPIO*)gpio;

/**
 * Creates an <code>AT+IO</code> command.
 * @param manager   the associated manager
 * @param gpio      the GPIO output pin argument
 * @param status    the output pin status argument (<code>true</code> for high, <code>false</code> for low)
 */
- (instancetype) initWithManager:(CodelessManager*)manager gpio:(CodelessGPIO*)gpio status:(BOOL)status;

/**
 * Creates an <code>AT+IO</code> command.
 * @param manager   the associated manager
 * @param port      the GPIO port number
 * @param pin       the GPIO pin number
 */
- (instancetype) initWithManager:(CodelessManager*)manager port:(int)port pin:(int)pin;

/**
 * Creates an <code>AT+IO</code> command.
 * @param manager   the associated manager
 * @param port      the GPIO port number
 * @param pin       the GPIO pin number
 * @param status    the output pin status argument (<code>true</code> for high, <code>false</code> for low)
 */
- (instancetype) initWithManager:(CodelessManager*)manager port:(int)port pin:(int)pin status:(BOOL)status;

/// Returns the output/input pin status argument/response (<code>true</code> for high, <code>false</code> for low).
- (BOOL) getStatus;
/// Sets the output pin status argument (<code>true</code> for high, <code>false</code> for low).
- (void) setStatus:(BOOL)status;

@end

NS_ASSUME_NONNULL_END
