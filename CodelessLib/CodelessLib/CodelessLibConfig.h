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

@class CodelessGPIO;

NS_ASSUME_NONNULL_BEGIN


#define CODELESS_LIB_CONFIG_SCAN_DURATION   10000 // ms

/// ATI command response (if <code>nil</code>, the app version is used).
#define CODELESS_LIB_CONFIG_INFO nil

/// Folder for CodeLess and DSPS log files (in app documents).
#define CODELESS_LIB_CONFIG_LOG_FILE_PATH   @"log"
/// Date format used when creating log file names.
#define CODELESS_LIB_CONFIG_LOG_FILE_DATE   @"yyyy-MM-dd'_'HH.mm.ss"
/// Append the device address to the log file name.
#define CODELESS_LIB_CONFIG_LOG_FILE_ADDRESS_SUFFIX   true
/// Log file extension.
#define CODELESS_LIB_CONFIG_LOG_FILE_EXTENSION   @".txt"
/// Enable CodeLess communication log file.
#define CODELESS_LIB_CONFIG_CODELESS_LOG   true
/// Flush the CodeLess log file on each write.
#define CODELESS_LIB_CONFIG_CODELESS_LOG_FLUSH   true
/// Prefix used for the CodeLess log file name.
#define CODELESS_LIB_CONFIG_CODELESS_LOG_FILE_PREFIX   @"Codeless_"
/// Prefix used for CodeLess log entries for user input.
#define CODELESS_LIB_CONFIG_CODELESS_LOG_PREFIX_TEXT   @""
/// Prefix used for CodeLess log entries for outgoing messages.
#define CODELESS_LIB_CONFIG_CODELESS_LOG_PREFIX_OUTBOUND   @">> "
/// Prefix used for CodeLess log entries for incoming messages.
#define CODELESS_LIB_CONFIG_CODELESS_LOG_PREFIX_INBOUND   @"<< "
/// Enable DSPS received data log file.
#define CODELESS_LIB_CONFIG_DSPS_RX_LOG   true
/// Flush the DSPS received data log file on each write.
#define CODELESS_LIB_CONFIG_DSPS_RX_LOG_FLUSH   true
/// Prefix used for the DSPS received data log file name.
#define CODELESS_LIB_CONFIG_DSPS_RX_LOG_FILE_PREFIX   @"DSPS_RX_"

/**
 * Enable priority for DSPS send data GATT operations.
 * <p>
 * High priority operations are put before low priority ones in the queue.
 * File and periodic send operations are low priority, while other DSPS operations are high priority.
 */
#define CODELESS_LIB_CONFIG_GATT_QUEUE_PRIORITY   true
/// Execute the next GATT operation in the queue before processing the results of the previous one.
#define CODELESS_LIB_CONFIG_GATT_DEQUEUE_BEFORE_PROCESSING   true
/// Monitor Bluetooth state and perform required actions.
#define CODELESS_LIB_CONFIG_BLUETOOTH_STATE_MONITOR   true

// WARNING: Modifying these may cause parse failure on peer device.
/// Used character set for conversion between text and bytes.
#define CODELESS_LIB_CONFIG_CHARSET   NSASCIIStringEncoding
/// End of line characters used when sending text.
#define CODELESS_LIB_CONFIG_END_OF_LINE   @"\r\n"
/// Append an end of line character to the sent text (if not already there, does not apply to sent commands).
#define CODELESS_LIB_CONFIG_APPEND_END_OF_LINE   true
/// Append an end of line character to the sent command text (if not already there).
#define CODELESS_LIB_CONFIG_END_OF_LINE_AFTER_COMMAND   false
/// Add an empty line before a success response, if there is no response message.
#define CODELESS_LIB_CONFIG_EMPTY_LINE_BEFORE_OK   true
/// Add an empty line before an error response, if there is no response message.
#define CODELESS_LIB_CONFIG_EMPTY_LINE_BEFORE_ERROR   true
/// Append a null byte to the sent text.
#define CODELESS_LIB_CONFIG_TRAILING_ZERO   true
/// Use single write operation to send response (merge lines).
#define CODELESS_LIB_CONFIG_SINGLE_WRITE_RESPONSE   true

