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

#import <CoreBluetooth/CoreBluetooth.h>
#import "CodelessCommand.h"
#import "CodelessProfile.h"
#import "CodelessBasicCommand.h"
#import "CodelessDeviceInformationCommand.h"
#import "CodelessUartEchoCommand.h"
#import "CodelessResetIoConfigCommand.h"
#import "CodelessErrorReportingCommand.h"
#import "CodelessResetCommand.h"
#import "CodelessBinRequestCommand.h"
#import "CodelessBinRequestAckCommand.h"
#import "CodelessBinExitCommand.h"
#import "CodelessBinExitAckCommand.h"
#import "CodelessBinResumeCommand.h"
#import "CodelessBinEscCommand.h"
#import "CodelessTimerStartCommand.h"
#import "CodelessTimerStopCommand.h"
#import "CodelessCursorCommand.h"
#import "CodelessRandomNumberCommand.h"
#import "CodelessBatteryLevelCommand.h"
#import "CodelessBluetoothAddressCommand.h"
#import "CodelessRssiCommand.h"
#import "CodelessDeviceSleepCommand.h"
#import "CodelessIoConfigCommand.h"
#import "CodelessIoStatusCommand.h"
#import "CodelessAdcReadCommand.h"
#import "CodelessI2cScanCommand.h"
#import "CodelessI2cConfigCommand.h"
#import "CodelessI2cReadCommand.h"
#import "CodelessI2cWriteCommand.h"
#import "CodelessUartPrintCommand.h"
#import "CodelessMemStoreCommand.h"
#import "CodelessPinCodeCommand.h"
#import "CodelessCmdStoreCommand.h"
#import "CodelessCmdPlayCommand.h"
#import "CodelessCmdGetCommand.h"
#import "CodelessAdvertisingStopCommand.h"
#import "CodelessAdvertisingStartCommand.h"
#import "CodelessAdvertisingDataCommand.h"
#import "CodelessAdvertisingResponseCommand.h"
#import "CodelessCentralRoleSetCommand.h"
#import "CodelessPeripheralRoleSetCommand.h"
#import "CodelessBroadcasterRoleSetCommand.h"
#import "CodelessGapStatusCommand.h"
#import "CodelessGapScanCommand.h"
#import "CodelessGapConnectCommand.h"
#import "CodelessGapDisconnectCommand.h"
#import "CodelessConnectionParametersCommand.h"
#import "CodelessMaxMtuCommand.h"
#import "CodelessDataLengthEnableCommand.h"
#import "CodelessSpiConfigCommand.h"
#import "CodelessSpiWriteCommand.h"
#import "CodelessSpiReadCommand.h"
#import "CodelessSpiTransferCommand.h"
#import "CodelessBaudRateCommand.h"
#import "CodelessPowerLevelConfigCommand.h"
#import "CodelessPulseGenerationCommand.h"
#import "CodelessEventConfigCommand.h"
#import "CodelessBondingEntryClearCommand.h"
#import "CodelessBondingEntryStatusCommand.h"
#import "CodelessBondingEntryTransferCommand.h"
#import "CodelessEventHandlerCommand.h"
#import "CodelessHeartbeatCommand.h"
#import "CodelessHostSleepCommand.h"
#import "CodelessSecurityModeCommand.h"
#import "CodelessFlowControlCommand.h"
#import "CodelessLibLog.h"
#import "CodelessCustomCommand.h"

@implementation CodelessProfile

static NSString* const TAG = @"CodelessProfile";
+ (NSString*) TAG {
    return TAG;
}

// UUID
static CBUUID* CLIENT_CONFIG_DESCRIPTOR;
static CBUUID* CODELESS_SERVICE_UUID;
static CBUUID* CODELESS_INBOUND_COMMAND_UUID;
static CBUUID* CODELESS_OUTBOUND_COMMAND_UUID;
static CBUUID* CODELESS_FLOW_CONTROL_UUID;
static CBUUID* DSPS_SERVICE_UUID;
static CBUUID* DSPS_SERVER_TX_UUID;
static CBUUID* DSPS_SERVER_RX_UUID;
static CBUUID* DSPS_FLOW_CONTROL_UUID;
static CBUUID* SUOTA_SERVICE_UUID;
static CBUUID* IOT_SERVICE_UUID;
static CBUUID* WEARABLES_580_SERVICE_UUID;
static CBUUID* WEARABLES_680_SERVICE_UUID;
static CBUUID* MESH_PROVISIONING_SERVICE_UUID;
static CBUUID* MESH_PROXY_SERVICE_UUID;
static CBUUID* IMMEDIATE_ALERT_SERVICE_UUID;
static CBUUID* LINK_LOSS_SERVICE_UUID;
static CBUUID* DEVICE_INFORMATION_SERVICE_UUID;
static CBUUID* MANUFACTURER_NAME_STRING_UUID;
static CBUUID* MODEL_NUMBER_STRING_UUID;
static CBUUID* SERIAL_NUMBER_STRING_UUID;
static CBUUID* HARDWARE_REVISION_STRING_UUID;
static CBUUID* FIRMWARE_REVISION_STRING_UUID;
static CBUUID* SOFTWARE_REVISION_STRING_UUID;
static CBUUID* SYSTEM_ID_UUID;
static CBUUID* IEEE_11073_UUID;
static CBUUID* PNP_ID_UUID;

