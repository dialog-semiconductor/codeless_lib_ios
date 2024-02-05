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

@class CodelessManager;
@class CodelessScript;
@class CodelessCommandEvent;

NS_ASSUME_NONNULL_BEGIN

/**
 * Base class for CodeLess command implementation.
 *
 * For each supported command, a subclass of this class provides the command behavior, by overriding the required properties and methods.
 * The library {@link #parseCommand: parses} the command text and creates the corresponding subclass object.
 * If a command is not recognized, a {@link CodelessCustomCommand} object is created.
 *
 * ## Add a new command ##
 * To add a new command, create a subclass of this class. Add a {@link CodelessProfile#CODELESS_COMMAND_ID command ID} for the new command.
 * In the subclass, override the properties and methods required to provide the command specific behavior.
 * <ul>
 * <li>
 * Required properties: {@link #TAG}, {@link #ID}, {@link #name}, {@link #commandID}, {@link #pattern}
 * </li>
 * <li>
 * Parsing methods: {@link #requiresArguments}, {@link #checkArgumentsCount}, {@link #parseArguments}
 * </li>
 * <li>
 * Outgoing commands: {@link #hasArguments}, {@link #getArguments}, {@link #parseResponse:}, {@link #onSuccess}, {@link #onError:}
 * </li>
 * <li>
 * Incoming commands: {@link #processInbound}, {@link #sendSuccess:}, {@link #sendError:}
 * </ul>
 * For example, see the implementation of the {@link CodelessUartPrintCommand <code>AT+PRINT</code>}
 * and the {@link CodelessDeviceInformationCommand <code>ATI</code>} commands.
 *
 * Each of the library command classes contains the following static fields:
 * <ul>
 * <li><code>TAG</code>: the command log tag</li>
 * <li><code>COMMAND</code>: the command text identifier</li>
 * <li><code>NAME</code>: the command name</li>
 * <li><code>ID</code>: the command ID</li>
 * <li><code>PATTERN_STRING</code>: the command pattern (regular expression)</li>
 * </ul>
 * @see CodelessManager
 * @see #parseCommand:
 * @see <a href="https://lpccs-docs.renesas.com/UM-140-DA145x-CodeLess/index.html">AT commands documentation</a>
 */
@interface CodelessCommand : NSObject

@property (class, readonly) NSString* TAG;

/// The associated manager.
@property (weak) CodelessManager* manager;
/// The associated script, if the command is part of one.
@property (weak) CodelessScript* script;
/// The object that created the command (optional, used by {@link CodelessCommands}).
@property NSObject* origin;
/// The command text (provided by the user or created by the {@link #packCommand command object}).
@property NSString* command;
/// The used AT command prefix.
@property NSString* prefix;
/// The response text received for this command (one string per line).
@property NSMutableArray<NSString*>* response;
/// Pattern matcher used for parsing the command text.
@property NSTextCheckingResult* matcher;
/// <code>true</code> if the command is received from the peer device, <code>false</code> if it is sent to it.
@property BOOL inbound;
/// <code>true</code> if the command is parsed from text, <code>false</code> if it is created by the library.
@property BOOL parsed;
/// <code>true</code> if the command is invalid (parsing failed, wrong arguments).
@property BOOL invalid;
/// <code>true</code> if the peer device responded with an invalid command error.
@property BOOL peerInvalid;
/// <code>true</code> if the command is complete.
@property BOOL complete;
/// The error message (if the sent or received command failed).
@property NSString* error;
/// The error code (if the sent or received command failed).
@property int errorCode;

/**
 * Creates a CodelessCommand object without arguments.
 * @param manager the associated manager
 */
- (instancetype) initWithManager:(CodelessManager*)manager;

/**
 * Creates a CodelessCommand object from text.
 * @param manager   the associated manager
 * @param command   the command text
 * @param parse     <code>true</code> to parse the command text
 */
- (instancetype) initWithManager:(CodelessManager*)manager command:(NSString*)command parse:(BOOL)parse;

/// Sets the object that created the command.
- (CodelessCommand*) origin:(NSObject*)origin;
/// Checks if the command prefix is set.
- (BOOL) hasPrefix;
/// Marks the command as received from the peer device.
- (void) setInbound;
/// Checks if the command is valid.
- (BOOL) isValid;
/// Marks the command as invalid for the peer device.
- (void) setPeerInvalid;
/// Completes the command.
- (void) setComplete;
/// Checks if the command has failed.
- (BOOL) failed;

