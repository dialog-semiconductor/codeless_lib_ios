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

@class CBUUID;
@class CodelessManager;
@class CodelessCommand;
@class CodelessErrorCodeMessage;

NS_ASSUME_NONNULL_BEGIN

/**
 * Contains definitions of static values used by the CodeLess and DSPS protocols, as well as helper classes and methods.
 * @see CodelessManager
 * @see CodelessBluetoothManager
 * @see <a href="https://lpccs-docs.renesas.com/UM-140-DA145x-CodeLess/index.html">CodeLess User Manual</a>
 */
@interface CodelessProfile : NSObject

@property (class, readonly) NSString* TAG;

// UUID strings
#define CODELESS_UUID_CLIENT_CONFIG_DESCRIPTOR   @"00002902-0000-1000-8000-00805f9b34fb"
// Codeless
#define CODELESS_UUID_CODELESS_SERVICE   @"866d3b04-e674-40dc-9c05-b7f91bec6e83"
#define CODELESS_UUID_CODELESS_INBOUND_COMMAND   @"914f8fb9-e8cd-411d-b7d1-14594de45425"
#define CODELESS_UUID_CODELESS_OUTBOUND_COMMAND   @"3bb535aa-50b2-4fbe-aa09-6b06dc59a404"
#define CODELESS_UUID_CODELESS_FLOW_CONTROL   @"e2048b39-d4f9-4a45-9f25-1856c10d5639"
// DSPS
#define CODELESS_UUID_DSPS_SERVICE   @"0783b03e-8535-b5a0-7140-a304d2495cb7"
#define CODELESS_UUID_DSPS_SERVER_TX   @"0783b03e-8535-b5a0-7140-a304d2495cb8"
#define CODELESS_UUID_DSPS_SERVER_RX   @"0783b03e-8535-b5a0-7140-a304d2495cba"
#define CODELESS_UUID_DSPS_FLOW_CONTROL   @"0783b03e-8535-b5a0-7140-a304d2495cb9"
// Other
#define CODELESS_UUID_SUOTA_SERVICE   @"0000fef5-0000-1000-8000-00805f9b34fb"
#define CODELESS_UUID_IOT_SERVICE   @"2ea78970-7d44-44bb-b097-26183f402400"
#define CODELESS_UUID_WEARABLES_580_SERVICE   @"00002800-0000-1000-8000-00805f9b34fb"
#define CODELESS_UUID_WEARABLES_680_SERVICE   @"00002ea7-0000-1000-8000-00805f9b34fb"
#define CODELESS_UUID_MESH_PROVISIONING_SERVICE   @"00001827-0000-1000-8000-00805f9b34fb"
#define CODELESS_UUID_MESH_PROXY_SERVICE   @"00001828-0000-1000-8000-00805f9b34fb"
#define CODELESS_UUID_IMMEDIATE_ALERT_SERVICE   @"00001802-0000-1000-8000-00805f9b34fb"
#define CODELESS_UUID_LINK_LOSS_SERVICE   @"00001803-0000-1000-8000-00805f9b34fb"
// Device information service
#define CODELESS_UUID_DEVICE_INFORMATION_SERVICE   @"0000180a-0000-1000-8000-00805f9b34fb"
#define CODELESS_UUID_MANUFACTURER_NAME_STRING   @"00002A29-0000-1000-8000-00805f9b34fb"
#define CODELESS_UUID_MODEL_NUMBER_STRING   @"00002A24-0000-1000-8000-00805f9b34fb"
#define CODELESS_UUID_SERIAL_NUMBER_STRING   @"00002A25-0000-1000-8000-00805f9b34fb"
#define CODELESS_UUID_HARDWARE_REVISION_STRING   @"00002A27-0000-1000-8000-00805f9b34fb"
#define CODELESS_UUID_FIRMWARE_REVISION_STRING   @"00002A26-0000-1000-8000-00805f9b34fb"
#define CODELESS_UUID_SOFTWARE_REVISION_STRING   @"00002A28-0000-1000-8000-00805f9b34fb"
#define CODELESS_UUID_SYSTEM_ID   @"00002A23-0000-1000-8000-00805f9b34fb"
#define CODELESS_UUID_IEEE_11073   @"00002A2A-0000-1000-8000-00805f9b34fb"
#define CODELESS_UUID_PNP_ID   @"00002A50-0000-1000-8000-00805f9b34fb"

