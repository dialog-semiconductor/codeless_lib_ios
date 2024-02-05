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

@class CodelessCommand;
@class CodelessManager;

NS_ASSUME_NONNULL_BEGIN

/**
 * CodeLess commands scripting functionality.
 *
 * ## Usage ##
 * You can create a script from a single string or a list of strings, with one command per line.
 * The single string script may contain empty lines, which are ignored. The script text is parsed
 * to a list of {@link CodelessCommand} objects. After creating the script, you can use {@link #invalid hasInvalid}
 * to check if the script contains invalid commands, or {@link #custom hasCustom} to check if the script
 * contains unidentified commands.
 *
 * The script commands are executed in sequence when {@link #start} is called.
 * When the scripts starts, a {@link CodelessLibEvent#ScriptStart ScriptStart} event is generated.
 * For each script command that is complete, a {@link CodelessLibEvent#ScriptCommand ScriptCommand} event is generated.
 * When the script is complete, a {@link CodelessLibEvent#ScriptEnd ScriptEnd} event is generated.
 * By default, the script will stop if a command fails. Use {@link #stopOnError} to modify this behavior.
 *
 * For example, a script that uses two timers to toggle an output pin:
 * <blockquote><pre>
 * NSString* text = @@"AT+IOCFG=10,4\n"
 *                  "AT+CMDSTORE=0,AT+IO=10,0;ATZ\n"
 *                  "AT+CMDSTORE=1,AT+IO=10,1;AT+TMRSTART=0,0,200\n"
 *                  "AT+TMRSTART=1,1,1";
 * CodelessScript* script = [[%CodelessScript alloc] initWithManager:self.manager text:text];
 * [script start];</pre></blockquote>
 *
 * @see CodelessManager
 * @see CodelessLibEvent
 */
@interface CodelessScript : NSObject

@property (class, readonly) NSString* TAG;

/// The script ID (unique per app session).
@property int id;
/// The script name.
@property NSString* name;
/// The associated {@link CodelessManager manager}.
@property (weak, readonly) CodelessManager* manager;
/// The script text (one command per line).
@property (nonatomic) NSArray<NSString*>* script;
/// The parsed script commands as a list of {@link CodelessCommand} objects.
@property (nonatomic) NSArray<CodelessCommand*>* commands;
/// The current command index (0-based).
@property (nonatomic) int current;
/// The stop on error configuration.
/// <p> <code>true</code> to stop the script if a command fails, <code>false</code> to continue execution.
@property BOOL stopOnError;
/// <code>true</code> if the script contains invalid commands.
@property (readonly, getter=hasInvalid) BOOL invalid;
/// <code>true</code> if the script contains unidentified commands.
@property (readonly, getter=hasCustom) BOOL custom;
/// <code>true</code> if the script has started.
@property (readonly) BOOL started;
/// <code>true</code> if the script was stopped by the user or due to an error.
@property (readonly) BOOL stopped;
/// <code>true</code> if the script is complete.
@property (readonly) BOOL complete;

/**
 * Creates a CodelessScript with no commands.
 * @param manager the manager used to run the script
 */
- (instancetype) initWithManager:(CodelessManager*)manager;
/**
 * Creates a CodelessScript.
 * @param manager   the manager used to run the script
 * @param text      the script text
 */
- (instancetype) initWithManager:(CodelessManager*)manager text:(NSString*)text;
/**
 * Creates a CodelessScript.
 * @param manager   the manager used to run the script
 * @param script    the script text (one command per line)
 */
- (instancetype) initWithManager:(CodelessManager*)manager script:(NSArray<NSString*>*)script;
/**
 * Creates a named CodelessScript with no commands.
 * @param name      the script name
 * @param manager   the manager used to run the script
 */
- (instancetype) initWithName:(NSString*)name manager:(CodelessManager*)manager;
/**
 * Creates a named CodelessScript.
 * @param name      the script name
 * @param manager   the manager used to run the script
 * @param text      the script text
 */
- (instancetype) initWithName:(NSString*)name manager:(CodelessManager*)manager text:(NSString*)text;
/**
 * Creates a named CodelessScript.
 * @param name      the script name
 * @param manager   the manager used to run the script
 * @param script    the script text (one command per line)
 */
- (instancetype) initWithName:(NSString*)name manager:(CodelessManager*)manager script:(NSArray<NSString*>*)script;

/**
 * Starts the script.
 * <p> A {@link CodelessLibEvent#ScriptStart ScriptStart} event is generated.
 */
- (void) start;
/// Stops the script.
- (void) stop;
/**
 * Called when a script command completes successfully.
 * <p> A {@link CodelessLibEvent#ScriptCommand ScriptCommand} event is generated.
 * <p> The script continues its execution with the next command.
 * @param command the command that succeeded
 */
- (void) onSuccess:(CodelessCommand*)command;
/**
 * Called when a script command fails.
 * <p> A {@link CodelessLibEvent#ScriptCommand ScriptCommand} event is generated.
 * <p>
 * The script can be configured to stop if a command fails, or ignore the error and
 * continue its execution with the next command.
 * @param command the command that failed
 */
- (void) onError:(CodelessCommand*)command;

/**
 * Sets the script text and parses it to a list of {@link CodelessCommand} objects.
 * @param text the script text
 * @see #script
 */
- (void) setText:(NSString*)text;
/// Returns the whole script text as one string.
- (NSString*) getText;

/// Returns the current {@link CodelessCommand command} object.
- (CodelessCommand*) getCurrentCommand;
/// Returns the current command text.
- (NSString*) getCurrentCommandText;
/**
 * Returns the command index for the specified {@link CodelessCommand command} object.
 * @param command the command to search
 */
- (int) getCommandIndex:(CodelessCommand*)command;

@end

NS_ASSUME_NONNULL_END
