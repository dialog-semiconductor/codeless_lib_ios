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

#import "CodelessCommands.h"
#import "CodelessCommand.h"
#import "CodelessProfile.h"
#import "CodelessManager.h"
#import "CodelessBasicCommand.h"
#import "CodelessDeviceInformationCommand.h"
#import "CodelessResetCommand.h"
#import "CodelessBluetoothAddressCommand.h"
#import "CodelessRssiCommand.h"
#import "CodelessBatteryLevelCommand.h"
#import "CodelessRandomNumberCommand.h"
#import "CodelessBinRequestCommand.h"
#import "CodelessBinRequestAckCommand.h"
#import "CodelessBinExitCommand.h"
#import "CodelessBinExitAckCommand.h"
#import "CodelessConnectionParametersCommand.h"
#import "CodelessMaxMtuCommand.h"
#import "CodelessDataLengthEnableCommand.h"
#import "CodelessAdvertisingDataCommand.h"
#import "CodelessAdvertisingResponseCommand.h"
#import "CodelessIoConfigCommand.h"
#import "CodelessResetIoConfigCommand.h"
#import "CodelessIoConfigCommand.h"
#import "CodelessIoStatusCommand.h"
#import "CodelessAdcReadCommand.h"
#import "CodelessPulseGenerationCommand.h"
#import "CodelessI2cConfigCommand.h"
#import "CodelessI2cScanCommand.h"
#import "CodelessI2cReadCommand.h"
#import "CodelessI2cReadCommand.h"
#import "CodelessI2cWriteCommand.h"
#import "CodelessSpiConfigCommand.h"
#import "CodelessSpiWriteCommand.h"
#import "CodelessSpiReadCommand.h"
#import "CodelessSpiTransferCommand.h"
#import "CodelessUartPrintCommand.h"
#import "CodelessMemStoreCommand.h"
#import "CodelessRandomNumberCommand.h"
#import "CodelessCmdGetCommand.h"
#import "CodelessCmdStoreCommand.h"
#import "CodelessCmdPlayCommand.h"
#import "CodelessTimerStartCommand.h"
#import "CodelessTimerStopCommand.h"
#import "CodelessEventConfigCommand.h"
#import "CodelessEventHandlerCommand.h"
#import "CodelessBaudRateCommand.h"
#import "CodelessUartEchoCommand.h"
#import "CodelessHeartbeatCommand.h"
#import "CodelessHostSleepCommand.h"
#import "CodelessSecurityModeCommand.h"
#import "CodelessPinCodeCommand.h"
#import "CodelessFlowControlCommand.h"
#import "CodelessErrorReportingCommand.h"
#import "CodelessCursorCommand.h"
#import "CodelessDeviceSleepCommand.h"
#import "CodelessPowerLevelConfigCommand.h"
#import "CodelessBondingEntryClearCommand.h"
#import "CodelessBondingEntryStatusCommand.h"
#import "CodelessBondingEntryTransferCommand.h"
#import "CodelessLibConfig.h"

@implementation CodelessCommands

- (instancetype) initWithManager:(CodelessManager*)manager {
    self = [super init];
    if (!self)
        return nil;
    self.manager = manager;
    return self;
}

/// Sends the AT command represented by the provided command object to the peer device.
- (__kindof CodelessCommand*) sendCommand:(CodelessCommand*)command {
    command.origin = self;
    [self.manager sendCommand:command];
    return command;
}

- (CodelessBasicCommand*) ping {
    return [self sendCommand:[[CodelessBasicCommand alloc] initWithManager:self.manager]];
}

- (CodelessDeviceInformationCommand*) getDeviceInfo {
    return [self sendCommand:[[CodelessDeviceInformationCommand alloc] initWithManager:self.manager]];
}

- (CodelessResetCommand*) resetDevice {
    return [self sendCommand:[[CodelessResetCommand alloc] initWithManager:self.manager]];
}

- (CodelessBluetoothAddressCommand*) getBluetoothAddress {
    return [self sendCommand:[[CodelessBluetoothAddressCommand alloc] initWithManager:self.manager]];
}

- (CodelessRssiCommand*) getPeerRssi {
    return [self sendCommand:[[CodelessRssiCommand alloc] initWithManager:self.manager]];
}