// Patterns
static NSString* PREFIX;
static NSString* PREFIX_LOCAL;
static NSString* PREFIX_REMOTE;
static NSString* PREFIX_PATTERN_STRING;
static NSRegularExpression* PREFIX_PATTERN;
static NSRegularExpression* PREFIX_REMOVE_PATTERN;
static NSString* COMMAND_PATTERN_STRING;
static NSRegularExpression* COMMAND_PATTERN;
static NSString* COMMAND_WITH_ARGUMENTS_PREFIX_PATTERN_STRING;
static NSRegularExpression* COMMAND_WITH_ARGUMENTS_PREFIX_PATTERN;
static NSString* COMMAND_WITH_ARGUMENTS_PATTERN_STRING;
static NSRegularExpression* COMMAND_WITH_ARGUMENTS_PATTERN;

static NSString* OK;
static NSString* ERROR;
static NSString* ERROR_PREFIX;
static NSString* INVALID_COMMAND;
static NSString* COMMAND_NOT_SUPPORTED;
static NSString* NO_ARGUMENTS;
static NSString* WRONG_NUMBER_OF_ARGUMENTS;
static NSString* INVALID_ARGUMENTS;
static NSString* GATT_OPERATION_ERROR;
static NSString* ERROR_MESSAGE_PATTERN_STRING;
static NSRegularExpression* ERROR_MESSAGE_PATTERN;
static NSString* PEER_INVALID_COMMAND;
static NSString* ERROR_CODE_PATTERN_STRING;
static NSRegularExpression* ERROR_CODE_PATTERN;

static NSDictionary<NSString*, Class>* commandMap;
static NSSet<NSNumber*>* modeCommands;