// UUID
@property (class, readonly) CBUUID* CLIENT_CONFIG_DESCRIPTOR;
// Codeless
@property (class, readonly) CBUUID* CODELESS_SERVICE_UUID;
@property (class, readonly) CBUUID* CODELESS_INBOUND_COMMAND_UUID;
@property (class, readonly) CBUUID* CODELESS_OUTBOUND_COMMAND_UUID;
@property (class, readonly) CBUUID* CODELESS_FLOW_CONTROL_UUID;
// DSPS
@property (class, readonly) CBUUID* DSPS_SERVICE_UUID;
@property (class, readonly) CBUUID* DSPS_SERVER_TX_UUID;
@property (class, readonly) CBUUID* DSPS_SERVER_RX_UUID;
@property (class, readonly) CBUUID* DSPS_FLOW_CONTROL_UUID;
// Other
@property (class, readonly) CBUUID* SUOTA_SERVICE_UUID;
@property (class, readonly) CBUUID* IOT_SERVICE_UUID;
@property (class, readonly) CBUUID* WEARABLES_580_SERVICE_UUID;
@property (class, readonly) CBUUID* WEARABLES_680_SERVICE_UUID;
@property (class, readonly) CBUUID* MESH_PROVISIONING_SERVICE_UUID;
@property (class, readonly) CBUUID* MESH_PROXY_SERVICE_UUID;
@property (class, readonly) CBUUID* IMMEDIATE_ALERT_SERVICE_UUID;
@property (class, readonly) CBUUID* LINK_LOSS_SERVICE_UUID;
// Device information service
@property (class, readonly) CBUUID* DEVICE_INFORMATION_SERVICE_UUID;
@property (class, readonly) CBUUID* MANUFACTURER_NAME_STRING_UUID;
@property (class, readonly) CBUUID* MODEL_NUMBER_STRING_UUID;
@property (class, readonly) CBUUID* SERIAL_NUMBER_STRING_UUID;
@property (class, readonly) CBUUID* HARDWARE_REVISION_STRING_UUID;
@property (class, readonly) CBUUID* FIRMWARE_REVISION_STRING_UUID;
@property (class, readonly) CBUUID* SOFTWARE_REVISION_STRING_UUID;
@property (class, readonly) CBUUID* SYSTEM_ID_UUID;
@property (class, readonly) CBUUID* IEEE_11073_UUID;
@property (class, readonly) CBUUID* PNP_ID_UUID;

/// The default MTU value of the connection.
#define CODELESS_MTU_DEFAULT   23

// DSPS flow control
/// Value used to set the DSPS TX/RX flow to on.
#define CODELESS_DSPS_XON   0x01
/// Value used to set the DSPS TX/RX flow to off.
#define CODELESS_DSPS_XOFF   0x02

// Codeless flow control
/**
 * Value notified by the peer device, through the {@link #CODELESS_FLOW_CONTROL_UUID flow control} characteristic, when there are CodeLess data ready to be received.
 * <p> After receiving this notification, the library reads the {@link #CODELESS_OUTBOUND_COMMAND_UUID outbound} characteristic to get the data.
 */
#define CODELESS_DATA_PENDING   0x01

// Patterns
/// AT command prefix.
@property (class, readonly) NSString* PREFIX;
/// Local AT command prefix.
@property (class, readonly) NSString* PREFIX_LOCAL;
/**
 * Remote AT command prefix.
 * <p>
 * The library always uses the remote prefix to send commands to the peer device,
 * except for unidentified commands, which are sent verbatim, and mode commands,
 * which always use the local prefix.
 */
@property (class, readonly) NSString* PREFIX_REMOTE;
/// AT command prefix pattern.
@property (class, readonly) NSString* PREFIX_PATTERN_STRING;
@property (class, readonly) NSRegularExpression* PREFIX_PATTERN;
/// AT command pattern.
@property (class, readonly) NSString* COMMAND_PATTERN_STRING;
@property (class, readonly) NSRegularExpression* COMMAND_PATTERN;
/// AT command with arguments prefix pattern.
@property (class, readonly) NSString* COMMAND_WITH_ARGUMENTS_PREFIX_PATTERN_STRING;
@property (class, readonly) NSRegularExpression* COMMAND_WITH_ARGUMENTS_PREFIX_PATTERN;
/// AT command with arguments pattern.
@property (class, readonly) NSString* COMMAND_WITH_ARGUMENTS_PATTERN_STRING;
@property (class, readonly) NSRegularExpression* COMMAND_WITH_ARGUMENTS_PATTERN;

/**
 * Checks if a command string starts with the AT prefix.
 * @param command the command string to check
 */
+ (BOOL) hasPrefix:(NSString*)command;
/**
 * Gets the AT command prefix from a command string.
 * @param command the command string
 */
+ (NSString*) getPrefix:(NSString*)command;
/**
 * Checks if a command string is a valid AT command.
 * @param command the command string to check
 */
+ (BOOL) isCommand:(NSString*)command;
/**
 * Gets the AT command text identifier from a command string.
 * @param command the command string
 */
+ (NSString*) getCommand:(NSString*)command;
/**
 * Removes the AT prefix from a command string.
 * @param command the command string
 */
+ (NSString*) removeCommandPrefix:(NSString*)command;
/**
 * Checks if a command string contains arguments.
 * @param command the command string to check
 */
+ (BOOL) hasArguments:(NSString*)command;
/**
 * Gets the number of arguments contained in a command string.
 * @param command   the command string to check
 * @param split     the delimiter used to separate the arguments
 */