- (CodelessBatteryLevelCommand*) getBatteryLevel {
    return [self sendCommand:[[CodelessBatteryLevelCommand alloc] initWithManager:self.manager]];
}

- (CodelessBinRequestCommand*) requestBinaryMode {
    return [self sendCommand:[[CodelessBinRequestCommand alloc] initWithManager:self.manager]];
}

- (CodelessBinRequestAckCommand*) sendBinaryRequestAck {
    return [self sendCommand:[[CodelessBinRequestAckCommand alloc] initWithManager:self.manager]];
}

- (CodelessBinExitCommand*) sendBinaryExit {
    return [self sendCommand:[[CodelessBinExitCommand alloc] initWithManager:self.manager]];
}

- (CodelessBinExitAckCommand*) sendBinaryExitAck {
    return [self sendCommand:[[CodelessBinExitAckCommand alloc] initWithManager:self.manager]];
}

- (CodelessConnectionParametersCommand*) getConnectionParameters {
    return [self sendCommand:[[CodelessConnectionParametersCommand alloc] initWithManager:self.manager]];
}

- (CodelessConnectionParametersCommand*) setConnectionParameters:(int)connectionInterval slaveLatency:(int)slaveLatency supervisionTimeout:(int)supervisionTimeout action:(int)action {
    return [self sendCommand:[[CodelessConnectionParametersCommand alloc] initWithManager:self.manager interval:connectionInterval latency:slaveLatency timeout:supervisionTimeout action:action]];
}

- (CodelessMaxMtuCommand*) getMaxMtu {
    return [self sendCommand:[[CodelessMaxMtuCommand alloc] initWithManager:self.manager]];
}

- (CodelessMaxMtuCommand*) setMaxMtu:(int)mtu {
    return [self sendCommand:[[CodelessMaxMtuCommand alloc] initWithManager:self.manager mtu:mtu]];
}

- (CodelessDataLengthEnableCommand*) getDataLength {
    return [self sendCommand:[[CodelessDataLengthEnableCommand alloc] initWithManager:self.manager]];
}

- (CodelessDataLengthEnableCommand*) setDataLength:(BOOL)enabled txPacketLength:(int)txPacketLength rxPacketLength:(int)rxPacketLength {
    return [self sendCommand:[[CodelessDataLengthEnableCommand alloc] initWithManager:self.manager enabled:enabled txPacketLength:txPacketLength rxPacketLength:rxPacketLength]];
}

- (CodelessDataLengthEnableCommand*) setDataLengthEnabled:(BOOL)enabled {
    return [self sendCommand:[[CodelessDataLengthEnableCommand alloc] initWithManager:self.manager enabled:enabled]];
}

- (CodelessDataLengthEnableCommand*) enableDataLength {
    return [self setDataLengthEnabled:true];
}

- (CodelessDataLengthEnableCommand*) disableDataLength {
    return [self setDataLengthEnabled:false];
}

- (CodelessAdvertisingDataCommand*) getAdvertisingData {
    return [self sendCommand:[[CodelessAdvertisingDataCommand alloc] initWithManager:self.manager]];
}

- (CodelessAdvertisingDataCommand*) setAdvertisingData:(NSData*)data {
    return [self sendCommand:[[CodelessAdvertisingDataCommand alloc] initWithManager:self.manager data:data]];
}

- (CodelessAdvertisingResponseCommand*) getScanResponseData {
    return [self sendCommand:[[CodelessAdvertisingResponseCommand alloc] initWithManager:self.manager]];
}

- (CodelessAdvertisingResponseCommand*) setScanResponseData:(NSData*)data {
    return [self sendCommand:[[CodelessAdvertisingResponseCommand alloc] initWithManager:self.manager data:data]];
}

- (CodelessIoConfigCommand*) readIoConfig {
    return [self sendCommand:[[CodelessIoConfigCommand alloc] initWithManager:self.manager]];
}

- (CodelessResetIoConfigCommand*) resetIoConfig {
    return [self sendCommand:[[CodelessResetIoConfigCommand alloc] initWithManager:self.manager]];
}