/// Do not send invalid commands which are parsed from text (for example, user input).
#define CODELESS_LIB_CONFIG_DISALLOW_INVALID_PARSED_COMMAND   false
/// Do not send invalid commands which are not parsed from text (for example, commands created with {@link CodelessCommands}).
#define CODELESS_LIB_CONFIG_DISALLOW_INVALID_COMMAND   true
/// Do not send commands which do not have a valid AT command prefix.
#define CODELESS_LIB_CONFIG_DISALLOW_INVALID_PREFIX   true
/// Automatically add the AT command prefix (if missing).
#define CODELESS_LIB_CONFIG_AUTO_ADD_PREFIX   true

/// Enable {@link CodelessLibEvent#Line Line} events.
#define CODELESS_LIB_CONFIG_LINE_EVENTS   true

/// Start in command mode operation, if the peer device supports CodeLess.
#define CODELESS_LIB_CONFIG_START_IN_COMMAND_MODE   true
/**
 * Enable {@link CodelessLibEvent#BinaryModeRequest BinaryModeRequest} event when the peer CodeLess device sends the <code>AT+BINREQ</code> command.
 * <p>
 * The app should call {@link CodelessManager#acceptBinaryModeRequest}, if the request is accepted.
 * If disabled, the library will automatically respond with <code>AT+BINREQACK</code>, entering binary mode.
 */
#define CODELESS_LIB_CONFIG_HOST_BINARY_REQUEST   true
/**
 * Send the <code>AT+BINREQ</code> command to the peer device to request switching to binary mode.
 * <p> If disabled, the library will send the <code>AT+BINREQACK</code> command to force the switch.
 */
#define CODELESS_LIB_CONFIG_MODE_CHANGE_SEND_BINARY_REQUEST   true
/// Allow incoming binary data in command mode.
#define CODELESS_LIB_CONFIG_ALLOW_INBOUND_BINARY_IN_COMMAND_MODE   false
/// Allow outgoing binary data in command mode.
#define CODELESS_LIB_CONFIG_ALLOW_OUTBOUND_BINARY_IN_COMMAND_MODE   false
/// Allow incoming commands in binary mode (mode commands are always allowed).
#define CODELESS_LIB_CONFIG_ALLOW_INBOUND_COMMAND_IN_BINARY_MODE   false
/// Allow outgoing commands in binary mode (mode commands are always allowed).
#define CODELESS_LIB_CONFIG_ALLOW_OUTBOUND_COMMAND_IN_BINARY_MODE   false

/**
 * The initial DSPS chunk size.
 * <p> WARNING: The chunk size must not exceed the value (MTU - 3), otherwise chunks will be truncated when sent.
 */
#define CODELESS_LIB_CONFIG_DEFAULT_DSPS_CHUNK_SIZE   128
/// Increase the DSPS chunk size to the maximum allowed value after the MTU exchange.
#define CODELESS_LIB_CONFIG_DSPS_CHUNK_SIZE_INCREASE_TO_MTU   true
/// Maximum buffer size for pending binary data operations when TX flow control is off.
#define CODELESS_LIB_CONFIG_DSPS_PENDING_MAX_SIZE   1000
/// The initial DSPS RX flow control configuration (<code>true</code> for on, <code>false</code> for off).
#define CODELESS_LIB_CONFIG_DEFAULT_DSPS_RX_FLOW_CONTROL   true
/**
 * The initial DSPS TX flow control configuration (<code>true</code> for on, <code>false</code> for off).
 * <p>
 * If set to on, the library will be able to send data immediately after connection. Otherwise, it will wait for the
 * peer device to set the flow control to on by sending a notification through the DSPS Flow Control characteristic.
 */
#define CODELESS_LIB_CONFIG_DEFAULT_DSPS_TX_FLOW_CONTROL   true
/// Configure the RX flow control on connection by writing the appropriate value to the DSPS Flow Control characteristic.
#define CODELESS_LIB_CONFIG_SET_FLOW_CONTROL_ON_CONNECTION   true

/// Length of the number suffix for pattern {@link DspsPeriodicSend} operations.
#define CODELESS_LIB_CONFIG_DSPS_PATTERN_DIGITS   4