+ (void) initialize {
    if (self != CodelessProfile.class)
        return;

    CLIENT_CONFIG_DESCRIPTOR = [CBUUID UUIDWithString:CODELESS_UUID_CLIENT_CONFIG_DESCRIPTOR];
    CODELESS_SERVICE_UUID = [CBUUID UUIDWithString:CODELESS_UUID_CODELESS_SERVICE];
    CODELESS_INBOUND_COMMAND_UUID = [CBUUID UUIDWithString:CODELESS_UUID_CODELESS_INBOUND_COMMAND];
    CODELESS_OUTBOUND_COMMAND_UUID = [CBUUID UUIDWithString:CODELESS_UUID_CODELESS_OUTBOUND_COMMAND];
    CODELESS_FLOW_CONTROL_UUID = [CBUUID UUIDWithString:CODELESS_UUID_CODELESS_FLOW_CONTROL];
    DSPS_SERVICE_UUID = [CBUUID UUIDWithString:CODELESS_UUID_DSPS_SERVICE];
    DSPS_SERVER_TX_UUID = [CBUUID UUIDWithString:CODELESS_UUID_DSPS_SERVER_TX];
    DSPS_SERVER_RX_UUID = [CBUUID UUIDWithString:CODELESS_UUID_DSPS_SERVER_RX];
    DSPS_FLOW_CONTROL_UUID = [CBUUID UUIDWithString:CODELESS_UUID_DSPS_FLOW_CONTROL];
    SUOTA_SERVICE_UUID = [CBUUID UUIDWithString:CODELESS_UUID_SUOTA_SERVICE];
    IOT_SERVICE_UUID = [CBUUID UUIDWithString:CODELESS_UUID_IOT_SERVICE];
    WEARABLES_580_SERVICE_UUID = [CBUUID UUIDWithString:CODELESS_UUID_WEARABLES_580_SERVICE];
    WEARABLES_680_SERVICE_UUID = [CBUUID UUIDWithString:CODELESS_UUID_WEARABLES_680_SERVICE];
    MESH_PROVISIONING_SERVICE_UUID = [CBUUID UUIDWithString:CODELESS_UUID_MESH_PROVISIONING_SERVICE];
    MESH_PROXY_SERVICE_UUID = [CBUUID UUIDWithString:CODELESS_UUID_MESH_PROXY_SERVICE];
    IMMEDIATE_ALERT_SERVICE_UUID = [CBUUID UUIDWithString:CODELESS_UUID_IMMEDIATE_ALERT_SERVICE];
    LINK_LOSS_SERVICE_UUID = [CBUUID UUIDWithString:CODELESS_UUID_LINK_LOSS_SERVICE];
    DEVICE_INFORMATION_SERVICE_UUID = [CBUUID UUIDWithString:CODELESS_UUID_DEVICE_INFORMATION_SERVICE];
    MANUFACTURER_NAME_STRING_UUID = [CBUUID UUIDWithString:CODELESS_UUID_MANUFACTURER_NAME_STRING];
    MODEL_NUMBER_STRING_UUID = [CBUUID UUIDWithString:CODELESS_UUID_MODEL_NUMBER_STRING];
    SERIAL_NUMBER_STRING_UUID = [CBUUID UUIDWithString:CODELESS_UUID_SERIAL_NUMBER_STRING];
    HARDWARE_REVISION_STRING_UUID = [CBUUID UUIDWithString:CODELESS_UUID_HARDWARE_REVISION_STRING];
    FIRMWARE_REVISION_STRING_UUID = [CBUUID UUIDWithString:CODELESS_UUID_FIRMWARE_REVISION_STRING];
    SOFTWARE_REVISION_STRING_UUID = [CBUUID UUIDWithString:CODELESS_UUID_SOFTWARE_REVISION_STRING];
    SYSTEM_ID_UUID = [CBUUID UUIDWithString:CODELESS_UUID_SYSTEM_ID];
    IEEE_11073_UUID = [CBUUID UUIDWithString:CODELESS_UUID_IEEE_11073];
    PNP_ID_UUID = [CBUUID UUIDWithString:CODELESS_UUID_PNP_ID];

    NSError* error;
    PREFIX = @"AT";
    PREFIX_LOCAL = [PREFIX stringByAppendingString:@"+"];
    PREFIX_REMOTE = [PREFIX stringByAppendingString:@"r"];
    PREFIX_PATTERN_STRING = [NSString stringWithFormat:@"^%@(?:\\+|r\\+?)?", PREFIX];
    PREFIX_PATTERN = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"(%@).*", PREFIX_PATTERN_STRING] options:0 error:&error]; // <prefix>
    PREFIX_REMOVE_PATTERN = [NSRegularExpression regularExpressionWithPattern:PREFIX_PATTERN_STRING options:0 error:&error];
    COMMAND_PATTERN_STRING = [PREFIX_PATTERN_STRING stringByAppendingString:@"([^=]*)=?.*"]; // <command>
    COMMAND_PATTERN = [NSRegularExpression regularExpressionWithPattern:COMMAND_PATTERN_STRING options:0 error:&error];
    COMMAND_WITH_ARGUMENTS_PREFIX_PATTERN_STRING = [NSString stringWithFormat:@"^(?:%@)?([^=]*)=", PREFIX_PATTERN_STRING]; // <command>
    COMMAND_WITH_ARGUMENTS_PREFIX_PATTERN = [NSRegularExpression regularExpressionWithPattern:COMMAND_WITH_ARGUMENTS_PREFIX_PATTERN_STRING options:0 error:&error];
    COMMAND_WITH_ARGUMENTS_PATTERN_STRING = [COMMAND_WITH_ARGUMENTS_PREFIX_PATTERN_STRING stringByAppendingString:@".*"];
    COMMAND_WITH_ARGUMENTS_PATTERN = [NSRegularExpression regularExpressionWithPattern:COMMAND_WITH_ARGUMENTS_PATTERN_STRING options:0 error:&error];

    OK = @"OK";
    ERROR = @"ERROR";
    ERROR_PREFIX = @"ERROR: ";
    INVALID_COMMAND = @"Invalid command";
    COMMAND_NOT_SUPPORTED = @"Command not supported";
    NO_ARGUMENTS = @"No arguments";
    WRONG_NUMBER_OF_ARGUMENTS = @"Wrong number of arguments";
    INVALID_ARGUMENTS = @"Invalid arguments";
    GATT_OPERATION_ERROR = @"Gatt operation error";
    ERROR_MESSAGE_PATTERN_STRING = @"^(?:ERROR|INVALID COMMAND|EC\\d{1,8}:).*";
    ERROR_MESSAGE_PATTERN = [NSRegularExpression regularExpressionWithPattern:ERROR_MESSAGE_PATTERN_STRING options:0 error:&error];
    PEER_INVALID_COMMAND = @"INVALID COMMAND";
    ERROR_CODE_PATTERN_STRING = @"^EC(\\d{1,8}):\\s*(.*)"; // <code> <message>
    ERROR_CODE_PATTERN = [NSRegularExpression regularExpressionWithPattern:ERROR_CODE_PATTERN_STRING options:0 error:&error];

    commandMap = @{
            CodelessBasicCommand.COMMAND : CodelessBasicCommand.class,
            CodelessDeviceInformationCommand.COMMAND : CodelessDeviceInformationCommand.class,
            CodelessUartEchoCommand.COMMAND : CodelessUartEchoCommand.class,
            CodelessResetIoConfigCommand.COMMAND : CodelessResetIoConfigCommand.class,
            CodelessErrorReportingCommand.COMMAND : CodelessErrorReportingCommand.class,
            CodelessResetCommand.COMMAND : CodelessResetCommand.class,
            CodelessBinRequestCommand.COMMAND : CodelessBinRequestCommand.class,
            CodelessBinRequestAckCommand.COMMAND : CodelessBinRequestAckCommand.class,
            CodelessBinExitCommand.COMMAND : CodelessBinExitCommand.class,
            CodelessBinExitAckCommand.COMMAND : CodelessBinExitAckCommand.class,
            CodelessBinResumeCommand.COMMAND : CodelessBinResumeCommand.class,
            CodelessBinEscCommand.COMMAND : CodelessBinEscCommand.class,
            CodelessTimerStartCommand.COMMAND : CodelessTimerStartCommand.class,
            CodelessTimerStopCommand.COMMAND : CodelessTimerStopCommand.class,
            CodelessCursorCommand.COMMAND : CodelessCursorCommand.class,
            CodelessRandomNumberCommand.COMMAND : CodelessRandomNumberCommand.class,
            CodelessBatteryLevelCommand.COMMAND : CodelessBatteryLevelCommand.class,
            CodelessBluetoothAddressCommand.COMMAND : CodelessBluetoothAddressCommand.class,
            CodelessRssiCommand.COMMAND : CodelessRssiCommand.class,
            CodelessDeviceSleepCommand.COMMAND : CodelessDeviceSleepCommand.class,
            CodelessIoConfigCommand.COMMAND : CodelessIoConfigCommand.class,
            CodelessIoStatusCommand.COMMAND : CodelessIoStatusCommand.class,
            CodelessAdcReadCommand.COMMAND : CodelessAdcReadCommand.class,
            CodelessI2cScanCommand.COMMAND : CodelessI2cScanCommand.class,
            CodelessI2cConfigCommand.COMMAND : CodelessI2cConfigCommand.class,
            CodelessI2cReadCommand.COMMAND : CodelessI2cReadCommand.class,
            CodelessI2cWriteCommand.COMMAND : CodelessI2cWriteCommand.class,
            CodelessUartPrintCommand.COMMAND : CodelessUartPrintCommand.class,
            CodelessMemStoreCommand.COMMAND : CodelessMemStoreCommand.class,
            CodelessPinCodeCommand.COMMAND : CodelessPinCodeCommand.class,
            CodelessCmdStoreCommand.COMMAND : CodelessCmdStoreCommand.class,
            CodelessCmdPlayCommand.COMMAND : CodelessCmdPlayCommand.class,
            CodelessCmdGetCommand.COMMAND : CodelessCmdGetCommand.class,
            CodelessAdvertisingStopCommand.COMMAND : CodelessAdvertisingStopCommand.class,
            CodelessAdvertisingStartCommand.COMMAND : CodelessAdvertisingStartCommand.class,
            CodelessAdvertisingDataCommand.COMMAND : CodelessAdvertisingDataCommand.class,
            CodelessAdvertisingResponseCommand.COMMAND : CodelessAdvertisingResponseCommand.class,
            CodelessCentralRoleSetCommand.COMMAND : CodelessCentralRoleSetCommand.class,
            CodelessPeripheralRoleSetCommand.COMMAND : CodelessPeripheralRoleSetCommand.class,
            CodelessBroadcasterRoleSetCommand.COMMAND : CodelessBroadcasterRoleSetCommand.class,
            CodelessGapStatusCommand.COMMAND : CodelessGapStatusCommand.class,
            CodelessGapScanCommand.COMMAND : CodelessGapScanCommand.class,
            CodelessGapConnectCommand.COMMAND : CodelessGapConnectCommand.class,
            CodelessGapDisconnectCommand.COMMAND : CodelessGapDisconnectCommand.class,
            CodelessConnectionParametersCommand.COMMAND : CodelessConnectionParametersCommand.class,
            CodelessMaxMtuCommand.COMMAND : CodelessMaxMtuCommand.class,
            CodelessDataLengthEnableCommand.COMMAND : CodelessDataLengthEnableCommand.class,
            CodelessSpiConfigCommand.COMMAND : CodelessSpiConfigCommand.class,
            CodelessSpiWriteCommand.COMMAND : CodelessSpiWriteCommand.class,
            CodelessSpiReadCommand.COMMAND : CodelessSpiReadCommand.class,
            CodelessSpiTransferCommand.COMMAND : CodelessSpiTransferCommand.class,
            CodelessBaudRateCommand.COMMAND : CodelessBaudRateCommand.class,
            CodelessPowerLevelConfigCommand.COMMAND : CodelessPowerLevelConfigCommand.class,
            CodelessPulseGenerationCommand.COMMAND : CodelessPulseGenerationCommand.class,
            CodelessEventConfigCommand.COMMAND : CodelessEventConfigCommand.class,
            CodelessBondingEntryClearCommand.COMMAND : CodelessBondingEntryClearCommand.class,
            CodelessBondingEntryStatusCommand.COMMAND : CodelessBondingEntryStatusCommand.class,
            CodelessBondingEntryTransferCommand.COMMAND : CodelessBondingEntryTransferCommand.class,
            CodelessEventHandlerCommand.COMMAND : CodelessEventHandlerCommand.class,
            CodelessHeartbeatCommand.COMMAND : CodelessHeartbeatCommand.class,
            CodelessHostSleepCommand.COMMAND : CodelessHostSleepCommand.class,
            CodelessSecurityModeCommand.COMMAND : CodelessSecurityModeCommand.class,
            CodelessFlowControlCommand.COMMAND : CodelessFlowControlCommand.class,
    };

    modeCommands = [NSSet setWithArray:@[
            @(CODELESS_COMMAND_ID_BINREQ),
            @(CODELESS_COMMAND_ID_BINREQACK),
            @(CODELESS_COMMAND_ID_BINREQEXIT),
            @(CODELESS_COMMAND_ID_BINREQEXITACK),
    ]];
}