- (CodelessIoConfigCommand*) setIoConfig:(CodelessGPIO*)gpio {
    return [self sendCommand:[[CodelessIoConfigCommand alloc] initWithManager:self.manager gpio:gpio]];
}

- (CodelessIoStatusCommand*) readInput:(CodelessGPIO*)gpio {
    return [self sendCommand:[[CodelessIoStatusCommand alloc] initWithManager:self.manager gpio:gpio]];
}

- (CodelessIoStatusCommand*) setOutput:(CodelessGPIO*)gpio status:(BOOL)status {
    return [self sendCommand:[[CodelessIoStatusCommand alloc] initWithManager:self.manager gpio:gpio status:status]];
}

- (CodelessIoStatusCommand*) setOutputLow:(CodelessGPIO*)gpio {
    return [self setOutput:gpio status:false];
}

- (CodelessIoStatusCommand*) setOutputHigh:(CodelessGPIO*)gpio {
    return [self setOutput:gpio status:true];
}

- (CodelessAdcReadCommand*) readAnalogInput:(CodelessGPIO*)gpio {
    return [self sendCommand:[[CodelessAdcReadCommand alloc] initWithManager:self.manager gpio:gpio]];
}

- (CodelessPulseGenerationCommand*) getPwm {
    return [self sendCommand:[[CodelessPulseGenerationCommand alloc] initWithManager:self.manager]];
}

- (CodelessPulseGenerationCommand*) setPwm:(int)frequency dutyCycle:(int)dutyCycle duration:(int)duration {
    return [self sendCommand:[[CodelessPulseGenerationCommand alloc] initWithManager:self.manager frequency:frequency dutyCycle:dutyCycle duration:duration]];
}

- (CodelessI2cConfigCommand*) setI2cConfig:(int)addressSize bitRate:(int)bitRate registerSize:(int)registerSize {
    return [self sendCommand:[[CodelessI2cConfigCommand alloc] initWithManager:self.manager bitCount:addressSize bitRate:bitRate registerWidth:registerSize]];
}

- (CodelessI2cScanCommand*) i2cScan {
    return [self sendCommand:[[CodelessI2cScanCommand alloc] initWithManager:self.manager]];
}

- (CodelessI2cReadCommand*) i2cRead:(int)address i2cRegister:(int)i2cRegister {
    return [self sendCommand:[[CodelessI2cReadCommand alloc] initWithManager:self.manager address:address i2cRegister:i2cRegister]];
}

- (CodelessI2cReadCommand*) i2cRead:(int)address i2cRegister:(int)i2cRegister count:(int)count {
    return [self sendCommand:[[CodelessI2cReadCommand alloc] initWithManager:self.manager address:address i2cRegister:i2cRegister byteCount:count]];
}

- (CodelessI2cWriteCommand*) i2cWrite:(int)address i2cRegister:(int)i2cRegister value:(int)value {
    return [self sendCommand:[[CodelessI2cWriteCommand alloc] initWithManager:self.manager address:address i2cRegister:i2cRegister value:value]];
}

- (CodelessSpiConfigCommand*) readSpiConfig {
    return [self sendCommand:[[CodelessSpiConfigCommand alloc] initWithManager:self.manager]];
}

- (CodelessSpiConfigCommand*) setSpiConfig:(int)speed mode:(int)mode size:(int)size {
    return [self sendCommand:[[CodelessSpiConfigCommand alloc] initWithManager:self.manager speed:speed mode:mode size:size]];
}

- (CodelessSpiWriteCommand*) spiWrite:(NSString*)hexString {
    return [self sendCommand:[[CodelessSpiWriteCommand alloc] initWithManager:self.manager hexString:hexString]];
}

- (CodelessSpiReadCommand*) spiRead:(int)count {
    return [self sendCommand:[[CodelessSpiReadCommand alloc] initWithManager:self.manager byteNumber:count]];
}

- (CodelessSpiTransferCommand*) spiTransfer:(NSString*)hexString {
    return [self sendCommand:[[CodelessSpiTransferCommand alloc] initWithManager:self.manager hexString:hexString]];
}

- (CodelessUartPrintCommand*) print:(NSString*)text {
    return [self sendCommand:[[CodelessUartPrintCommand alloc] initWithManager:self.manager text:text]];
}

