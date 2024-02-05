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

#import "CodelessLibConfig.h"
#import "CodelessProfile.h"

@implementation CodelessLibConfig

static NSDateFormatter* LOG_FILE_DATE;
static NSData* DSPS_PATTERN_SUFFIX;
static NSRegularExpression* DSPS_RX_FILE_HEADER_PATTERN;
static NSArray<CodelessGPIO*>* ANALOG_INPUT_GPIO;
static NSArray<CodelessGPIO*>* GPIO_LIST_585;
static NSArray<CodelessGPIO*>* GPIO_LIST_531;
static NSArray<NSArray<CodelessGPIO*>*>* GPIO_CONFIGURATIONS;
static NSSet<NSNumber*>* supportedCommands;
static NSSet<NSNumber*>* hostCommands;

+ (void) initialize {
    if (self != CodelessLibConfig.class)
        return;

    LOG_FILE_DATE = [NSDateFormatter new];
    LOG_FILE_DATE.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    LOG_FILE_DATE.dateFormat = CODELESS_LIB_CONFIG_LOG_FILE_DATE;

    const uint8_t dspsPatternSuffix[] = { 0x0a };
    DSPS_PATTERN_SUFFIX = [NSData dataWithBytes:dspsPatternSuffix length:sizeof(dspsPatternSuffix)];

    NSError* error;
    DSPS_RX_FILE_HEADER_PATTERN = [NSRegularExpression regularExpressionWithPattern:CODELESS_LIB_CONFIG_DSPS_RX_FILE_HEADER_PATTERN_STRING options:NSRegularExpressionCaseInsensitive error:&error];

    ANALOG_INPUT_GPIO = @[
            [[CodelessGPIO alloc] initWithPort:0 pin:0],
            [[CodelessGPIO alloc] initWithPort:0 pin:1],
            [[CodelessGPIO alloc] initWithPort:0 pin:2],
            [[CodelessGPIO alloc] initWithPort:0 pin:3],
    ];

    // GPIO configurations
    GPIO_LIST_585 = @[
            // Port 0, Pin 0-7, 8-9 not used
            [[CodelessGPIO alloc] initWithPort:0 pin:0],
            [[CodelessGPIO alloc] initWithPort:0 pin:1],
            [[CodelessGPIO alloc] initWithPort:0 pin:2],
            [[CodelessGPIO alloc] initWithPort:0 pin:3],
            [[CodelessGPIO alloc] initWithPort:0 pin:4],
            [[CodelessGPIO alloc] initWithPort:0 pin:5],
            [[CodelessGPIO alloc] initWithPort:0 pin:6],
            [[CodelessGPIO alloc] initWithPort:0 pin:7],
            [CodelessGPIO new], [CodelessGPIO new],
            // Port 1, Pin 0-5, 6-9 not used
            [[CodelessGPIO alloc] initWithPort:1 pin:0],
            [[CodelessGPIO alloc] initWithPort:1 pin:1],
            [[CodelessGPIO alloc] initWithPort:1 pin:2],
            [[CodelessGPIO alloc] initWithPort:1 pin:3],
            [[CodelessGPIO alloc] initWithPort:1 pin:4],
            [[CodelessGPIO alloc] initWithPort:1 pin:5],
            [CodelessGPIO new], [CodelessGPIO new],
            [CodelessGPIO new], [CodelessGPIO new],
            // Port 2, Pin 0-9
            [[CodelessGPIO alloc] initWithPort:2 pin:0],
            [[CodelessGPIO alloc] initWithPort:2 pin:1],
            [[CodelessGPIO alloc] initWithPort:2 pin:2],
            [[CodelessGPIO alloc] initWithPort:2 pin:3],
            [[CodelessGPIO alloc] initWithPort:2 pin:4],
            [[CodelessGPIO alloc] initWithPort:2 pin:5],
            [[CodelessGPIO alloc] initWithPort:2 pin:6],
            [[CodelessGPIO alloc] initWithPort:2 pin:7],
            [[CodelessGPIO alloc] initWithPort:2 pin:8],
            [[CodelessGPIO alloc] initWithPort:2 pin:9],
            // Port 3, Pin 0, 1-6 not used
            [[CodelessGPIO alloc] initWithPort:3 pin:0],
            [CodelessGPIO new], [CodelessGPIO new], [CodelessGPIO new],
            [CodelessGPIO new], [CodelessGPIO new], [CodelessGPIO new]
    ];

    GPIO_LIST_531 = @[
            // Port 0, Pin 0-11
            [[CodelessGPIO alloc] initWithPort:0 pin:0],
            [[CodelessGPIO alloc] initWithPort:0 pin:1],
            [[CodelessGPIO alloc] initWithPort:0 pin:2],
            [[CodelessGPIO alloc] initWithPort:0 pin:3],
            [[CodelessGPIO alloc] initWithPort:0 pin:4],
            [[CodelessGPIO alloc] initWithPort:0 pin:5],
            [[CodelessGPIO alloc] initWithPort:0 pin:6],
            [[CodelessGPIO alloc] initWithPort:0 pin:7],
            [[CodelessGPIO alloc] initWithPort:0 pin:8],
            [[CodelessGPIO alloc] initWithPort:0 pin:9],
            [[CodelessGPIO alloc] initWithPort:0 pin:10],
            [[CodelessGPIO alloc] initWithPort:0 pin:11]
    ];

    GPIO_CONFIGURATIONS = @[
            GPIO_LIST_585,
            GPIO_LIST_531,
    ];

    // Commands to be process by the library.
    supportedCommands = [NSSet setWithArray:@[
            @(CODELESS_COMMAND_ID_AT),
            @(CODELESS_COMMAND_ID_ATI),
            @(CODELESS_COMMAND_ID_BINREQ),
            @(CODELESS_COMMAND_ID_BINREQACK),
            @(CODELESS_COMMAND_ID_BINREQEXIT),
            @(CODELESS_COMMAND_ID_BINREQEXITACK),
            @(CODELESS_COMMAND_ID_RANDOM),
            @(CODELESS_COMMAND_ID_BATT),
            @(CODELESS_COMMAND_ID_BDADDR),
            @(CODELESS_COMMAND_ID_GAPSTATUS),
            @(CODELESS_COMMAND_ID_PRINT),
    ]];

    // Commands to be sent to the app for processing.
    // App is responsible for sending a proper response.
    hostCommands = [NSSet setWithArray:@[
    ]];
}