+ (CBUUID*) CLIENT_CONFIG_DESCRIPTOR {
    return CLIENT_CONFIG_DESCRIPTOR;
}

+ (CBUUID*) CODELESS_SERVICE_UUID {
    return CODELESS_SERVICE_UUID;
}

+ (CBUUID*) CODELESS_INBOUND_COMMAND_UUID {
    return CODELESS_INBOUND_COMMAND_UUID;
}

+ (CBUUID*) CODELESS_OUTBOUND_COMMAND_UUID {
    return CODELESS_OUTBOUND_COMMAND_UUID;
}

+ (CBUUID*) CODELESS_FLOW_CONTROL_UUID {
    return CODELESS_FLOW_CONTROL_UUID;
}

+ (CBUUID*) DSPS_SERVICE_UUID {
    return DSPS_SERVICE_UUID;
}

+ (CBUUID*) DSPS_SERVER_TX_UUID {
    return DSPS_SERVER_TX_UUID;
}

+ (CBUUID*) DSPS_SERVER_RX_UUID {
    return DSPS_SERVER_RX_UUID;
}

+ (CBUUID*) DSPS_FLOW_CONTROL_UUID {
    return DSPS_FLOW_CONTROL_UUID;
}

+ (CBUUID*) SUOTA_SERVICE_UUID {
    return SUOTA_SERVICE_UUID;
}