+ (int) countArguments:(NSString*)command split:(NSString*)split;

/// CodeLess command success response.
@property (class, readonly) NSString* OK;
/// CodeLess command error response.
@property (class, readonly) NSString* ERROR;
/// Error message prefix for sending an error response to the peer device.
@property (class, readonly) NSString* ERROR_PREFIX;
/// Error message for invalid command.
@property (class, readonly) NSString* INVALID_COMMAND;
/// Error message for unsupported command.
@property (class, readonly) NSString* COMMAND_NOT_SUPPORTED;
/// Error message for missing arguments.
@property (class, readonly) NSString* NO_ARGUMENTS;
/// Error message for wrong number of arguments.
@property (class, readonly) NSString* WRONG_NUMBER_OF_ARGUMENTS;
/// Error message for invalid arguments.
@property (class, readonly) NSString* INVALID_ARGUMENTS;
/// Error message for GATT operation error (local).
@property (class, readonly) NSString* GATT_OPERATION_ERROR;
/// Error message pattern, when receiving an error response from the peer device.
@property (class, readonly) NSString* ERROR_MESSAGE_PATTERN_STRING;
@property (class, readonly) NSRegularExpression* ERROR_MESSAGE_PATTERN;
/// Error message for invalid command received from peer device.
@property (class, readonly) NSString* PEER_INVALID_COMMAND;
/// Error code/message pattern received from peer device.
@property (class, readonly) NSString* ERROR_CODE_PATTERN_STRING;
@property (class, readonly) NSRegularExpression* ERROR_CODE_PATTERN;

/**
 * Checks if a command response indicates success.
 * @param response the response to check
 */
+ (BOOL) isSuccess:(NSString*)response;
/**
 * Checks if a command response indicates failure.
 * @param response the response to check
 */
+ (BOOL) isError:(NSString*)response;
/**
 * Checks if a command response contains an error message.
 * @param response the response to check
 */
+ (BOOL) isErrorMessage:(NSString*)response;
/**
 * Checks if an error message indicates an invalid command.
 * @param error the error message to check
 */
+ (BOOL) isPeerInvalidCommand:(NSString*)error;
/**
 * Checks if an error message contains an error code/message pattern.
 * @param error the error message to check
 */
+ (BOOL) isErrorCodeMessage:(NSString*)error;
/**
 * Parses an error code/message response.
 * @param error the error message to parse
 */
+ (CodelessErrorCodeMessage*) parseErrorCodeMessage:(NSString*)error;

/// <code>ATE</code> command
enum {
    CODELESS_COMMAND_UART_ECHO_OFF = 0,
    CODELESS_COMMAND_UART_ECHO_ON = 1,
};

/// <code>ATF</code> command
enum {
    CODELESS_COMMAND_ERROR_REPORTING_OFF = 0,
    CODELESS_COMMAND_ERROR_REPORTING_ON = 1,
};

/// <code>AT+FLOWCONTROL</code> command
enum {
    CODELESS_COMMAND_DISABLE_UART_FLOW_CONTROL = 0,
    CODELESS_COMMAND_ENABLE_UART_FLOW_CONTROL = 1,
};

/// <code>AT+SLEEP</code> command
enum {
    CODELESS_COMMAND_AWAKE_DEVICE = 0,
    CODELESS_COMMAND_PUT_DEVICE_IN_SLEEP = 1,
};

// BINESC
#define CODELESS_COMMAND_BINESC_TIME_PRIOR_DEFAULT   1000
#define CODELESS_COMMAND_BINESC_TIME_AFTER_DEFAULT   1000