+ (NSString*) CODELESS_LIB_INFO {
    return CODELESS_LIB_CONFIG_INFO;
}

+ (NSString*) LOG_FILE_PATH {
    return CODELESS_LIB_CONFIG_LOG_FILE_PATH;
}

+ (NSDateFormatter*) LOG_FILE_DATE {
    return LOG_FILE_DATE;
}

+ (BOOL) LOG_FILE_ADDRESS_SUFFIX {
    return CODELESS_LIB_CONFIG_LOG_FILE_ADDRESS_SUFFIX;
}

+ (NSString*) LOG_FILE_EXTENSION {
    return CODELESS_LIB_CONFIG_LOG_FILE_EXTENSION;
}

+ (BOOL) CODELESS_LOG {
    return CODELESS_LIB_CONFIG_CODELESS_LOG;
}

+ (BOOL) CODELESS_LOG_FLUSH {
    return CODELESS_LIB_CONFIG_CODELESS_LOG_FLUSH;
}

+ (NSString*) CODELESS_LOG_FILE_PREFIX {
    return CODELESS_LIB_CONFIG_CODELESS_LOG_FILE_PREFIX;
}

+ (NSString*) CODELESS_LOG_PREFIX_TEXT {
    return CODELESS_LIB_CONFIG_CODELESS_LOG_PREFIX_TEXT;
}

+ (NSString*) CODELESS_LOG_PREFIX_OUTBOUND {
    return CODELESS_LIB_CONFIG_CODELESS_LOG_PREFIX_OUTBOUND;
}

+ (NSString*) CODELESS_LOG_PREFIX_INBOUND {
    return CODELESS_LIB_CONFIG_CODELESS_LOG_PREFIX_INBOUND;
}

+ (BOOL) DSPS_RX_LOG {
    return CODELESS_LIB_CONFIG_DSPS_RX_LOG;
}

+ (BOOL) DSPS_RX_LOG_FLUSH {
    return CODELESS_LIB_CONFIG_DSPS_RX_LOG_FLUSH;
}

+ (NSString*) DSPS_RX_LOG_FILE_PREFIX {
    return CODELESS_LIB_CONFIG_DSPS_RX_LOG_FILE_PREFIX;
}

+ (BOOL) GATT_QUEUE_PRIORITY {
    return CODELESS_LIB_CONFIG_GATT_QUEUE_PRIORITY;
}

+ (BOOL) GATT_DEQUEUE_BEFORE_PROCESSING {
    return CODELESS_LIB_CONFIG_GATT_DEQUEUE_BEFORE_PROCESSING;
}