+ (CBUUID*) IOT_SERVICE_UUID {
    return IOT_SERVICE_UUID;
}

+ (CBUUID*) WEARABLES_580_SERVICE_UUID {
    return WEARABLES_580_SERVICE_UUID;
}

+ (CBUUID*) WEARABLES_680_SERVICE_UUID {
    return WEARABLES_680_SERVICE_UUID;
}

+ (CBUUID*) MESH_PROVISIONING_SERVICE_UUID {
    return MESH_PROVISIONING_SERVICE_UUID;
}

+ (CBUUID*) MESH_PROXY_SERVICE_UUID {
    return MESH_PROXY_SERVICE_UUID;
}

+ (CBUUID*) IMMEDIATE_ALERT_SERVICE_UUID {
    return IMMEDIATE_ALERT_SERVICE_UUID;
}

+ (CBUUID*) LINK_LOSS_SERVICE_UUID {
    return LINK_LOSS_SERVICE_UUID;
}

+ (CBUUID*) DEVICE_INFORMATION_SERVICE_UUID {
    return DEVICE_INFORMATION_SERVICE_UUID;
}

+ (CBUUID*) MANUFACTURER_NAME_STRING_UUID {
    return MANUFACTURER_NAME_STRING_UUID;
}

+ (CBUUID*) MODEL_NUMBER_STRING_UUID {
    return MODEL_NUMBER_STRING_UUID;
}

+ (CBUUID*) SERIAL_NUMBER_STRING_UUID {
    return SERIAL_NUMBER_STRING_UUID;
}

+ (CBUUID*) HARDWARE_REVISION_STRING_UUID {
    return HARDWARE_REVISION_STRING_UUID;
}

+ (CBUUID*) FIRMWARE_REVISION_STRING_UUID {
    return FIRMWARE_REVISION_STRING_UUID;
}

+ (CBUUID*) SOFTWARE_REVISION_STRING_UUID {
    return SOFTWARE_REVISION_STRING_UUID;
}

+ (CBUUID*) SYSTEM_ID_UUID {
    return SYSTEM_ID_UUID;
}

+ (CBUUID*) IEEE_11073_UUID {
    return IEEE_11073_UUID;
}

+ (CBUUID*) PNP_ID_UUID {
    return PNP_ID_UUID;
}