/// GPIO pin functionality
enum CODELESS_COMMAND_GPIO_FUNCTION {
    CODELESS_COMMAND_GPIO_FUNCTION_UNDEFINED = 0,
    CODELESS_COMMAND_GPIO_FUNCTION_INPUT = 1,
    CODELESS_COMMAND_GPIO_FUNCTION_INPUT_PULL_UP = 2,
    CODELESS_COMMAND_GPIO_FUNCTION_INPUT_PULL_DOWN = 3,
    CODELESS_COMMAND_GPIO_FUNCTION_OUTPUT = 4,
    CODELESS_COMMAND_GPIO_FUNCTION_ANALOG_INPUT = 5,
    CODELESS_COMMAND_GPIO_FUNCTION_ANALOG_INPUT_ATTENUATION = 6,
    CODELESS_COMMAND_GPIO_FUNCTION_I2C_CLK = 7,
    CODELESS_COMMAND_GPIO_FUNCTION_I2C_SDA = 8,
    CODELESS_COMMAND_GPIO_FUNCTION_CONNECTION_INDICATOR_HIGH = 9,
    CODELESS_COMMAND_GPIO_FUNCTION_CONNECTION_INDICATOR_LOW = 10,
    CODELESS_COMMAND_GPIO_FUNCTION_UART_TX = 11,
    CODELESS_COMMAND_GPIO_FUNCTION_UART_RX = 12,
    CODELESS_COMMAND_GPIO_FUNCTION_UART_CTS = 13,
    CODELESS_COMMAND_GPIO_FUNCTION_UART_RTS = 14,
    CODELESS_COMMAND_GPIO_FUNCTION_UART2_TX = 15, // Reserved
    CODELESS_COMMAND_GPIO_FUNCTION_UART2_RX = 16, // Reserved
    CODELESS_COMMAND_GPIO_FUNCTION_UART2_CTS = 17, // Reserved
    CODELESS_COMMAND_GPIO_FUNCTION_UART2_RTS = 18, // Reserved
    CODELESS_COMMAND_GPIO_FUNCTION_SPI_CLK = 19,
    CODELESS_COMMAND_GPIO_FUNCTION_SPI_CS = 20,
    CODELESS_COMMAND_GPIO_FUNCTION_SPI_MOSI = 21,
    CODELESS_COMMAND_GPIO_FUNCTION_SPI_MISO = 22,
    CODELESS_COMMAND_GPIO_FUNCTION_PWM1 = 23, // Reserved
    CODELESS_COMMAND_GPIO_FUNCTION_PWM = 24,
    CODELESS_COMMAND_GPIO_FUNCTION_PWM2 = 25, // Reserved
    CODELESS_COMMAND_GPIO_FUNCTION_PWM3 = 26, // Reserved
    CODELESS_COMMAND_GPIO_FUNCTION_HEARTBEAT = 27,
    CODELESS_COMMAND_GPIO_FUNCTION_NOT_AVAILABLE = 28,
};

/// GPIO pin status
enum CODELESS_COMMAND_PIN_STATUS {
    CODELESS_COMMAND_PIN_STATUS_LOW = 0,
    CODELESS_COMMAND_PIN_STATUS_HIGH = 1,
};

/**
 * Checks if value represents a binary pin state.
 * @param state the value to check
 */
+ (BOOL) isBinaryState:(int)state;
/**
 * Packs a GPIO port/pin to an <code>int</code> value.
 * @param port  the port number
 * @param pin   the pin number
 * @return the packed value (10 x port + pin)
 */
+ (int) gpioPackPort:(int)port pin:(int)pin;
/**
 * Gets the GPIO port number from a packed value.
 * @param pack the packed port/pin value
 * @return the port number
 * @see #gpioPackPort:pin:
 */
+ (int) gpioGetPort:(int)pack;
/**
 * Gets the GPIO pin number from a packed value.
 * @param pack the packed port/pin value
 * @return the pin number
 * @see #gpioPackPort:pin:
 */
+ (int) gpioGetPin:(int)pack;


/// GAP role
enum {
    CODELESS_COMMAND_GAP_ROLE_PERIPHERAL = 0,
    CODELESS_COMMAND_GAP_ROLE_CENTRAL = 1,
};

/// GAP status
enum {
    CODELESS_COMMAND_GAP_STATUS_DISCONNECTED = 0,
    CODELESS_COMMAND_GAP_STATUS_CONNECTED = 1,
};

#define CODELESS_COMMAND_GAP_ADDRESS_TYPE_PUBLIC_STRING   @"P"
#define CODELESS_COMMAND_GAP_ADDRESS_TYPE_RANDOM_STRING   @"R"
/// Bluetooth address type
enum CODELESS_COMMAND_GAP_ADDRESS_TYPE {
    CODELESS_COMMAND_GAP_ADDRESS_TYPE_PUBLIC = 0,
    CODELESS_COMMAND_GAP_ADDRESS_TYPE_RANDOM = 1,
};

#define CODELESS_COMMAND_GAP_SCAN_TYPE_ADV_STRING   @"ADV"
#define CODELESS_COMMAND_GAP_SCAN_TYPE_RSP_STRING   @"RSP"
/// Advertising packet type
enum {
    CODELESS_COMMAND_GAP_SCAN_TYPE_ADV = 0,
    CODELESS_COMMAND_GAP_SCAN_TYPE_RSP = 1,
};

/// Connection parameters configuration values
enum {
    CODELESS_COMMAND_CONNECTION_INTERVAL_MIN = 6,
    CODELESS_COMMAND_CONNECTION_INTERVAL_MAX = 3200,
    CODELESS_COMMAND_SLAVE_LATENCY_MIN = 0,
    CODELESS_COMMAND_SLAVE_LATENCY_MAX = 500,
    CODELESS_COMMAND_SUPERVISION_TIMEOUT_MIN = 10,
    CODELESS_COMMAND_SUPERVISION_TIMEOUT_MAX = 3200,
};