- (CodelessMemStoreCommand*) setMemContent:(int)index content:(NSString*)content {
    return [self sendCommand:[[CodelessMemStoreCommand alloc] initWithManager:self.manager memIndex:index text:content]];
}

- (CodelessMemStoreCommand*) getMemContent:(int)index {
    return [self sendCommand:[[CodelessMemStoreCommand alloc] initWithManager:self.manager memIndex:index]];
}

- (CodelessRandomNumberCommand*) getRandom {
    return [self sendCommand:[[CodelessRandomNumberCommand alloc] initWithManager:self.manager]];
}

- (CodelessCmdGetCommand*) getStoredCommands:(int)index {
    return [self sendCommand:[[CodelessCmdGetCommand alloc] initWithManager:self.manager index:index]];
}

- (CodelessCmdStoreCommand*) storeCommands:(int)index commandString:(NSString*)commandString {
    return [self sendCommand:[[CodelessCmdStoreCommand alloc] initWithManager:self.manager index:index commandString:commandString]];
}

- (CodelessCmdPlayCommand*) playCommands:(int)index {
    return [self sendCommand:[[CodelessCmdPlayCommand alloc] initWithManager:self.manager index:index]];
}

- (CodelessTimerStartCommand*) startTimer:(int)timerIndex commandIndex:(int)commandIndex delay:(int)delay {
    return [self sendCommand:[[CodelessTimerStartCommand alloc] initWithManager:self.manager timerIndex:timerIndex commandIndex:commandIndex delay:delay]];
}

- (CodelessTimerStopCommand*) stopTimer:(int)timerIndex {
    return [self sendCommand:[[CodelessTimerStopCommand alloc] initWithManager:self.manager timerIndex:timerIndex]];
}

- (CodelessEventConfigCommand*) setEventConfig:(int)eventType status:(BOOL)status {
    return [self sendCommand:[[CodelessEventConfigCommand alloc] initWithManager:self.manager eventType:eventType status:status]];
}

- (CodelessEventConfigCommand*) getEventConfigTable {
    return [self sendCommand:[[CodelessEventConfigCommand alloc] initWithManager:self.manager]];
}

- (CodelessEventHandlerCommand*) setEventHandler:(int)eventType commandString:(NSString*)commandString {
    return [self sendCommand:[[CodelessEventHandlerCommand alloc] initWithManager:self.manager event:eventType commandString:commandString]];
}

- (CodelessEventHandlerCommand*) getEventHandlers {
    return [self sendCommand:[[CodelessEventHandlerCommand alloc] initWithManager:self.manager]];
}

- (CodelessBaudRateCommand*) getBaudRate {
    return [self sendCommand:[[CodelessBaudRateCommand alloc] initWithManager:self.manager]];
}

- (CodelessBaudRateCommand*) setBaudRate:(int)baudRate {
    return [self sendCommand:[[CodelessBaudRateCommand alloc] initWithManager:self.manager baudRate:baudRate]];
}

- (CodelessUartEchoCommand*) getUartEcho {
    return [self sendCommand:[[CodelessUartEchoCommand alloc] initWithManager:self.manager]];
}

- (CodelessUartEchoCommand*) setUartEcho:(BOOL)echo {
    return [self sendCommand:[[CodelessUartEchoCommand alloc] initWithManager:self.manager echo:echo]];
}

- (CodelessHeartbeatCommand*) getHeartbeatStatus {
    return [self sendCommand:[[CodelessHeartbeatCommand alloc] initWithManager:self.manager]];
}

- (CodelessHeartbeatCommand*) setHeartbeatStatus:(BOOL)enable {
    return [self sendCommand:[[CodelessHeartbeatCommand alloc] initWithManager:self.manager enabled:enable]];
}

- (CodelessErrorReportingCommand*) setErrorReporting:(BOOL)enabled {
    return [self sendCommand:[[CodelessErrorReportingCommand alloc] initWithManager:self.manager enabled:enabled]];
}

- (CodelessCursorCommand*) timeCursor {
    return [self sendCommand:[[CodelessCursorCommand alloc] initWithManager:self.manager]];
}