// Patterns
+ (NSTextCheckingResult*) match:(NSRegularExpression*)regex text:(NSString*)text {
    return [regex firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
}

+ (NSString*) PREFIX {
    return PREFIX;
}

+ (NSString*) PREFIX_LOCAL {
    return PREFIX_LOCAL;
}

+ (NSString*) PREFIX_REMOTE {
    return PREFIX_REMOTE;
}

+ (NSString*) PREFIX_PATTERN_STRING {
    return PREFIX_PATTERN_STRING;
}

+ (NSRegularExpression*) PREFIX_PATTERN {
    return PREFIX_PATTERN;
}

+ (NSString*) COMMAND_PATTERN_STRING {
    return COMMAND_PATTERN_STRING;
}

+ (NSRegularExpression*) COMMAND_PATTERN {
    return COMMAND_PATTERN;
}

+ (NSString*) COMMAND_WITH_ARGUMENTS_PREFIX_PATTERN_STRING {
    return COMMAND_WITH_ARGUMENTS_PREFIX_PATTERN_STRING;
}

+ (NSRegularExpression*) COMMAND_WITH_ARGUMENTS_PREFIX_PATTERN {
    return COMMAND_WITH_ARGUMENTS_PREFIX_PATTERN;
}

+ (NSString*) COMMAND_WITH_ARGUMENTS_PATTERN_STRING {
    return COMMAND_WITH_ARGUMENTS_PATTERN_STRING;
}

+ (NSRegularExpression*) COMMAND_WITH_ARGUMENTS_PATTERN {
    return COMMAND_WITH_ARGUMENTS_PATTERN;
}

+ (BOOL) hasPrefix:(NSString*)command {
    return [self match:PREFIX_PATTERN text:command] != nil;
}

+ (NSString*) getPrefix:(NSString*)command {
    NSTextCheckingResult* matcher = [self match:PREFIX_PATTERN text:command];
    return matcher ? [command substringWithRange:[matcher rangeAtIndex:1]] : nil;
}

+ (BOOL) isCommand:(NSString*)command {
    return [self match:COMMAND_PATTERN text:command] != nil;
}

+ (NSString*) getCommand:(NSString*)command {
    NSTextCheckingResult* matcher = [self match:COMMAND_PATTERN text:command];
    return matcher ? [command substringWithRange:[matcher rangeAtIndex:1]] : nil;
}

+ (NSString*) removeCommandPrefix:(NSString*)command {
    NSTextCheckingResult* matcher = [self match:PREFIX_REMOVE_PATTERN text:command];
    return matcher ? [command stringByReplacingCharactersInRange:matcher.range withString:@""] : command;
}

+ (BOOL) hasArguments:(NSString*)command {
    return [self match:COMMAND_WITH_ARGUMENTS_PATTERN text:command] != nil;
}

+ (int) countArguments:(NSString*)command split:(NSString*)split {
    if (![self hasArguments:command])
        return 0;
    NSTextCheckingResult* matcher = [self match:COMMAND_WITH_ARGUMENTS_PREFIX_PATTERN text:command];
    if (matcher)
        command = [command stringByReplacingCharactersInRange:matcher.range withString:@""];
    return (int) [command componentsSeparatedByString:split].count;
}

+ (NSString*) OK {
    return OK;
}

+ (NSString*) ERROR {
    return ERROR;
}

+ (NSString*) ERROR_PREFIX {
    return ERROR_PREFIX;
}

+ (NSString*) INVALID_COMMAND {
    return INVALID_COMMAND;
}

+ (NSString*) COMMAND_NOT_SUPPORTED {
    return COMMAND_NOT_SUPPORTED;
}

+ (NSString*) NO_ARGUMENTS {
    return NO_ARGUMENTS;
}

+ (NSString*) WRONG_NUMBER_OF_ARGUMENTS {
    return WRONG_NUMBER_OF_ARGUMENTS;
}

+ (NSString*) INVALID_ARGUMENTS {
    return INVALID_ARGUMENTS;
}

+ (NSString*) GATT_OPERATION_ERROR {
    return GATT_OPERATION_ERROR;
}

+ (NSString*) ERROR_MESSAGE_PATTERN_STRING {
    return ERROR_MESSAGE_PATTERN_STRING;
}

+ (NSRegularExpression*) ERROR_MESSAGE_PATTERN {
    return ERROR_MESSAGE_PATTERN;
}

+ (NSString*) PEER_INVALID_COMMAND {
    return PEER_INVALID_COMMAND;
}

+ (NSString*) ERROR_CODE_PATTERN_STRING {
    return ERROR_CODE_PATTERN_STRING;
}

+ (NSRegularExpression*) ERROR_CODE_PATTERN {
    return ERROR_CODE_PATTERN;
}

+ (BOOL) isSuccess:(NSString*)response {
    return [response isEqualToString:OK];
}

+ (BOOL) isError:(NSString*)response {
    return [response isEqualToString:ERROR];
}

+ (BOOL) isErrorMessage:(NSString*)response {
    return [self match:ERROR_MESSAGE_PATTERN text:response] != nil;
}

+ (BOOL) isPeerInvalidCommand:(NSString*)error {
    return [error hasPrefix:PEER_INVALID_COMMAND];
}

+ (BOOL) isErrorCodeMessage:(NSString*)error {
    return [self match:ERROR_CODE_PATTERN text:error] != nil;
}

+ (CodelessErrorCodeMessage*) parseErrorCodeMessage:(NSString*)error {
    NSTextCheckingResult* matcher = [self match:ERROR_CODE_PATTERN text:error];
    return matcher ? [[CodelessErrorCodeMessage alloc] initWithCode:[error substringWithRange:[matcher rangeAtIndex:1]].intValue message:[error substringWithRange:[matcher rangeAtIndex:2]]] : nil;
}


// GPIO
+ (BOOL) isBinaryState:(int)state {
    return state == CODELESS_COMMAND_PIN_STATUS_HIGH || state == CODELESS_COMMAND_PIN_STATUS_LOW;
}

+ (int) gpioPackPort:(int)port pin:(int)pin {
    return port * 10 + pin;
}

+ (int) gpioGetPort:(int)pack {
    return pack / 10;
}

+ (int) gpioGetPin:(int)pack {
    return pack % 10;
}


+ (NSDictionary<NSString*, Class>*) commandMap {
    return commandMap;
}

+ (CodelessCommand*) createCommand:(CodelessManager*)manager commandClass:(Class)commandClass command:(NSString*)command {
    if ([commandClass isSubclassOfClass:CodelessCommand.class]) {
        id object = [commandClass alloc];
        if ([object respondsToSelector:@selector(initWithManager:command:parse:)])
            return [object initWithManager:manager command:command parse:true];
    }
    CodelessLog(TAG, "Failed to create %@ object", commandClass);
    return [[CodelessCustomCommand alloc] initWithManager:manager command:[PREFIX stringByAppendingString:command] parse:true];
}

+ (NSSet<NSNumber*>*) modeCommands {
    return modeCommands;
}

+ (BOOL) isModeCommand:(CodelessCommand*)command {
    return [modeCommands containsObject:@(command.commandID)];
}

@end


@implementation CodelessErrorCodeMessage

- (instancetype) initWithCode:(int)code message:(NSString*)message {
    self = [super init];
    if (!self)
        return nil;
    self.code = code;
    self.message = message;
    return self;
}

@end


@interface CodelessLine ()

@property NSString* text;
@property int type;

@end

@implementation CodelessLine

- (instancetype) initWithText:(NSString*)text type:(int)type {
    self = [super init];
    if (!self)
        return nil;
    self.text = text;
    self.type = type;
    return self;
}

- (instancetype) initWithType:(int)type {
    return self = [self initWithText:@"" type:type];
}

- (BOOL) isInbound {
    return self.type == CodelessLineInboundCommand || self.type == CodelessLineInboundResponse || self.type == CodelessLineInboundOK
            || self.type == CodelessLineInboundError || self.type == CodelessLineInboundEmpty;
}

- (BOOL) isOutbound {
    return self.type == CodelessLineOutboundCommand || self.type == CodelessLineOutboundResponse || self.type == CodelessLineOutboundOK
            || self.type == CodelessLineOutboundError || self.type == CodelessLineOutboundEmpty;
}

- (BOOL) isCommand {
    return self.type == CodelessLineInboundCommand || self.type == CodelessLineOutboundCommand;
}

- (BOOL) isResponse {
    return self.type == CodelessLineInboundResponse || self.type == CodelessLineOutboundResponse;
}

- (BOOL) isOK {
    return self.type == CodelessLineInboundOK || self.type == CodelessLineOutboundOK;
}

- (BOOL) isError {
    return self.type == CodelessLineInboundError || self.type == CodelessLineOutboundError;
}

- (BOOL) isEmpty {
    return self.type == CodelessLineInboundEmpty || self.type == CodelessLineOutboundEmpty;
}

@end


@implementation CodelessGPIO

- (instancetype) init {
    self = [super init];
    if (!self)
        return nil;
    self.port = CODELESS_GPIO_INVALID;
    self.pin = CODELESS_GPIO_INVALID;
    self.state = CODELESS_GPIO_INVALID;
    self.function = CODELESS_GPIO_INVALID;
    self.level = CODELESS_GPIO_INVALID;
    return self;
}

- initWithPort:(int)port pin:(int)pin {
    self = [self init];
    if (!self)
        return nil;
    self.port = port;
    self.pin = pin;
    return self;
}

- initWithPort:(int)port pin:(int)pin function:(int)function {
    self = [self initWithPort:port pin:pin];
    if (!self)
        return nil;
    self.function = function;
    return self;
}

- initWithPort:(int)port pin:(int)pin function:(int)function level:(int)level {
    self = [self initWithPort:port pin:pin function:function];
    if (!self)
        return nil;
    self.level = level;
    return self;
}

- initWithPack:(int)pack {
    self = [self init];
    if (!self)
        return nil;
    [self setGpio:pack];
    return self;
}

- initWithGPIO:(CodelessGPIO*)gpio {
    self = [self initWithPort:gpio.port pin:gpio.pin function:gpio.function level:gpio.level];
    if (!self)
        return nil;
    self.state = gpio.state;
    return self;
}

- initWithGPIO:(CodelessGPIO*)gpio function:(int)function {
    return [self initWithPort:gpio.port pin:gpio.pin function:function];
}

- initWithGPIO:(CodelessGPIO*)gpio function:(int)function level:(int)level {
    return [self initWithPort:gpio.port pin:gpio.pin function:function level:level];
}

- (void) update:(CodelessGPIO*)gpio {
    if (![self isEqual:gpio])
        return;
    if (gpio.validFunction) {
        if (self.function != gpio.function) {
            self.level = CODELESS_GPIO_INVALID;
            self.state = CODELESS_GPIO_INVALID;
        }
        self.function = gpio.function;
    }
    if (gpio.validLevel)
        self.level = gpio.level;
    if (gpio.validState)
        self.state = gpio.state;
}

- (CodelessGPIO*) gpioPin {
    return [[CodelessGPIO alloc] initWithPort:self.port pin:self.pin];
}

- (BOOL) validGpio {
    return self.port != CODELESS_GPIO_INVALID && self.pin != CODELESS_GPIO_INVALID;
}

- (int) getGpio {
    return [CodelessProfile gpioPackPort:self.port pin:self.pin];
}

- (void) setGpio:(int)pack {
    self.port = [CodelessProfile gpioGetPort:pack];
    self.pin = [CodelessProfile gpioGetPin:pack];
}

- (void) setGpioPort:(int)port pin:(int)pin {
    self.port = port;
    self.pin = pin;
}

- (BOOL) validState {
    return self.state != CODELESS_GPIO_INVALID;
}

- (BOOL) isLow {
    return self.state == CODELESS_COMMAND_PIN_STATUS_LOW;
}

- (BOOL) isHigh {
    return self.state == CODELESS_COMMAND_PIN_STATUS_HIGH;
}

- (BOOL) isBinary {
    return self.isLow || self.isHigh;
}

- (void) setLow {
    self.state = CODELESS_COMMAND_PIN_STATUS_LOW;
}

- (void) setHigh {
    self.state = CODELESS_COMMAND_PIN_STATUS_HIGH;
}

- (void) setStatus:(BOOL)status {
    self.state = status ? CODELESS_COMMAND_PIN_STATUS_HIGH : CODELESS_COMMAND_PIN_STATUS_LOW;
}

- (BOOL) validFunction {
    return self.function != CODELESS_GPIO_INVALID;
}

- (BOOL) isInput {
    return self.function == CODELESS_COMMAND_GPIO_FUNCTION_INPUT
            || self.function == CODELESS_COMMAND_GPIO_FUNCTION_INPUT_PULL_UP || self.function == CODELESS_COMMAND_GPIO_FUNCTION_INPUT_PULL_DOWN;
}

- (BOOL) isOutput {
    return self.function == CODELESS_COMMAND_GPIO_FUNCTION_OUTPUT;
}

- (BOOL) isAnalog {
    return self.function == CODELESS_COMMAND_GPIO_FUNCTION_ANALOG_INPUT || self.function == CODELESS_COMMAND_GPIO_FUNCTION_ANALOG_INPUT_ATTENUATION;
}

- (BOOL) isPwm {
    return self.function == CODELESS_COMMAND_GPIO_FUNCTION_PWM || self.function == CODELESS_COMMAND_GPIO_FUNCTION_PWM1
            || self.function == CODELESS_COMMAND_GPIO_FUNCTION_PWM2 || self.function == CODELESS_COMMAND_GPIO_FUNCTION_PWM3;
}

- (BOOL) isI2c {
    return self.function == CODELESS_COMMAND_GPIO_FUNCTION_I2C_CLK || self.function == CODELESS_COMMAND_GPIO_FUNCTION_I2C_SDA;
}

- (BOOL) isSpi {
    return self.function == CODELESS_COMMAND_GPIO_FUNCTION_SPI_CLK || self.function == CODELESS_COMMAND_GPIO_FUNCTION_SPI_CS
            || self.function == CODELESS_COMMAND_GPIO_FUNCTION_SPI_MISO || self.function == CODELESS_COMMAND_GPIO_FUNCTION_SPI_MOSI;
}

- (BOOL) isUart {
    return self.function == CODELESS_COMMAND_GPIO_FUNCTION_UART_CTS || self.function == CODELESS_COMMAND_GPIO_FUNCTION_UART_RTS
            || self.function == CODELESS_COMMAND_GPIO_FUNCTION_UART_RX || self.function == CODELESS_COMMAND_GPIO_FUNCTION_UART_TX
            || self.function == CODELESS_COMMAND_GPIO_FUNCTION_UART2_CTS || self.function == CODELESS_COMMAND_GPIO_FUNCTION_UART2_RTS
            || self.function == CODELESS_COMMAND_GPIO_FUNCTION_UART2_RX || self.function == CODELESS_COMMAND_GPIO_FUNCTION_UART2_TX;
}

- (BOOL) validLevel {
    return self.level != CODELESS_GPIO_INVALID;
}

+ (NSArray<CodelessGPIO*>*) copyConfig:(NSArray<CodelessGPIO*>*)config {
    NSMutableArray<CodelessGPIO*>* copy = [NSMutableArray arrayWithCapacity:config.count];
    for (CodelessGPIO* gpio in config)
        [copy addObject:[[CodelessGPIO alloc] initWithGPIO:gpio]];
    return copy;
}

+ (NSArray<CodelessGPIO*>*) updateConfig:(NSArray<CodelessGPIO*>*)config update:(NSArray<CodelessGPIO*>*)update {
    if (!config || ![config isEqualToArray:update])
        return [self copyConfig:update];
    for (int i = 0; i < config.count; i++)
        [config[i] update:update[i]];
    return config;
}

- (BOOL)isEqual:(id)obj {
    if ([obj isKindOfClass:CodelessGPIO.class]) {
        CodelessGPIO* gpio = (CodelessGPIO*) obj;
        return self.port == gpio.port && self.pin == gpio.pin;
    } else if ([obj isKindOfClass:NSNumber.class]) {
        return self.getGpio == [(NSNumber*) obj intValue];
    }
    return [super isEqual:obj];
}

- (NSString*) name {
    return [NSString stringWithFormat:@"P%d_%d", self.port, self.pin];
}

- (NSString*) description {
    return [NSString stringWithFormat:@"%@%@", self.name, self.validFunction ? [NSString stringWithFormat:@"(%d)", self.function] : @""];
}

@end


@implementation CodelessEventConfig

- (instancetype) initWithType:(int)type status:(BOOL)status {
    self = [super init];
    if (!self)
        return nil;
    self.type = type;
    self.status = status;
    return self;
}

@end


@implementation CodelessGapScannedDevice
@end


@implementation CodelessEventHandler
@end


@implementation CodelessBondingEntry
@end