/// Folder for DSPS receive file operations (in app documents).
#define CODELESS_LIB_CONFIG_DSPS_RX_FILE_PATH   @"files"
/// Log receive file operation data to the DSPS RX log file (if {@link #DSPS_RX_LOG enabled}).
#define CODELESS_LIB_CONFIG_DSPS_RX_FILE_LOG_DATA   false
/// Received file header pattern, used to detect the file header, if a receive file operation is active.
#define CODELESS_LIB_CONFIG_DSPS_RX_FILE_HEADER_PATTERN_STRING   @"(?s)(.{0,100})Name:\\s*(\\S{1,100})\\s*Size:\\s*(\\d{1,9})\\s*(?:CRC:\\s*([0-9a-f]{8})\\s*)?(?:\\x00|END\\s*)(.*)" // <ignored> <name> <size> <crc> <data>

/// Enable DSPS statistics calculation.
#define CODELESS_LIB_CONFIG_DSPS_STATS   true
/// DSPS statistics update interval (ms).
#define CODELESS_LIB_CONFIG_DSPS_STATS_INTERVAL   1000 // ms

/// Check the timer index value in command arguments.
#define CODELESS_LIB_CONFIG_CHECK_TIMER_INDEX   true
/// Minimum timer index value.
#define CODELESS_LIB_CONFIG_TIMER_INDEX_MIN   0
/// Maximum timer index value.
#define CODELESS_LIB_CONFIG_TIMER_INDEX_MAX   3

/// Check the command slot index value in timer command arguments.
#define CODELESS_LIB_CONFIG_CHECK_COMMAND_INDEX   true
/// Minimum command slot index value.
#define CODELESS_LIB_CONFIG_COMMAND_INDEX_MIN   0
/// Maximum command slot index value.
#define CODELESS_LIB_CONFIG_COMMAND_INDEX_MAX   3

/// Check the GPIO function value in command arguments.
#define CODELESS_LIB_CONFIG_CHECK_GPIO_FUNCTION   true
/// Minimum GPIO function value.
#define CODELESS_LIB_CONFIG_GPIO_FUNCTION_MIN   CODELESS_COMMAND_GPIO_FUNCTION_UNDEFINED
/// Maximum GPIO function value.
#define CODELESS_LIB_CONFIG_GPIO_FUNCTION_MAX   CODELESS_COMMAND_GPIO_FUNCTION_NOT_AVAILABLE

/// Check if the selected GPIO pin in command arguments supports analog input.
#define CODELESS_LIB_CONFIG_CHECK_ANALOG_INPUT_GPIO   true

/// Check the memory slot index value in command arguments.
#define CODELESS_LIB_CONFIG_CHECK_MEM_INDEX   true
/// Minimum memory slot index value.
#define CODELESS_LIB_CONFIG_MEM_INDEX_MIN   0
/// Maximum memory slot index value.
#define CODELESS_LIB_CONFIG_MEM_INDEX_MAX   3

/// Check the memory content size in command arguments.
#define CODELESS_LIB_CONFIG_CHECK_MEM_CONTENT_SIZE   true
/// Maximum memory content size.
#define CODELESS_LIB_CONFIG_MEM_MAX_CHAR_COUNT   100

/// Check the command slot index value in command arguments.
#define CODELESS_LIB_CONFIG_CHECK_COMMAND_STORE_INDEX   true
/// Minimum command slot index value.
#define CODELESS_LIB_CONFIG_COMMAND_STORE_INDEX_MIN   0
/// Maximum command slot index value.
#define CODELESS_LIB_CONFIG_COMMAND_STORE_INDEX_MAX   3

/// Check the advertising internal value in command arguments.
#define CODELESS_LIB_CONFIG_CHECK_ADVERTISING_INTERVAL   true
/// Minimum advertising internal value (ms).
#define CODELESS_LIB_CONFIG_ADVERTISING_INTERVAL_MIN   100 // ms
/// Maximum advertising internal value (ms).
#define CODELESS_LIB_CONFIG_ADVERTISING_INTERVAL_MAX   3000 // ms

/// Check the SPI word size value in command arguments.
#define CODELESS_LIB_CONFIG_CHECK_SPI_WORD_SIZE   true
/// Supported SPI word size (bits).
#define CODELESS_LIB_CONFIG_SPI_WORD_SIZE   8 // bits

/// Check the hex string size in SPI command arguments.
#define CODELESS_LIB_CONFIG_CHECK_SPI_HEX_STRING_WRITE   true
/// Minimum SPI hex string size.
#define CODELESS_LIB_CONFIG_SPI_HEX_STRING_CHAR_SIZE_MIN   2
/// Maximum SPI hex string size.
#define CODELESS_LIB_CONFIG_SPI_HEX_STRING_CHAR_SIZE_MAX   64