/// Connection parameters action values
enum {
    CODELESS_COMMAND_PARAMETER_UPDATE_DISABLE = 0,
    CODELESS_COMMAND_PARAMETER_UPDATE_ON_CONNECTION = 1,
    CODELESS_COMMAND_PARAMETER_UPDATE_NOW_ONLY = 2,
    CODELESS_COMMAND_PARAMETER_UPDATE_NOW_SAVE = 3,
    CODELESS_COMMAND_PARAMETER_UPDATE_ACTION_MIN = CODELESS_COMMAND_PARAMETER_UPDATE_DISABLE,
    CODELESS_COMMAND_PARAMETER_UPDATE_ACTION_MAX = CODELESS_COMMAND_PARAMETER_UPDATE_NOW_SAVE,
};

/// MTU configuration values
enum {
    CODELESS_COMMAND_MTU_MIN = 23,
    CODELESS_COMMAND_MTU_MAX = 512,
};

/// DLE configuration values
enum {
    CODELESS_COMMAND_DLE_DISABLED = 0,
    CODELESS_COMMAND_DLE_ENABLED = 1,
    CODELESS_COMMAND_DLE_PACKET_LENGTH_MIN = 27,
    CODELESS_COMMAND_DLE_PACKET_LENGTH_MAX = 251,
    CODELESS_COMMAND_DLE_PACKET_LENGTH_DEFAULT = 251,
};

/// SPI clock value
enum CODELESS_COMMAND_SPI_CLOCK_VALUE {
    CODELESS_COMMAND_SPI_CLOCK_VALUE_2_MHZ = 0,
    CODELESS_COMMAND_SPI_CLOCK_VALUE_4_MHZ = 1,
    CODELESS_COMMAND_SPI_CLOCK_VALUE_8_MHZ = 2,
};

/// SPI mode (clock polarity and phase)
enum CODELESS_COMMAND_SPI_MODE {
    CODELESS_COMMAND_SPI_MODE_0 = 0,
    CODELESS_COMMAND_SPI_MODE_1 = 1,
    CODELESS_COMMAND_SPI_MODE_2 = 2,
    CODELESS_COMMAND_SPI_MODE_3 = 3,
};

/// Baud rate
enum CODELESS_COMMAND_BAUD_RATE {
    CODELESS_COMMAND_BAUD_RATE_2400 = 2400,
    CODELESS_COMMAND_BAUD_RATE_4800 = 4800,
    CODELESS_COMMAND_BAUD_RATE_9600 = 9600,
    CODELESS_COMMAND_BAUD_RATE_19200 = 19200,
    CODELESS_COMMAND_BAUD_RATE_38400 = 38400,
    CODELESS_COMMAND_BAUD_RATE_57600 = 57600,
    CODELESS_COMMAND_BAUD_RATE_115200 = 115200,
    CODELESS_COMMAND_BAUD_RATE_230400 = 230400,
};

/// Output power level
enum CODELESS_COMMAND_OUTPUT_POWER_LEVEL {
    CODELESS_COMMAND_OUTPUT_POWER_LEVEL_MINUS_19_POINT_5_DBM = 1,
    CODELESS_COMMAND_OUTPUT_POWER_LEVEL_MINUS_13_POINT_5_DBM = 2,
    CODELESS_COMMAND_OUTPUT_POWER_LEVEL_MINUS_10_DBM = 3,
    CODELESS_COMMAND_OUTPUT_POWER_LEVEL_MINUS_7_DBM = 4,
    CODELESS_COMMAND_OUTPUT_POWER_LEVEL_MINUS_5_DBM = 5,
    CODELESS_COMMAND_OUTPUT_POWER_LEVEL_MINUS_3_POINT_5_DBM = 6,
    CODELESS_COMMAND_OUTPUT_POWER_LEVEL_MINUS_2_DBM = 7,
    CODELESS_COMMAND_OUTPUT_POWER_LEVEL_MINUS_1_DBM = 8,
    CODELESS_COMMAND_OUTPUT_POWER_LEVEL_0_DBM = 9,
    CODELESS_COMMAND_OUTPUT_POWER_LEVEL_1_DBM = 10,
    CODELESS_COMMAND_OUTPUT_POWER_LEVEL_1_POINT_5_DBM = 11,
    CODELESS_COMMAND_OUTPUT_POWER_LEVEL_2_POINT_5_DBM = 12,
};

#define CODELESS_COMMAND_OUTPUT_POWER_LEVEL_NOT_SUPPORTED   @"NOT SUPPORTED"

/// Event configuration (status)
enum CODELESS_COMMAND_EVENT_CONFIG_STATUS {
    CODELESS_COMMAND_DEACTIVATE_EVENT = 0,
    CODELESS_COMMAND_ACTIVATE_EVENT = 1,
};

/// Event configuration (type)
enum CODELESS_COMMAND_EVENT_CONFIG_TYPE {
    CODELESS_COMMAND_INITIALIZATION_EVENT = 1,
    CODELESS_COMMAND_CONNECTION_EVENT = 2,
    CODELESS_COMMAND_DISCONNECTION_EVENT = 3,
    CODELESS_COMMAND_WAKEUP_EVENT = 4,
};