/// Returns the command log tag.
- (NSString*) TAG;
/// Returns the command text identifier (without the AT command prefix).
- (NSString*) ID;
/// Returns the command name.
- (NSString*) name;
/// Returns the {@link CodelessProfile#CODELESS_COMMAND_ID command ID}.
- (int) commandID;
/**
 * Returns the command pattern (regular expression, used for {@link #parseCommand: parsing}).
 *
 * During parsing, the library will try to match the command text with this pattern.
 *
 * The pattern starts with the command {@link #ID text identifier} and can
 * contain capturing groups for the command arguments, which can be used to extract
 * them using the {@link #matcher}.
 */
- (NSRegularExpression*) pattern;

/// Creates the command text to be sent to the peer device.
- (NSString*) packCommand;
/// Checks if the command has arguments (used by {@link #packCommand}).
- (BOOL) hasArguments;
/// Returns the text for the command's arguments (used by {@link #packCommand}).
- (NSString*) getArguments;
/**
 * Checks if the command wants to parse each received response line immediately.
 *
 * Otherwise the whole response will be parsed when the command is complete.
 * Used for command processing.
 */
- (BOOL) parsePartialResponse;
/**
 * Parses the response text.
 * <p> Called on each response line before the success or error response.
 * @param response the response text
 */
- (void) parseResponse:(NSString*)response;
/**
 * Returns the size of the {@link #response} array.
 * <p> Can be used to get the current response line in {@link #parseResponse: parseResponse}.
 */
- (int) responseLine;
/// Called on command success (for sent commands).
- (void) onSuccess;
/**
 * Called on command failure (for sent commands).
 * @param msg the error message
 */
- (void) onError:(NSString*)msg;
/**
 * Sets the error code and message for a failed command.
 * @param code      the error code
 * @param message   the error message
 */
- (void) setErrorCode:(int)code message:(NSString*)message;
/**
 * Parses the specified command text and initializes the command object.
 *
 * The parsing uses methods that are overridden by subclasses to provide the required behavior.
 * First it checks if arguments are {@link #requiresArguments required} but missing.
 * Then it checks if the number of arguments is {@link #checkArgumentsCount correct}.
 * After that, it uses the command {@link #pattern} to match the command text.
 * If the matching is successful, it {@link #parseArguments parses} the arguments.
 * @param command the command text
 * @return <code>nil</code> if the command was parsed successfully, otherwise the parse error message
 */
- (NSString*) parseCommand:(NSString*)command;
/// Checks if the command requires arguments (used for {@link #parseCommand: parsing}).
- (BOOL) requiresArguments;
/// Checks if the number of arguments is correct (used for {@link #parseCommand: parsing}).
- (BOOL) checkArgumentsCount;
/**
 * Parses the command text arguments (used for {@link #parseCommand: parsing}).
 *
 * The {@link #matcher} can be used to extract the arguments from the parsed text,
 * by using capturing groups defined in the command {@link #pattern}.
 * @return <code>nil</code> if the arguments were parsed successfully, otherwise the parse error message
 */
- (NSString*) parseArguments;
/**
 * Called when a {@link CodelessLibConfig#supportedCommands supported} command is received from the peer device.
 *
 * Subclasses of supported commands can override this to implement the required behavior.
 * The command implementation is responsible for sending a proper response to the peer device.
 *
 * The default behavior is to send a success response.
 * @see #sendSuccess:
 * @see #sendError:
 */
- (void) processInbound;
/// Completes the command with a success response (no response message).
- (void) sendSuccess;
/**
 * Completes the command with a success response.
 * @param response the response message
 */
- (void) sendSuccess:(NSString*)response;
/**
 * Completes the command with an error response.
 * @param msg the error message
 */
- (void) sendError:(NSString*)msg;
/**
 * Sends a response message to the peer device.
 * @param response  the response message
 * @param more      <code>true</code> to add more response messages later, <code>false</code> to complete successfully
 * @see CodelessManager#sendResponse:
 */
- (void) sendResponse:(NSString*)response more:(BOOL)more;

/**
 * Decodes a number argument from a capturing group in {@link #matcher}.
 * @param group the capturing group index
 */
- (NSNumber*) decodeNumberArgument:(int)group;
/// Generates a command event.
- (void) sendEvent:(NSString*)event object:(CodelessCommandEvent*)object;

@end

NS_ASSUME_NONNULL_END