/// Check the read size in SPI command arguments.
#define CODELESS_LIB_CONFIG_CHECK_SPI_READ_SIZE   true
/// Maximum SPI read size.
#define CODELESS_LIB_CONFIG_SPI_MAX_BYTE_READ_SIZE   64

/// Check the PWM frequency value in command arguments.
#define CODELESS_LIB_CONFIG_CHECK_PWM_FREQUENCY   true
/// Minimum PWM frequency value.
#define CODELESS_LIB_CONFIG_PWM_FREQUENCY_MIN   1000
/// Maximum PWM frequency value.
#define CODELESS_LIB_CONFIG_PWM_FREQUENCY_MAX   500000

/// Check the PWM duty cycle value in command arguments.
#define CODELESS_LIB_CONFIG_CHECK_PWM_DUTY_CYCLE   true
/// Minimum PWM duty cycle value.
#define CODELESS_LIB_CONFIG_PWM_DUTY_CYCLE_MIN   0
/// Maximum PWM duty cycle value.
#define CODELESS_LIB_CONFIG_PWM_DUTY_CYCLE_MAX   100

/// Check the PWM duration value in command arguments.
#define CODELESS_LIB_CONFIG_CHECK_PWM_DURATION   true
/// Minimum PWM duration value.
#define CODELESS_LIB_CONFIG_PWM_DURATION_MIN   100
/// Maximum PWM duration value.
#define CODELESS_LIB_CONFIG_PWM_DURATION_MAX   10000

/// Check the bonding entry index value in command arguments.
#define CODELESS_LIB_CONFIG_CHECK_BONDING_DATABASE_INDEX   true
/// Minimum bonding entry index value.
#define CODELESS_LIB_CONFIG_BONDING_DATABASE_INDEX_MIN   1
/// Maximum bonding entry index value.
#define CODELESS_LIB_CONFIG_BONDING_DATABASE_INDEX_MAX   5
/// Bonding entry index value that selects all entries.
#define CODELESS_LIB_CONFIG_BONDING_DATABASE_ALL_VALUES  0xff

/**
 * Send unsupported commands to the app for processing.
 * <p> Otherwise, an error response is sent by the library.
 * <p> If <code>true</code>, the app is responsible for sending a proper response.
 */
#define CODELESS_LIB_CONFIG_HOST_UNSUPPORTED_COMMANDS   false
/**
 * Send invalid commands to the app for processing.
 * <p> Otherwise, an error response is sent by the library.
 * <p> If <code>true</code>, the app is responsible for sending a proper response.
 */
#define CODELESS_LIB_CONFIG_HOST_INVALID_COMMANDS   false


/// Configuration options that configure the library behavior.
@interface CodelessLibConfig : NSObject

/// ATI command response (if <code>nil</code>, the app version is used).
@property (class, readonly) NSString* CODELESS_LIB_INFO;

/// Folder for CodeLess and DSPS log files (in app documents).
@property (class, readonly) NSString* LOG_FILE_PATH;
/// Date format used when creating log file names.
@property (class, readonly) NSDateFormatter* LOG_FILE_DATE;
/// Append the device address to the log file name.
@property (class, readonly) BOOL LOG_FILE_ADDRESS_SUFFIX;
/// Log file extension.
@property (class, readonly) NSString* LOG_FILE_EXTENSION;
/// Enable CodeLess communication log file.
@property (class, readonly) BOOL CODELESS_LOG;
/// Flush the CodeLess log file on each write.
@property (class, readonly) BOOL CODELESS_LOG_FLUSH;
/// Prefix used for the CodeLess log file name.
@property (class, readonly) NSString* CODELESS_LOG_FILE_PREFIX;
/// Prefix used for CodeLess log entries for user input.
@property (class, readonly) NSString* CODELESS_LOG_PREFIX_TEXT;
/// Prefix used for CodeLess log entries for outgoing messages.
@property (class, readonly) NSString* CODELESS_LOG_PREFIX_OUTBOUND;
/// Prefix used for CodeLess log entries for incoming messages.
@property (class, readonly) NSString* CODELESS_LOG_PREFIX_INBOUND;
/// Enable DSPS received data log file.
@property (class, readonly) BOOL DSPS_RX_LOG;
/// Flush the DSPS received data log file on each write.
@property (class, readonly) BOOL DSPS_RX_LOG_FLUSH;
/// Prefix used for the DSPS received data log file name.
@property (class, readonly) NSString* DSPS_RX_LOG_FILE_PREFIX;

