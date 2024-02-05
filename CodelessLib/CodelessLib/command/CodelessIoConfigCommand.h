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
 * <code>AT+IOCFG</code> command implementation.
 * @see CodelessLibEvent#IoConfig
 * @see CodelessLibEvent#IoConfigSet
 * @see <a href="https://lpccs-docs.renesas.com/UM-140-DA145x-CodeLess/index.html">AT commands documentation</a>
 */
@interface CodelessIoConfigCommand : CodelessCommand

@property (class, readonly) NSString* TAG;

@property (class, readonly) NSString* COMMAND;
@property (class, readonly) NSString* NAME;
@property (class, readonly) int ID;

@property (class, readonly) NSString* PATTERN_STRING;
@property (class, readonly) NSRegularExpression* PATTERN;

/// The GPIO pin configuration argument.
@property CodelessGPIO* gpio;
/// The GPIO pin configuration response.
@property NSMutableArray<CodelessGPIO*>* configuration;

/**
 * Creates an <code>AT+IOCFG</code> command.
 * @param manager   the associated manager
 * @param gpio      the GPIO pin configuration argument
 */
- (instancetype) initWithManager:(CodelessManager*)manager gpio:(CodelessGPIO*)gpio;

/**
 * Creates an <code>AT+IOCFG</code> command.
 * @param manager   the associated manager
 * @param port      the GPIO port number
 * @param pin       the GPIO pin number
 * @param function  the GPIO {@link CodelessProfile#CODELESS_COMMAND_GPIO_FUNCTION functionality} argument
 */
- (instancetype) initWithManager:(CodelessManager*)manager port:(int)port pin:(int)pin function:(int)function;

/**
 * Creates an <code>AT+IOCFG</code> command.
 * @param manager   the associated manager
 * @param port      the GPIO port number
 * @param pin       the GPIO pin number
 * @param function  the GPIO pin {@link CodelessProfile#CODELESS_COMMAND_GPIO_FUNCTION functionality} argument
 * @param level     the GPIO pin level argument
 */
- (instancetype) initWithManager:(CodelessManager*)manager port:(int)port pin:(int)pin function:(int)function level:(int)level;

/// Sets the GPIO pin configuration argument.
- (void) setGpioPack:(int)pack;
/// Sets the GPIO pin configuration argument.
- (void) setGpioPort:(int)port pin:(int)pin;
/// Returns the port number of the GPIO pin configuration argument.
- (int) getGpioPort;
/// Sets the port number of the GPIO pin configuration argument.
- (void) setGpioPort:(int)port;
/// Returns the pin number of the GPIO pin configuration argument.
- (int) getGpioPin;
/// Sets the pin number of the GPIO pin configuration argument.
- (void) setGpioPin:(int)pin;
/// Returns the GPIO {@link CodelessProfile#CODELESS_COMMAND_GPIO_FUNCTION functionality} argument.
- (int) getGpioFunction;
/// Sets the GPIO {@link CodelessProfile#CODELESS_COMMAND_GPIO_FUNCTION functionality} argument.
- (void) setGpioFunction:(int)function;
/// Returns the GPIO pin level argument.
- (int) getGpioLevel;
/// Sets the GPIO pin level argument.
- (void) setGpioLevel:(int)level;

@end

NS_ASSUME_NONNULL_END