+ (BOOL) BLUETOOTH_STATE_MONITOR {
    return CODELESS_LIB_CONFIG_BLUETOOTH_STATE_MONITOR;
}

+ (NSStringEncoding) CHARSET {
    return CODELESS_LIB_CONFIG_CHARSET;
}

+ (NSString*) END_OF_LINE {
    return CODELESS_LIB_CONFIG_END_OF_LINE;
}

+ (BOOL) APPEND_END_OF_LINE {
    return CODELESS_LIB_CONFIG_APPEND_END_OF_LINE;
}

+ (BOOL) END_OF_LINE_AFTER_COMMAND {
    return CODELESS_LIB_CONFIG_END_OF_LINE_AFTER_COMMAND;
}

+ (BOOL) EMPTY_LINE_BEFORE_OK {
    return CODELESS_LIB_CONFIG_EMPTY_LINE_BEFORE_OK;
}

+ (BOOL) EMPTY_LINE_BEFORE_ERROR {
    return CODELESS_LIB_CONFIG_EMPTY_LINE_BEFORE_ERROR;
}

+ (BOOL) TRAILING_ZERO {
    return CODELESS_LIB_CONFIG_TRAILING_ZERO;
}

+ (BOOL) SINGLE_WRITE_RESPONSE {
    return CODELESS_LIB_CONFIG_SINGLE_WRITE_RESPONSE;
}

+ (BOOL) DISALLOW_INVALID_PARSED_COMMAND {
    return CODELESS_LIB_CONFIG_DISALLOW_INVALID_PARSED_COMMAND;
}

+ (BOOL) DISALLOW_INVALID_COMMAND {
    return CODELESS_LIB_CONFIG_DISALLOW_INVALID_COMMAND;
}

+ (BOOL) DISALLOW_INVALID_PREFIX {
    return CODELESS_LIB_CONFIG_DISALLOW_INVALID_PREFIX;
}

+ (BOOL) AUTO_ADD_PREFIX {
    return CODELESS_LIB_CONFIG_AUTO_ADD_PREFIX;
}

+ (BOOL) LINE_EVENTS {
    return CODELESS_LIB_CONFIG_LINE_EVENTS;
}

+ (BOOL) START_IN_COMMAND_MODE {
    return CODELESS_LIB_CONFIG_START_IN_COMMAND_MODE;
}

+ (BOOL) HOST_BINARY_REQUEST {
    return CODELESS_LIB_CONFIG_HOST_BINARY_REQUEST;
}

+ (BOOL) MODE_CHANGE_SEND_BINARY_REQUEST {
    return CODELESS_LIB_CONFIG_MODE_CHANGE_SEND_BINARY_REQUEST;
}

+ (BOOL) ALLOW_INBOUND_BINARY_IN_COMMAND_MODE {
    return CODELESS_LIB_CONFIG_ALLOW_INBOUND_BINARY_IN_COMMAND_MODE;
}

+ (BOOL) ALLOW_OUTBOUND_BINARY_IN_COMMAND_MODE {
    return CODELESS_LIB_CONFIG_ALLOW_OUTBOUND_BINARY_IN_COMMAND_MODE;
}

+ (BOOL) ALLOW_INBOUND_COMMAND_IN_BINARY_MODE {
    return CODELESS_LIB_CONFIG_ALLOW_INBOUND_COMMAND_IN_BINARY_MODE;
}

+ (BOOL) ALLOW_OUTBOUND_COMMAND_IN_BINARY_MODE {
    return CODELESS_LIB_CONFIG_ALLOW_OUTBOUND_COMMAND_IN_BINARY_MODE;
}

+ (int) DEFAULT_DSPS_CHUNK_SIZE {
    return CODELESS_LIB_CONFIG_DEFAULT_DSPS_CHUNK_SIZE;
}

+ (BOOL) DSPS_CHUNK_SIZE_INCREASE_TO_MTU {
    return CODELESS_LIB_CONFIG_DSPS_CHUNK_SIZE_INCREASE_TO_MTU;
}

+ (int) DSPS_PENDING_MAX_SIZE {
    return CODELESS_LIB_CONFIG_DSPS_PENDING_MAX_SIZE;
}

+ (BOOL) DEFAULT_DSPS_RX_FLOW_CONTROL {
    return CODELESS_LIB_CONFIG_DEFAULT_DSPS_RX_FLOW_CONTROL;
}

+ (BOOL) DEFAULT_DSPS_TX_FLOW_CONTROL {
    return CODELESS_LIB_CONFIG_DEFAULT_DSPS_TX_FLOW_CONTROL;
}