/**
 * Enable priority for DSPS send data GATT operations.
 * <p>
 * High priority operations are put before low priority ones in the queue.
 * File and periodic send operations are low priority, while other DSPS operations are high priority.
 */
@property (class, readonly) BOOL GATT_QUEUE_PRIORITY;
/// Execute the next GATT operation in the queue before processing the results of the previous one.
@property (class, readonly) BOOL GATT_DEQUEUE_BEFORE_PROCESSING;
/// Monitor Bluetooth state and perform required actions.
@property (class, readonly) BOOL BLUETOOTH_STATE_MONITOR;

/// Used character set for conversion between text and bytes.
@property (class, readonly) NSStringEncoding CHARSET;
/// End of line characters used when sending text.
@property (class, readonly) NSString* END_OF_LINE;
/// Append an end of line character to the sent text (if not already there, does not apply to sent commands).
@property (class, readonly) BOOL APPEND_END_OF_LINE;
/// Append an end of line character to the sent command text (if not already there).
@property (class, readonly) BOOL END_OF_LINE_AFTER_COMMAND;
/// Add an empty line before a success response, if there is no response message.
@property (class, readonly) BOOL EMPTY_LINE_BEFORE_OK;
/// Add an empty line before an error response, if there is no response message.
@property (class, readonly) BOOL EMPTY_LINE_BEFORE_ERROR;
/// Append a null byte to the sent text.
@property (class, readonly) BOOL TRAILING_ZERO;
/// Use single write operation to send response (merge lines).
@property (class, readonly) BOOL SINGLE_WRITE_RESPONSE;

/// Do not send invalid commands which are parsed from text (for example, user input).
@property (class, readonly) BOOL DISALLOW_INVALID_PARSED_COMMAND;
/// Do not send invalid commands which are not parsed from text (for example, commands created with {@link CodelessCommands}).
@property (class, readonly) BOOL DISALLOW_INVALID_COMMAND;
/// Do not send commands which do not have a valid AT command prefix.
@property (class, readonly) BOOL DISALLOW_INVALID_PREFIX;
/// Automatically add the AT command prefix (if missing).
@property (class, readonly) BOOL AUTO_ADD_PREFIX;

/// Enable {@link CodelessLibEvent#Line Line} events.
@property (class, readonly) BOOL LINE_EVENTS;

/// Start in command mode operation, if the peer device supports CodeLess.
@property (class, readonly) BOOL START_IN_COMMAND_MODE;
/**
 * Enable {@link CodelessLibEvent#BinaryModeRequest BinaryModeRequest} event when the peer CodeLess device sends the <code>AT+BINREQ</code> command.
 * <p>
 * The app should call {@link CodelessManager#acceptBinaryModeRequest}, if the request is accepted.
 * If disabled, the library will automatically respond with <code>AT+BINREQACK</code>, entering binary mode.
 */
@property (class, readonly) BOOL HOST_BINARY_REQUEST;
/**
 * Send the <code>AT+BINREQ</code> command to the peer device to request switching to binary mode.
 * <p> If disabled, the library will send the <code>AT+BINREQACK</code> command to force the switch.
 */
@property (class, readonly) BOOL MODE_CHANGE_SEND_BINARY_REQUEST;
/// Allow incoming binary data in command mode.
@property (class, readonly) BOOL ALLOW_INBOUND_BINARY_IN_COMMAND_MODE;
/// Allow outgoing binary data in command mode.
@property (class, readonly) BOOL ALLOW_OUTBOUND_BINARY_IN_COMMAND_MODE;
/// Allow incoming commands in binary mode (mode commands are always allowed).
@property (class, readonly) BOOL ALLOW_INBOUND_COMMAND_IN_BINARY_MODE;
/// Allow outgoing commands in binary mode (mode commands are always allowed).
@property (class, readonly) BOOL ALLOW_OUTBOUND_COMMAND_IN_BINARY_MODE;

/**
 * The initial DSPS chunk size.
 * <p> WARNING: The chunk size must not exceed the value (MTU - 3), otherwise chunks will be truncated when sent.
 */