/// Bonding entry persistence status
enum CODELESS_COMMAND_BONDING_ENTRY_PERSISTENCE {
    CODELESS_COMMAND_BONDING_ENTRY_NON_PERSISTENT = 0,
    CODELESS_COMMAND_BONDING_ENTRY_PERSISTENT = 1,
};

/// Event handler configuration (type)
enum CODELESS_COMMAND_EVENT_HANDLER_CONFIG {
    CODELESS_COMMAND_CONNECTION_EVENT_HANDLER = 1,
    CODELESS_COMMAND_DISCONNECTION_EVENT_HANDLER = 2,
    CODELESS_COMMAND_WAKEUP_EVENT_HANDLER = 3,
};

/// <code>AT+HRTBT</code> command
enum CODELESS_COMMAND_HEARTBEAT {
    CODELESS_COMMAND_HEARTBEAT_DISABLED = 0,
    CODELESS_COMMAND_HEARTBEAT_ENABLED = 1,
};

/// <code>AT+HOSTSLP</code> command
enum CODELESS_COMMAND_HOST_SLEEP_MODE {
    CODELESS_COMMAND_HOST_SLEEP_MODE_0 = 0,
    CODELESS_COMMAND_HOST_SLEEP_MODE_1 = 1,
};

/// Security mode
enum CODELESS_COMMAND_SECURITY_MODE {
    /// LE secure connections pairing.
    CODELESS_COMMAND_SECURITY_MODE_0 = 0,
    /// Legacy pairing with MITM protection.
    CODELESS_COMMAND_SECURITY_MODE_1 = 1,
    /// Legacy pairing without MITM protection (Just Works).
    CODELESS_COMMAND_SECURITY_MODE_2 = 2,
    /// No security.
    CODELESS_COMMAND_SECURITY_MODE_3 = 3,
};

/// Commands that can change the operation mode.
@property (class, readonly) NSSet<NSNumber*>* modeCommands;
/**
 * Checks if the specified command is a mode command.
 * @param command the command to check
 */
+ (BOOL) isModeCommand:(CodelessCommand*)command;

/**
 * Map each command text identifier to a {@link CodelessCommand} subclass.
 * <p> Used for command parsing.
 */
@property (class, readonly) NSDictionary<NSString*, Class>* commandMap;
/**
 * Creates a {@link CodelessCommand} subclass object from the specified command text.
 * @param manager       the associated manager
 * @param commandClass  the CodelessCommand subclass type
 * @param command       the command text to parse
 * @return the created command object
 */
+ (CodelessCommand*) createCommand:(CodelessManager*)manager commandClass:(Class)commandClass command:(NSString*)command;

/**
 * Enumeration of CodeLess command identifiers.
 * <p>
 * Each value starts with <code>CODELESS_COMMAND_ID_</code> and the rest is
 * the same as the corresponding command text identifier, except for
 * single character commands, like <code>ATI</code>, where the prefix is also present,
 * and <code>CUSTOM</code>, which is used for unidentified commands.
 * <p>
 * Used for quick referencing or checking of the command identifier.
 */
