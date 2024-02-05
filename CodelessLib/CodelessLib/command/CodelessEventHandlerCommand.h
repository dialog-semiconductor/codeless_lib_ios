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

@class CodelessEventHandler;

NS_ASSUME_NONNULL_BEGIN

/**
 * <code>AT+HNDL</code> command implementation.
 * @see CodelessLibEvent#EventCommandsTable
 * @see CodelessLibEvent#EventCommands
 * @see <a href="https://lpccs-docs.renesas.com/UM-140-DA145x-CodeLess/index.html">AT commands documentation</a>
 */
@interface CodelessEventHandlerCommand : CodelessCommand

@property (class, readonly) NSString* TAG;

@property (class, readonly) NSString* COMMAND;
@property (class, readonly) NSString* NAME;
@property (class, readonly) int ID;

@property (class, readonly) NSString* PATTERN_STRING;
@property (class, readonly) NSRegularExpression* PATTERN;

/// The predefined event handler configuration argument.
@property CodelessEventHandler* eventHandler;
/// The predefined event handlers configuration response.
@property NSMutableArray<CodelessEventHandler*>* eventHandlerTable;

/**
 * Creates an <code>AT+HNDL</code> command.
 * @param manager   the associated manager
 * @param event     the predefined event type argument
 * @param commands  the predefined event handler commands argument
 */
- (instancetype) initWithManager:(CodelessManager*)manager event:(int)event commands:(NSMutableArray<CodelessCommand*>*)commands;

/**
 * Creates an <code>AT+HNDL</code> command.
 * @param manager       the associated manager
 * @param event         the predefined event type argument
 * @param commandString the predefined event handler commands (semicolon separated) argument
 */
- (instancetype) initWithManager:(CodelessManager*)manager event:(int)event commandString:(NSString*)commandString;

/**
 * Creates an <code>AT+HNDL</code> command.
 * @param manager   the associated manager
 * @param event     the predefined event type argument
 */
- (instancetype) initWithManager:(CodelessManager*)manager event:(int)event;

/**
 * Creates an <code>AT+HNDL</code> command.
 * @param manager       the associated manager
 * @param eventHandler  the predefined event handler configuration argument
 */
- (instancetype) initWithManager:(CodelessManager*)manager eventHandler:(CodelessEventHandler*)eventHandler;

/// Returns the predefined event type argument.
- (int) getEvent;
/// Sets the predefined event type argument.
- (void) setEvent:(int)event;
/// Returns the predefined event handler commands argument.
- (NSMutableArray<CodelessCommand*>*) getCommands;
/// Sets the predefined event handler commands argument.
- (void) setCommands:(NSMutableArray<CodelessCommand*>*)commands;
/// Returns the predefined event handler commands (semicolon separated) argument.
- (NSString*) getCommandString;
/// Sets the predefined event handler commands (semicolon separated) argument.
- (void) setCommandString:(NSString*)commandString;

@end

NS_ASSUME_NONNULL_END