+ (BOOL) SET_FLOW_CONTROL_ON_CONNECTION {
    return CODELESS_LIB_CONFIG_SET_FLOW_CONTROL_ON_CONNECTION;
}

+ (int) DSPS_PATTERN_DIGITS {
    return CODELESS_LIB_CONFIG_DSPS_PATTERN_DIGITS;
}

+ (NSData*) DSPS_PATTERN_SUFFIX {
    return DSPS_PATTERN_SUFFIX;
}

+ (NSString*) DSPS_RX_FILE_PATH {
    return CODELESS_LIB_CONFIG_DSPS_RX_FILE_PATH;
}

+ (BOOL) DSPS_RX_FILE_LOG_DATA {
    return CODELESS_LIB_CONFIG_DSPS_RX_FILE_LOG_DATA;
}

+ (NSString*) DSPS_RX_FILE_HEADER_PATTERN_STRING {
    return CODELESS_LIB_CONFIG_DSPS_RX_FILE_HEADER_PATTERN_STRING;
}

+ (NSRegularExpression*) DSPS_RX_FILE_HEADER_PATTERN {
    return DSPS_RX_FILE_HEADER_PATTERN;
}

+ (BOOL) DSPS_STATS {
    return CODELESS_LIB_CONFIG_DSPS_STATS;
}

+ (int) DSPS_STATS_INTERVAL {
    return CODELESS_LIB_CONFIG_DSPS_STATS_INTERVAL;
}

+ (BOOL) CHECK_TIMER_INDEX {
    return CODELESS_LIB_CONFIG_CHECK_TIMER_INDEX;
}

+ (int) TIMER_INDEX_MIN {
    return CODELESS_LIB_CONFIG_TIMER_INDEX_MIN;
}

+ (int) TIMER_INDEX_MAX {
    return CODELESS_LIB_CONFIG_TIMER_INDEX_MAX;
}

+ (BOOL) CHECK_COMMAND_INDEX {
    return CODELESS_LIB_CONFIG_CHECK_COMMAND_INDEX;
}

+ (int) COMMAND_INDEX_MIN {
    return CODELESS_LIB_CONFIG_COMMAND_INDEX_MIN;
}

+ (int) COMMAND_INDEX_MAX {
    return CODELESS_LIB_CONFIG_COMMAND_INDEX_MAX;
}

+ (BOOL) CHECK_GPIO_FUNCTION {
    return CODELESS_LIB_CONFIG_CHECK_GPIO_FUNCTION;
}

+ (int) GPIO_FUNCTION_MIN {
    return CODELESS_LIB_CONFIG_GPIO_FUNCTION_MIN;
}

+ (int) GPIO_FUNCTION_MAX {
    return CODELESS_LIB_CONFIG_GPIO_FUNCTION_MAX;
}

+ (BOOL) CHECK_ANALOG_INPUT_GPIO {
    return CODELESS_LIB_CONFIG_CHECK_ANALOG_INPUT_GPIO;
}

+ (NSArray<CodelessGPIO*>*) ANALOG_INPUT_GPIO {
    return ANALOG_INPUT_GPIO;
}

+ (BOOL) CHECK_MEM_INDEX {
    return CODELESS_LIB_CONFIG_CHECK_MEM_INDEX;
}

+ (int) MEM_INDEX_MIN {
    return CODELESS_LIB_CONFIG_MEM_INDEX_MIN;
}

+ (int) MEM_INDEX_MAX {
    return CODELESS_LIB_CONFIG_MEM_INDEX_MAX;
}

+ (BOOL) CHECK_MEM_CONTENT_SIZE {
    return CODELESS_LIB_CONFIG_CHECK_MEM_CONTENT_SIZE;
}

+ (int) MEM_MAX_CHAR_COUNT {
    return CODELESS_LIB_CONFIG_MEM_MAX_CHAR_COUNT;
}

+ (BOOL) CHECK_COMMAND_STORE_INDEX {
    return CODELESS_LIB_CONFIG_CHECK_COMMAND_STORE_INDEX;
}

+ (int) COMMAND_STORE_INDEX_MIN {
    return CODELESS_LIB_CONFIG_COMMAND_STORE_INDEX_MIN;
}

+ (int) COMMAND_STORE_INDEX_MAX {
    return CODELESS_LIB_CONFIG_COMMAND_STORE_INDEX_MAX;
}

+ (BOOL) CHECK_ADVERTISING_INTERVAL {
    return CODELESS_LIB_CONFIG_CHECK_ADVERTISING_INTERVAL;
}