enum CODELESS_COMMAND_ID {
    CODELESS_COMMAND_ID_AT,
    CODELESS_COMMAND_ID_ATI,
    CODELESS_COMMAND_ID_ATE,
    CODELESS_COMMAND_ID_ATZ,
    CODELESS_COMMAND_ID_ATF,
    CODELESS_COMMAND_ID_ATR,
    CODELESS_COMMAND_ID_BINREQ,
    CODELESS_COMMAND_ID_BINREQACK,
    CODELESS_COMMAND_ID_BINREQEXIT,
    CODELESS_COMMAND_ID_BINREQEXITACK,
    CODELESS_COMMAND_ID_BINRESUME,
    CODELESS_COMMAND_ID_BINESC,
    CODELESS_COMMAND_ID_TMRSTART,
    CODELESS_COMMAND_ID_TMRSTOP,
    CODELESS_COMMAND_ID_CURSOR,
    CODELESS_COMMAND_ID_RANDOM,
    CODELESS_COMMAND_ID_BATT,
    CODELESS_COMMAND_ID_BDADDR,
    CODELESS_COMMAND_ID_RSSI,
    CODELESS_COMMAND_ID_FLOWCONTROL,
    CODELESS_COMMAND_ID_SLEEP,
    CODELESS_COMMAND_ID_IOCFG,
    CODELESS_COMMAND_ID_IO,
    CODELESS_COMMAND_ID_ADC,
    CODELESS_COMMAND_ID_I2CSCAN,
    CODELESS_COMMAND_ID_I2CCFG,
    CODELESS_COMMAND_ID_I2CREAD,
    CODELESS_COMMAND_ID_I2CWRITE,
    CODELESS_COMMAND_ID_PRINT,
    CODELESS_COMMAND_ID_MEM,
    CODELESS_COMMAND_ID_PIN,
    CODELESS_COMMAND_ID_CMDSTORE,
    CODELESS_COMMAND_ID_CMDPLAY,
    CODELESS_COMMAND_ID_CMD,
    CODELESS_COMMAND_ID_ADVSTOP,
    CODELESS_COMMAND_ID_ADVSTART,
    CODELESS_COMMAND_ID_ADVDATA,
    CODELESS_COMMAND_ID_ADVRESP,
    CODELESS_COMMAND_ID_CENTRAL,
    CODELESS_COMMAND_ID_PERIPHERAL,
    CODELESS_COMMAND_ID_BROADCASTER,
    CODELESS_COMMAND_ID_GAPSTATUS,
    CODELESS_COMMAND_ID_GAPSCAN,
    CODELESS_COMMAND_ID_GAPCONNECT,
    CODELESS_COMMAND_ID_GAPDISCONNECT,
    CODELESS_COMMAND_ID_CONPAR,
    CODELESS_COMMAND_ID_MAXMTU,
    CODELESS_COMMAND_ID_DLEEN,
    CODELESS_COMMAND_ID_HOSTSLP,
    CODELESS_COMMAND_ID_SPICFG,
    CODELESS_COMMAND_ID_SPIWR,
    CODELESS_COMMAND_ID_SPIRD,
    CODELESS_COMMAND_ID_SPITR,
    CODELESS_COMMAND_ID_BAUD,
    CODELESS_COMMAND_ID_PWRLVL,
    CODELESS_COMMAND_ID_PWM,
    CODELESS_COMMAND_ID_EVENT,
    CODELESS_COMMAND_ID_CLRBNDE,
    CODELESS_COMMAND_ID_CHGBNDP,
    CODELESS_COMMAND_ID_IEBNDE,
    CODELESS_COMMAND_ID_HNDL,
    CODELESS_COMMAND_ID_SEC,
    CODELESS_COMMAND_ID_HRTBT,

    CODELESS_COMMAND_ID_CUSTOM
};

@end


/// Error code and message received as response to a command that failed.
@interface CodelessErrorCodeMessage : NSObject

/// The error code of the failure.
@property int code;
/// The error message describing the failure.
@property NSString* message;

- (instancetype) initWithCode:(int)code message:(NSString*)message;

@end


/**
 * Information about a CodeLess communication line.
 * <p> May be used to distinguish between incoming and outgoing messages, commands and responses.
 * @see CodelessLibEvent#Line
 */
@interface CodelessLine : NSObject

/// The type of a CodeLess communication line.
enum {
    CodelessLineInboundCommand,
    CodelessLineInboundResponse,
    CodelessLineInboundOK,
    CodelessLineInboundError,
    CodelessLineInboundEmpty,
    CodelessLineOutboundCommand,
    CodelessLineOutboundResponse,
    CodelessLineOutboundOK,
    CodelessLineOutboundError,
    CodelessLineOutboundEmpty
};

/// The communication text.
@property (readonly) NSString* text;
/// The line type.
@property (readonly) int type;

- (instancetype) initWithText:(NSString*)text type:(int)type;
- (instancetype) initWithType:(int)type;

/// Checks if the line is received from the peer device.
- (BOOL) isInbound;
/// Checks if the line is sent to the peer device.
- (BOOL) isOutbound;
/// Checks if the line is a command.
- (BOOL) isCommand;
/// Checks if the line is a response.
- (BOOL) isResponse;
/// Checks if the line represents command success.
- (BOOL) isOK;
/// Checks if the line contains a command error.
- (BOOL) isError;
/// Checks if the line is empty.
- (BOOL) isEmpty;

@end


/**
 * General Purpose Input Output pin.
 * <p> Used by various CodeLess commands to select or configure the peer device IO pins.
 */
@interface CodelessGPIO : NSObject

/// Indicates that the configuration option is not set.
#define CODELESS_GPIO_INVALID -1

/// The IO port number.
@property int port;
/// The IO pin number.
@property int pin;
/// The IO pin state.
@property int state;
/// The IO pin {@link CodelessProfile#CODELESS_COMMAND_GPIO_FUNCTION functionality}.
@property int function;
/// The IO pin level.
@property int level;

- initWithPort:(int)port pin:(int)pin;
- initWithPort:(int)port pin:(int)pin function:(int)function;
- initWithPort:(int)port pin:(int)pin function:(int)function level:(int)level;
- initWithPack:(int)pack;
- initWithGPIO:(CodelessGPIO*)gpio;
- initWithGPIO:(CodelessGPIO*)gpio function:(int)function;
- initWithGPIO:(CodelessGPIO*)gpio function:(int)function level:(int)level;

/**
 * Updates the IO pin configuration options, copying them from the specified GPIO.
 * @param gpio the GPIO to copy. Only valid configuration options are copied.
 */