@property (class, readonly) int DEFAULT_DSPS_CHUNK_SIZE;
/// Increase the DSPS chunk size to the maximum allowed value after the MTU exchange.
@property (class, readonly) BOOL DSPS_CHUNK_SIZE_INCREASE_TO_MTU;
/// Maximum buffer size for pending binary data operations when TX flow control is off.
@property (class, readonly) int DSPS_PENDING_MAX_SIZE;
/// The initial DSPS RX flow control configuration (<code>true</code> for on, <code>false</code> for off).
@property (class, readonly) BOOL DEFAULT_DSPS_RX_FLOW_CONTROL;
/**
 * The initial DSPS TX flow control configuration (<code>true</code> for on, <code>false</code> for off).
 * <p>
 * If set to on, the library will be able to send data immediately after connection. Otherwise, it will wait for the
 * peer device to set the flow control to on by sending a notification through the DSPS Flow Control characteristic.
 */
@property (class, readonly) BOOL DEFAULT_DSPS_TX_FLOW_CONTROL;
/// Configure the RX flow control on connection by writing the appropriate value to the DSPS Flow Control characteristic.
@property (class, readonly) BOOL SET_FLOW_CONTROL_ON_CONNECTION;

/// Length of the number suffix for pattern {@link DspsPeriodicSend} operations.
@property (class, readonly) int DSPS_PATTERN_DIGITS;
/// Bytes added after the number suffix for pattern {@link DspsPeriodicSend} operations.
@property (class, readonly) NSData* DSPS_PATTERN_SUFFIX;

/// Folder for DSPS receive file operations (in app documents).
@property (class, readonly) NSString* DSPS_RX_FILE_PATH;
/// Log receive file operation data to the DSPS RX log file (if {@link #DSPS_RX_LOG enabled}).
@property (class, readonly) BOOL DSPS_RX_FILE_LOG_DATA;
/// Received file header pattern, used to detect the file header, if a receive file operation is active.
@property (class, readonly) NSString* DSPS_RX_FILE_HEADER_PATTERN_STRING;
@property (class, readonly) NSRegularExpression* DSPS_RX_FILE_HEADER_PATTERN;

/// Enable DSPS statistics calculation.
@property (class, readonly) BOOL DSPS_STATS;
/// DSPS statistics update interval (ms).
@property (class, readonly) int DSPS_STATS_INTERVAL;

/// Check the timer index value in command arguments.
@property (class, readonly) BOOL CHECK_TIMER_INDEX;
/// Minimum timer index value.
@property (class, readonly) int TIMER_INDEX_MIN;
/// Maximum timer index value.
@property (class, readonly) int TIMER_INDEX_MAX;

/// Check the command slot index value in timer command arguments.
@property (class, readonly) BOOL CHECK_COMMAND_INDEX;
/// Minimum command slot index value.
@property (class, readonly) int COMMAND_INDEX_MIN;
/// Maximum command slot index value.
@property (class, readonly) int COMMAND_INDEX_MAX;

/// Check the GPIO function value in command arguments.
@property (class, readonly) BOOL CHECK_GPIO_FUNCTION;
/// Minimum GPIO function value.
@property (class, readonly) int GPIO_FUNCTION_MIN;
/// Maximum GPIO function value.
@property (class, readonly) int GPIO_FUNCTION_MAX;

/// Check if the selected GPIO pin in command arguments supports analog input.
@property (class, readonly) BOOL CHECK_ANALOG_INPUT_GPIO;
/// GPIO pins that support analog input.
@property (class, readonly) NSArray<CodelessGPIO*>* ANALOG_INPUT_GPIO;

/// Check the memory slot index value in command arguments.
@property (class, readonly) BOOL CHECK_MEM_INDEX;
/// Minimum memory slot index value.
@property (class, readonly) int MEM_INDEX_MIN;
/// Maximum memory slot index value.
@property (class, readonly) int MEM_INDEX_MAX;

/// Check the memory content size in command arguments.
@property (class, readonly) BOOL CHECK_MEM_CONTENT_SIZE;
/// Maximum memory content size.
@property (class, readonly) int MEM_MAX_CHAR_COUNT;

/// Check the command slot index value in command arguments.
@property (class, readonly) BOOL CHECK_COMMAND_STORE_INDEX;
/// Minimum command slot index value.
@property (class, readonly) int COMMAND_STORE_INDEX_MIN;
/// Maximum command slot index value.
@property (class, readonly) int COMMAND_STORE_INDEX_MAX;