+ (int) ADVERTISING_INTERVAL_MIN {
    return CODELESS_LIB_CONFIG_ADVERTISING_INTERVAL_MIN;
}

+ (int) ADVERTISING_INTERVAL_MAX {
    return CODELESS_LIB_CONFIG_ADVERTISING_INTERVAL_MAX;
}

+ (BOOL) CHECK_SPI_WORD_SIZE {
    return CODELESS_LIB_CONFIG_CHECK_SPI_WORD_SIZE;
}

+ (int) SPI_WORD_SIZE {
    return CODELESS_LIB_CONFIG_SPI_WORD_SIZE;
}

+ (BOOL) CHECK_SPI_HEX_STRING_WRITE {
    return CODELESS_LIB_CONFIG_CHECK_SPI_HEX_STRING_WRITE;
}

+ (int) SPI_HEX_STRING_CHAR_SIZE_MIN {
    return CODELESS_LIB_CONFIG_SPI_HEX_STRING_CHAR_SIZE_MIN;
}

+ (int) SPI_HEX_STRING_CHAR_SIZE_MAX {
    return CODELESS_LIB_CONFIG_SPI_HEX_STRING_CHAR_SIZE_MAX;
}

+ (BOOL) CHECK_SPI_READ_SIZE {
    return CODELESS_LIB_CONFIG_CHECK_SPI_READ_SIZE;
}

+ (int) SPI_MAX_BYTE_READ_SIZE {
    return CODELESS_LIB_CONFIG_SPI_MAX_BYTE_READ_SIZE;
}

+ (BOOL) CHECK_PWM_FREQUENCY {
    return CODELESS_LIB_CONFIG_CHECK_PWM_FREQUENCY;
}

+ (int) PWM_FREQUENCY_MIN {
    return CODELESS_LIB_CONFIG_PWM_FREQUENCY_MIN;
}

+ (int) PWM_FREQUENCY_MAX {
    return CODELESS_LIB_CONFIG_PWM_FREQUENCY_MAX;
}

+ (BOOL) CHECK_PWM_DUTY_CYCLE {
    return CODELESS_LIB_CONFIG_CHECK_PWM_DUTY_CYCLE;
}

+ (int) PWM_DUTY_CYCLE_MIN {
    return CODELESS_LIB_CONFIG_PWM_DUTY_CYCLE_MIN;
}

+ (int) PWM_DUTY_CYCLE_MAX {
    return CODELESS_LIB_CONFIG_PWM_DUTY_CYCLE_MAX;
}

+ (BOOL) CHECK_PWM_DURATION {
    return CODELESS_LIB_CONFIG_CHECK_PWM_DURATION;
}

+ (int) PWM_DURATION_MIN {
    return CODELESS_LIB_CONFIG_PWM_DURATION_MIN;
}

+ (int) PWM_DURATION_MAX {
    return CODELESS_LIB_CONFIG_PWM_DURATION_MAX;
}

+ (BOOL) CHECK_BONDING_DATABASE_INDEX {
    return CODELESS_LIB_CONFIG_CHECK_BONDING_DATABASE_INDEX;
}

+ (int) BONDING_DATABASE_INDEX_MIN {
    return CODELESS_LIB_CONFIG_BONDING_DATABASE_INDEX_MIN;
}

+ (int) BONDING_DATABASE_INDEX_MAX {
    return CODELESS_LIB_CONFIG_BONDING_DATABASE_INDEX_MAX;
}

+ (int) BONDING_DATABASE_ALL_VALUES {
    return CODELESS_LIB_CONFIG_BONDING_DATABASE_ALL_VALUES;
}

+ (NSArray<CodelessGPIO*>*) GPIO_LIST_585 {
    return GPIO_LIST_585;
}

+ (NSArray<CodelessGPIO*>*) GPIO_LIST_531 {
    return GPIO_LIST_531;
}

+ (NSArray<NSArray<CodelessGPIO*>*>*) GPIO_CONFIGURATIONS {
    return GPIO_CONFIGURATIONS;
}

+ (NSSet<NSNumber*>*) supportedCommands {
    return supportedCommands;
}

+ (NSSet<NSNumber*>*) hostCommands {
    return hostCommands;
}

+ (BOOL) HOST_UNSUPPORTED_COMMANDS {
    return CODELESS_LIB_CONFIG_HOST_UNSUPPORTED_COMMANDS;
}

+ (BOOL) HOST_INVALID_COMMANDS {
    return CODELESS_LIB_CONFIG_HOST_INVALID_COMMANDS;
}

@end