- (void) update:(CodelessGPIO*)gpio;
/// Returns the IO pin as a new object, with no other configuration options set.
- (CodelessGPIO*) gpioPin;

/// Checks if the IO pin is valid.
- (BOOL) validGpio;
/**
 * Returns the IO port/pin packed to an <code>int</code> value.
 * @see CodelessProfile#gpioPackPort:pin:
 */
- (int) getGpio;
/**
 * Sets the IO port/pin by unpacking an <code>int</code> value.
 * @param pack the packed port/pin value
 * @see CodelessProfile#gpioGetPort:
 * @see CodelessProfile#gpioGetPin:
 */
- (void) setGpio:(int)pack;
/**
 * Sets the IO port/pin.
 * @param port  the IO port number
 * @param pin   the IO pin number
 */
- (void) setGpioPort:(int)port pin:(int)pin;

/// Checks if the IO pin state is valid.
- (BOOL) validState;
/// Checks if the IO pin state is binary low.
- (BOOL) isLow;
/// Checks if the IO pin state is binary high.
- (BOOL) isHigh;
/// Checks if the IO pin state is binary.
- (BOOL) isBinary;
/// Sets the IO pin state to binary low.
- (void) setLow;
/// Sets the IO pin state to binary high.
- (void) setHigh;
/**
 * Sets the IO pin binary state.
 * @param status <code>true</code> for high, <code>false</code> for low
 */
- (void) setStatus:(BOOL)status;

/// Checks if the IO pin functionality is valid.
- (BOOL) validFunction;
/// Checks if the IO pin is a binary input pin.
- (BOOL) isInput;
/// Checks if the IO pin is a binary output pin.
- (BOOL) isOutput;
/// Checks if the IO pin is an analog input pin.
- (BOOL) isAnalog;
/// Checks if the IO pin is used for PWM pulse generation.
- (BOOL) isPwm;
/// Checks if the IO pin is used for I2C operation.
- (BOOL) isI2c;
/// Checks if the IO pin is used for SPI operation.
- (BOOL) isSpi;
/// Checks if the IO pin is used for UART operation.
- (BOOL) isUart;
/// Checks if the IO pin level is valid.
- (BOOL) validLevel;

/**
 * Creates a copy of a GPIO configuration list.
 * @param config the GPIO configuration list to copy
 */
+ (NSArray<CodelessGPIO*>*) copyConfig:(NSArray<CodelessGPIO*>*)config;
/**
 * Updates a GPIO configuration list, by copying configuration options from another one.
 * <p> If the lists contain different pins, a copy is created. Only valid configuration options are copied.
 * @param config the GPIO configuration list to update
 * @param update the GPIO configuration list to copy
 * @return the updated GPIO configuration list
 */
+ (NSArray<CodelessGPIO*>*) updateConfig:(NSArray<CodelessGPIO*>*)config update:(NSArray<CodelessGPIO*>*)update;

/// Returns a text representation of the IO port/pin that can be used as an identifier.
- (NSString*) name;

@end


/// Information about the activation status of one of the predefined events.
@interface CodelessEventConfig : NSObject

/// The event type (1: initialization, 2: connection, 3: disconnection, 4: wakeup).
@property int type;
/// <code>true</code> if the event is activated, <code>false</code> if it is deactivated.
@property BOOL status;

- (instancetype) initWithType:(int)type status:(BOOL)status;

@end


/// Information about a device found during a scan performed by the peer device.
@interface CodelessGapScannedDevice : NSObject

/// The Bluetooth address of the found device.
@property NSString* address;
/// The type of the Bluetooth address (public, random).
@property int addressType;
/// The type of the advertising packet (advertising, scan response).
@property int type;
/// The RSSI of the advertising event.
@property int rssi;

@end


/// Information about the event handler for one of the predefined events.
@interface CodelessEventHandler : NSObject

/// The event type (1: connection, 2: disconnection, 3: wakeup).
@property int event;
/// The commands to be executed when the event occurs.
@property NSMutableArray<CodelessCommand*>* commands;

@end


/// Bonding database entry configuration.
@interface CodelessBondingEntry : NSObject

/// The Long Term Key (LTK).
@property NSData* ltk;
/// The Encrypted Diversifier (EDIV).
@property uint16_t ediv;
/// The random number (RAND).
@property NSData* rand;
/// The key size.
@property uint8_t keySize;
/// The Connection Signature Resolving Key (CSRK).
@property NSData* csrk;
/// The peer Bluetooth address.
@property NSData* bluetoothAddress;
/// The peer Bluetooth address type.
@property uint8_t addressType;
/// The authentication level.
@property uint8_t authenticationLevel;
/// The bonding database slot.
@property uint8_t bondingDatabaseSlot;
/// The Identity Resolving Key (IRK).
@property NSData* irk;
/// The entry persistence status.
@property uint8_t persistenceStatus;
/// The entry timestamp.
@property NSData* timestamp;

@end

NS_ASSUME_NONNULL_END