/// Check the advertising internal value in command arguments.
@property (class, readonly) BOOL CHECK_ADVERTISING_INTERVAL;
/// Minimum advertising internal value (ms).
@property (class, readonly) int ADVERTISING_INTERVAL_MIN;
/// Maximum advertising internal value (ms).
@property (class, readonly) int ADVERTISING_INTERVAL_MAX;

/// Check the SPI word size value in command arguments.
@property (class, readonly) BOOL CHECK_SPI_WORD_SIZE;
/// Supported SPI word size (bits).
@property (class, readonly) int SPI_WORD_SIZE;

/// Check the hex string size in SPI command arguments.
@property (class, readonly) BOOL CHECK_SPI_HEX_STRING_WRITE;
/// Minimum SPI hex string size.
@property (class, readonly) int SPI_HEX_STRING_CHAR_SIZE_MIN;
/// Maximum SPI hex string size.
@property (class, readonly) int SPI_HEX_STRING_CHAR_SIZE_MAX;

/// Check the read size in SPI command arguments.
@property (class, readonly) BOOL CHECK_SPI_READ_SIZE;
/// Maximum SPI read size.
@property (class, readonly) int SPI_MAX_BYTE_READ_SIZE;

/// Check the PWM frequency value in command arguments.
@property (class, readonly) BOOL CHECK_PWM_FREQUENCY;
/// Minimum PWM frequency value.
@property (class, readonly) int PWM_FREQUENCY_MIN;
/// Maximum PWM frequency value.
@property (class, readonly) int PWM_FREQUENCY_MAX;

/// Check the PWM duty cycle value in command arguments.
@property (class, readonly) BOOL CHECK_PWM_DUTY_CYCLE;
/// Minimum PWM duty cycle value.
@property (class, readonly) int PWM_DUTY_CYCLE_MIN;
/// Maximum PWM duty cycle value.
@property (class, readonly) int PWM_DUTY_CYCLE_MAX;

/// Check the PWM duration value in command arguments.
@property (class, readonly) BOOL CHECK_PWM_DURATION;
/// Minimum PWM duration value.
@property (class, readonly) int PWM_DURATION_MIN;
/// Maximum PWM duration value.
@property (class, readonly) int PWM_DURATION_MAX;

/// Check the bonding entry index value in command arguments.
@property (class, readonly) BOOL CHECK_BONDING_DATABASE_INDEX;
/// Minimum bonding entry index value.
@property (class, readonly) int BONDING_DATABASE_INDEX_MIN;
/// Maximum bonding entry index value.
@property (class, readonly) int BONDING_DATABASE_INDEX_MAX;
/// Bonding entry index value that selects all entries.
@property (class, readonly) int BONDING_DATABASE_ALL_VALUES;

// GPIO configurations
/// DA14585 GPIO pin configuration.
@property (class, readonly) NSArray<CodelessGPIO*>* GPIO_LIST_585;
/// DA14531 GPIO pin configuration.
@property (class, readonly) NSArray<CodelessGPIO*>* GPIO_LIST_531;
/// Supported GPIO configurations.
@property (class, readonly) NSArray<NSArray<CodelessGPIO*>*>* GPIO_CONFIGURATIONS;

/**
 * Commands to be processed by the library.
 * <p> The library provides a default implementation with an appropriate response for each command.
 * @see CodelessCommand#processInbound
 */
@property (class, readonly) NSSet<NSNumber*>* supportedCommands;

/**
 * Commands to be sent to the app for processing.
 * <p>
 * Add here the commands that you want to be processed by the app.
 * The app is responsible for sending a proper response.
 * Use {@link CodelessManager#sendResponse: sendResponse}, {@link CodelessManager#sendSuccess: sendSuccess},
 * {@link CodelessManager#sendError: sendError} to send the response to the peer device.
 */
@property (class, readonly) NSSet<NSNumber*>* hostCommands;

/**
 * Send unsupported commands to the app for processing.
 * <p> Otherwise, an error response is sent by the library.
 * <p> If <code>true</code>, the app is responsible for sending a proper response.
 */
@property (class, readonly) BOOL HOST_UNSUPPORTED_COMMANDS;
/**
 * Send invalid commands to the app for processing.
 * <p> Otherwise, an error response is sent by the library.
 * <p> If <code>true</code>, the app is responsible for sending a proper response.
 */
@property (class, readonly) BOOL HOST_INVALID_COMMANDS;

@end

NS_ASSUME_NONNULL_END