- (CodelessDeviceSleepCommand*) sleep {
    return [self sendCommand:[[CodelessDeviceSleepCommand alloc] initWithManager:self.manager sleep:true]];
}

- (CodelessDeviceSleepCommand*) awake {
    return [self sendCommand:[[CodelessDeviceSleepCommand alloc] initWithManager:self.manager sleep:false]];
}

- (CodelessHostSleepCommand*) getHostSleepStatus {
    return [self sendCommand:[[CodelessHostSleepCommand alloc] initWithManager:self.manager]];
}

- (CodelessHostSleepCommand*) setHostSleepStatus:(int)hostSleepMode wakeupByte:(int)wakeupByte wakeupRetryInterval:(int)wakeupRetryInterval wakeupRetryTimes:(int)wakeupRetryTimes {
    return [self sendCommand:[[CodelessHostSleepCommand alloc] initWithManager:self.manager hostSleepMode:hostSleepMode wakeupByte:wakeupByte wakeupRetryInterval:wakeupRetryInterval wakeupRetryTimes:wakeupRetryTimes]];
}

- (CodelessPowerLevelConfigCommand*) getPowerLevel {
    return [self sendCommand:[[CodelessPowerLevelConfigCommand alloc] initWithManager:self.manager]];
}

- (CodelessPowerLevelConfigCommand*) setPowerLevel:(int)powerLevel {
    return [self sendCommand:[[CodelessPowerLevelConfigCommand alloc] initWithManager:self.manager powerLevel:powerLevel]];
}

- (CodelessSecurityModeCommand*) getSecurityMode {
    return [self sendCommand:[[CodelessSecurityModeCommand alloc] initWithManager:self.manager]];
}

- (CodelessSecurityModeCommand*) setSecurityMode:(int)mode {
    return [self sendCommand:[[CodelessSecurityModeCommand alloc] initWithManager:self.manager mode:mode]];
}

- (CodelessPinCodeCommand*) getPinCode {
    return [self sendCommand:[[CodelessPinCodeCommand alloc] initWithManager:self.manager]];
}

- (CodelessPinCodeCommand*) setPinCode:(int)code {
    return [self sendCommand:[[CodelessPinCodeCommand alloc] initWithManager:self.manager pinCode:code]];
}

- (CodelessFlowControlCommand*) getFlowControl {
    return [self sendCommand:[[CodelessFlowControlCommand alloc] initWithManager:self.manager]];
}

- (CodelessFlowControlCommand*) setFlowControl:(BOOL)enabled rts:(CodelessGPIO*)rts cts:(CodelessGPIO*)cts {
    return [self sendCommand:[[CodelessFlowControlCommand alloc] initWithManager:self.manager enabled:enabled rtsGpio:rts ctsGpio:cts]];
}

- (CodelessBondingEntryClearCommand*) clearBondingDatabaseEntry:(int)index {
    return [self sendCommand:[[CodelessBondingEntryClearCommand alloc] initWithManager:self.manager index:index]];
}

- (CodelessBondingEntryClearCommand*) clearBondingDatabase {
    return [self clearBondingDatabaseEntry:CodelessLibConfig.BONDING_DATABASE_ALL_VALUES];
}

- (CodelessBondingEntryStatusCommand*) getBondingDatabasePersistenceStatus {
    return [self sendCommand:[[CodelessBondingEntryStatusCommand alloc] initWithManager:self.manager]];
}

- (CodelessBondingEntryStatusCommand*) setBondingEntryPersistenceStatus:(int)index persistent:(BOOL)persistent {
    return [self sendCommand:[[CodelessBondingEntryStatusCommand alloc] initWithManager:self.manager index:index persistent:persistent]];
}

- (CodelessBondingEntryTransferCommand*) getBondingDatabase:(int)index {
    return [self sendCommand:[[CodelessBondingEntryTransferCommand alloc] initWithManager:self.manager index:index]];
}

- (CodelessBondingEntryTransferCommand*) setBondingDatabase:(int)index bondingEntry:(CodelessBondingEntry*)bondingEntry {
    return [self sendCommand:[[CodelessBondingEntryTransferCommand alloc] initWithManager:self.manager index:index bondingEntry:bondingEntry]];
}

@end
