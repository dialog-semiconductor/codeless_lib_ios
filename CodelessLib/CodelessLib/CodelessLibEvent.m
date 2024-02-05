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
#import "CodelessProfile.h"
#import "CodelessScript.h"
#import "CodelessLibEvent.h"
#import "CodelessBluetoothManager.h"
#import "CodelessManager.h"
#import "CodelessCommand.h"
#import "CodelessDeviceInformationCommand.h"
#import "CodelessUartEchoCommand.h"
#import "CodelessBinEscCommand.h"
#import "CodelessAdcReadCommand.h"
#import "CodelessPulseGenerationCommand.h"
#import "CodelessRssiCommand.h"
#import "CodelessIoConfigCommand.h"
#import "CodelessIoStatusCommand.h"
#import "CodelessI2cConfigCommand.h"
#import "CodelessI2cScanCommand.h"
#import "CodelessI2cReadCommand.h"
#import "CodelessMemStoreCommand.h"
#import "CodelessPinCodeCommand.h"
#import "CodelessCmdGetCommand.h"
#import "CodelessAdvertisingDataCommand.h"
#import "CodelessAdvertisingResponseCommand.h"
#import "CodelessRandomNumberCommand.h"
#import "CodelessBatteryLevelCommand.h"
#import "CodelessBaudRateCommand.h"
#import "CodelessBluetoothAddressCommand.h"
#import "CodelessBondingEntryStatusCommand.h"
#import "CodelessBondingEntryTransferCommand.h"
#import "CodelessGapStatusCommand.h"
#import "CodelessGapScanCommand.h"
#import "CodelessGapConnectCommand.h"
#import "CodelessGapDisconnectCommand.h"
#import "CodelessConnectionParametersCommand.h"
#import "CodelessMaxMtuCommand.h"
#import "CodelessFlowControlCommand.h"
#import "CodelessHostSleepCommand.h"
#import "CodelessSpiConfigCommand.h"
#import "CodelessSpiReadCommand.h"
#import "CodelessSpiTransferCommand.h"
#import "CodelessDataLengthEnableCommand.h"
#import "CodelessEventConfigCommand.h"
#import "CodelessBondingEntryClearCommand.h"
#import "CodelessBasicCommand.h"
#import "CodelessUartPrintCommand.h"
#import "CodelessEventHandlerCommand.h"
#import "CodelessSecurityModeCommand.h"
#import "CodelessHeartbeatCommand.h"
#import "CodelessPowerLevelConfigCommand.h"

@implementation CodelessLibEvent

static NSString* const BluetoothState = @"CodelessBluetoothStateEvent";
static NSString* const ScanStart = @"CodelessScanStartEvent";
static NSString* const ScanStop = @"CodelessScanStopEvent";
static NSString* const ScanResult = @"CodelessScanResultEvent";
static NSString* const ConnectionFailed = @"CodelessConnectionFailedEvent";
static NSString* const DeviceConnected = @"CodelessDeviceConnectedEvent";
static NSString* const DeviceDisconnected = @"CodelessDeviceDisconnectedEvent";
static NSString* const Connection = @"CodelessConnectionEvent";
static NSString* const ServiceDiscovery = @"CodelessServiceDiscoveryEvent";
static NSString* const Ready = @"CodelessReadyEvent";
static NSString* const Error = @"CodelessErrorEvent";
static NSString* const DeviceInfo = @"CodelessDeviceInfoEvent";
static NSString* const Rssi = @"CodelessRssiEvent";
static NSString* const BinaryModeRequest = @"CodelessBinaryModeRequestEvent";
static NSString* const Mode = @"CodelessModeEvent";
static NSString* const Line = @"CodelessLineEvent";
static NSString* const ScriptStart = @"CodelessScriptStartEvent";
static NSString* const ScriptEnd = @"CodelessScriptEndEvent";
static NSString* const ScriptCommand = @"CodelessScriptCommandEvent";
static NSString* const CommandSuccess = @"CodelessCommandSuccessEvent";
static NSString* const CommandError = @"CodelessCommandErrorEvent";
static NSString* const Ping = @"CodelessPingEvent";
static NSString* const DeviceInformation = @"CodelessDeviceInformationEvent";
static NSString* const UartEcho = @"CodelessUartEchoEvent";
static NSString* const BinEsc = @"CodelessBinEscEvent";
static NSString* const AnalogRead = @"CodelessAnalogReadEvent";
static NSString* const PwmStatus = @"CodelessPwmStatusEvent";
static NSString* const PwmStart = @"CodelessPwmStartEvent";
static NSString* const PeerRssi = @"CodelessPeerRssiEvent";
static NSString* const IoConfig = @"CodelessIoConfigEvent";
static NSString* const IoConfigSet = @"CodelessIoConfigSetEvent";
static NSString* const IoStatus = @"CodelessIoStatusEvent";
static NSString* const I2cConfig = @"CodelessI2cConfigEvent";
static NSString* const I2cScan = @"CodelessI2cScanEvent";
static NSString* const I2cRead = @"CodelessI2cReadEvent";
static NSString* const MemoryTextContent = @"CodelessMemoryTextContentEvent";
static NSString* const PinCode = @"CodelessPinCodeEvent";
static NSString* const StoredCommands = @"CodelessStoredCommandsEvent";
static NSString* const AdvertisingData = @"CodelessAdvertisingDataEvent";
static NSString* const ScanResponseData = @"CodelessScanResponseDataEvent";
static NSString* const RandomNumber = @"CodelessRandomNumberEvent";
static NSString* const BatteryLevel = @"CodelessBatteryLevelEvent";
static NSString* const BaudRate = @"CodelessBaudRateEvent";
static NSString* const BluetoothAddress = @"CodelessBluetoothAddressEvent";
static NSString* const BondingEntryPersistenceStatusSet = @"CodelessBondingEntryPersistenceStatusSetEvent";
static NSString* const BondingEntryPersistenceTableStatus = @"CodelessBondingEntryPersistenceTableStatusEvent";
static NSString* const BondingEntry = @"CodelessBondingEntryEvent";
static NSString* const GapStatus = @"CodelessGapStatusEvent";
static NSString* const GapScanResult = @"CodelessGapScanResultEvent";
static NSString* const GapDeviceConnected = @"CodelessGapDeviceConnectedEvent";
static NSString* const GapDeviceDisconnected = @"CodelessGapDeviceDisconnectedEvent";
static NSString* const ConnectionParameters = @"CodelessConnectionParametersEvent";
static NSString* const MaxMtu = @"CodelessMaxMtuEvent";
static NSString* const FlowControl = @"CodelessFlowControlEvent";
static NSString* const HostSleep = @"CodelessHostSleepEvent";
static NSString* const SpiConfig = @"CodelessSpiConfigEvent";
static NSString* const SpiRead = @"CodelessSpiReadEvent";
static NSString* const SpiTransfer = @"CodelessSpiTransferEvent";
static NSString* const DataLengthEnable = @"CodelessDataLengthEnableEvent";
static NSString* const EventStatus = @"CodelessEventStatusEvent";
static NSString* const EventStatusTable = @"CodelessEventStatusTableEvent";
static NSString* const BondingEntryClear = @"CodelessBondingEntryClearEvent";
static NSString* const InboundCommand = @"CodelessInboundCommandEvent";
static NSString* const HostCommand = @"CodelessHostCommandEvent";
static NSString* const Print = @"CodelessPrintEvent";
static NSString* const EventCommands = @"CodelessEventCommandsEvent";
static NSString* const EventCommandsTable = @"CodelessEventCommandsTableEvent";
static NSString* const SecurityMode = @"CodelessSecurityModeEvent";
static NSString* const Heartbeat = @"CodelessHeartbeatEvent";
static NSString* const PowerLevel = @"CodelessPowerLevelEvent";
static NSString* const DspsRxData = @"DspsRxDataEvent";
static NSString* const DspsRxFlowControl = @"DspsRxFlowControlEvent";
static NSString* const DspsTxFlowControl = @"DspsTxFlowControlEvent";
static NSString* const DspsFileChunk = @"DspsFileChunkEvent";
static NSString* const DspsFileError = @"DspsFileErrorEvent";
static NSString* const DspsRxFileData = @"DspsRxFileData";
static NSString* const DspsRxFileCrc = @"DspsRxFileCrc";
static NSString* const DspsPatternChunk = @"DspsPatternChunk";
static NSString* const DspsPatternFileError = @"DspsPatternFileError";
static NSString* const DspsStats = @"DspsStats";

+ (NSString*) BluetoothState {
    return BluetoothState;
}

+ (NSString*) ScanStart {
    return ScanStart;
}

+ (NSString*) ScanStop {
    return ScanStop;
}

+ (NSString*) ScanResult {
    return ScanResult;
}

+ (NSString*) ConnectionFailed {
    return ConnectionFailed;
}

+ (NSString*) DeviceConnected {
    return DeviceConnected;
}

+ (NSString*) DeviceDisconnected {
    return DeviceDisconnected;
}

+ (NSString*) Connection {
    return Connection;
}

+ (NSString*) ServiceDiscovery {
    return ServiceDiscovery;
}

+ (NSString*) Ready {
    return Ready;
}

+ (NSString*) Error {
    return Error;
}

+ (NSString*) DeviceInfo {
    return DeviceInfo;
}

+ (NSString*) Rssi {
    return Rssi;
}

+ (NSString*) BinaryModeRequest {
    return BinaryModeRequest;
}

+ (NSString*) Mode {
    return Mode;
}

+ (NSString*) Line {
    return Line;
}

+ (NSString*) ScriptStart {
    return ScriptStart;
}

+ (NSString*) ScriptEnd {
    return ScriptEnd;
}

+ (NSString*) ScriptCommand {
    return ScriptCommand;
}

+ (NSString*) CommandSuccess {
    return CommandSuccess;
}

+ (NSString*) CommandError {
    return CommandError;
}

+ (NSString*) Ping {
    return Ping;
}

+ (NSString*) DeviceInformation {
    return DeviceInformation;
}

+ (NSString*) UartEcho {
    return UartEcho;
}

+ (NSString*) BinEsc {
    return BinEsc;
}

+ (NSString*) AnalogRead {
    return AnalogRead;
}

+ (NSString*) PwmStatus {
    return PwmStatus;
}

+ (NSString*) PwmStart {
    return PwmStart;
}

+ (NSString*) PeerRssi {
    return PeerRssi;
}

+ (NSString*) IoConfig {
    return IoConfig;
}

+ (NSString*) IoConfigSet {
    return IoConfigSet;
}

+ (NSString*) IoStatus {
    return IoStatus;
}

+ (NSString*) I2cConfig {
    return I2cConfig;
}

+ (NSString*) I2cScan {
    return I2cScan;
}

+ (NSString*) I2cRead {
    return I2cRead;
}

+ (NSString*) MemoryTextContent {
    return MemoryTextContent;
}

+ (NSString*) PinCode {
    return PinCode;
}

+ (NSString*) StoredCommands {
    return StoredCommands;
}

+ (NSString*) AdvertisingData {
    return AdvertisingData;
}

+ (NSString*) ScanResponseData {
    return ScanResponseData;
}

+ (NSString*) RandomNumber {
    return RandomNumber;
}

+ (NSString*) BatteryLevel {
    return BatteryLevel;
}

+ (NSString*) BaudRate {
    return BaudRate;
}

+ (NSString*) BluetoothAddress {
    return BluetoothAddress;
}

+ (NSString*) BondingEntryPersistenceStatusSet {
    return BondingEntryPersistenceStatusSet;
}

+ (NSString*) BondingEntryPersistenceTableStatus {
    return BondingEntryPersistenceTableStatus;
}

+ (NSString*) BondingEntry {
    return BondingEntry;
}

+ (NSString*) GapStatus {
    return GapStatus;
}

+ (NSString*) GapScanResult {
    return GapScanResult;
}

+ (NSString*) GapDeviceConnected {
    return GapDeviceConnected;
}

+ (NSString*) GapDeviceDisconnected {
    return GapDeviceDisconnected;
}

+ (NSString*) ConnectionParameters {
    return ConnectionParameters;
}

+ (NSString*) MaxMtu {
    return MaxMtu;
}

+ (NSString*) FlowControl {
    return FlowControl;
}

+ (NSString*) HostSleep {
    return HostSleep;
}

+ (NSString*) SpiConfig {
    return SpiConfig;
}

+ (NSString*) SpiRead {
    return SpiRead;
}

+ (NSString*) SpiTransfer {
    return SpiTransfer;
}

+ (NSString*) DataLengthEnable {
    return DataLengthEnable;
}

+ (NSString*) EventStatus {
    return EventStatus;
}

+ (NSString*) EventStatusTable {
    return EventStatusTable;
}

+ (NSString*) BondingEntryClear {
    return BondingEntryClear;
}

+ (NSString*) InboundCommand {
    return InboundCommand;
}

+ (NSString*) HostCommand {
    return HostCommand;
}

+ (NSString*) Print {
    return Print;
}

+ (NSString*) EventCommands {
    return EventCommands;
}

+ (NSString*) EventCommandsTable {
    return EventCommandsTable;
}

+ (NSString*) SecurityMode {
    return SecurityMode;
}

+ (NSString*) Heartbeat {
    return Heartbeat;
}

+ (NSString*) PowerLevel {
    return PowerLevel;
}

+ (NSString*) DspsRxData {
    return DspsRxData;
}

+ (NSString*) DspsRxFlowControl {
    return DspsRxFlowControl;
}

+ (NSString*) DspsTxFlowControl {
    return DspsTxFlowControl;
}

+ (NSString*) DspsFileChunk {
    return DspsFileChunk;
}

+ (NSString*) DspsFileError {
    return DspsFileError;
}

+ (NSString*) DspsRxFileData {
    return DspsRxFileData;
}

+ (NSString*) DspsRxFileCrc {
    return DspsRxFileCrc;
}

+ (NSString*) DspsPatternChunk {
    return DspsPatternChunk;
}

+ (NSString*) DspsPatternFileError {
    return DspsPatternFileError;
}

+ (NSString*) DspsStats {
    return DspsStats;
}

@end


@implementation CodelessBluetoothEvent

- (instancetype) initWithManager:(CodelessBluetoothManager*)manager {
    self = [super init];
    if (!self)
        return nil;
    self.manager = manager;
    return self;
}

@end


@implementation CodelessBluetoothStateEvent

- (instancetype) initWithManager:(CodelessBluetoothManager*)manager {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.state = @(manager.centralManager.state);
    return self;
}

@end


@implementation CodelessScanStartEvent

@end


@implementation CodelessScanStopEvent

@end


@implementation CodelessScanResultEvent

- (instancetype) initWithManager:(CodelessBluetoothManager*)manager device:(CBPeripheral*)device advData:(CodelessAdvData*)advData rssi:(NSNumber*)rssi {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.device = device;
    self.advData = advData;
    self.rssi = rssi;
    return self;
}

@end


@implementation CodelessConnectionFailedEvent

- (instancetype) initWithManager:(CodelessBluetoothManager*)manager device:(CBPeripheral*)device error:(NSError*)error {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.device = device;
    self.error = error;
    return self;
}

@end


@implementation CodelessDeviceConnectedEvent

- (instancetype) initWithManager:(CodelessBluetoothManager*)manager device:(CBPeripheral*)device {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.device = device;
    return self;
}

@end


@implementation CodelessDeviceDisconnectedEvent

- (instancetype) initWithManager:(CodelessBluetoothManager*)manager device:(CBPeripheral*)device error:(NSError*)error {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.device = device;
    self.error = error;
    return self;
}

@end


@implementation CodelessEvent

- (instancetype) initWithManager:(CodelessManager*)manager {
    self = [super init];
    if (!self)
        return nil;
    self.manager = manager;
    return self;
}

@end


@implementation CodelessConnectionEvent

@end


@implementation CodelessServiceDiscoveryEvent

- (instancetype) initWithManager:(CodelessManager*)manager complete:(BOOL)complete {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.complete = complete;
    return self;
}

@end


@implementation CodelessReadyEvent

@end


@implementation CodelessErrorEvent

- (instancetype) initWithManager:(CodelessManager*)manager error:(int)error {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.error = error;
    return self;
}

@end


@implementation CodelessDeviceInfoEvent

- (instancetype) initWithManager:(CodelessManager*)manager uuid:(CBUUID*)uuid value:(NSData*)value info:(NSString*)info {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.uuid = uuid;
    self.value = value;
    self.info = info;
    return self;
}

@end


@implementation CodelessRssiEvent

- (instancetype) initWithManager:(CodelessManager*)manager rssi:(NSNumber*)rssi {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.rssi = rssi;
    return self;
}

@end


@implementation CodelessBinaryModeRequestEvent

@end


@implementation CodelessModeEvent

- (instancetype) initWithManager:(CodelessManager*)manager command:(BOOL)command {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.command = command;
    return self;
}

@end


@implementation CodelessLineEvent

- (instancetype) initWithManager:(CodelessManager*)manager line:(CodelessLine*)line {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.line = line;
    return self;
}

@end


@implementation CodelessScriptStartEvent

- (instancetype) initWithScript:(CodelessScript*)script {
    self = [super initWithManager:script.manager];
    if (!self)
        return nil;
    self.script = script;
    return self;
}

@end


@implementation CodelessScriptEndEvent

- (instancetype) initWithScript:(CodelessScript*)script error:(BOOL)error {
    self = [super initWithManager:script.manager];
    if (!self)
        return nil;
    self.script = script;
    self.error = error;
    return self;
}

@end


@implementation CodelessScriptCommandEvent

- (instancetype) initWithScript:(CodelessScript*)script command:(CodelessCommand*)command {
    self = [super initWithManager:script.manager];
    if (!self)
        return nil;
    self.script = script;
    self.command = command;
    return self;
}

@end


@implementation CodelessCommandEvent

- (instancetype) initWithCodelessCommand:(CodelessCommand*)command {
    self = [super initWithManager:command.manager];
    if (!self)
        return nil;
    self.command = command;
    return self;
}

@end


@implementation CodelessCommandSuccessEvent

- (instancetype) initWithCommand:(CodelessCommand*)command {
    return self = [super initWithCodelessCommand:command];
}

@end


@implementation CodelessCommandErrorEvent

- (instancetype) initWithCommand:(CodelessCommand*)command msg:(NSString*)msg {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.msg = msg;
    return self;
}

@end


@implementation CodelessPingEvent

- (instancetype) initWithCommand:(CodelessBasicCommand*)command {
    return self = [super initWithCodelessCommand:command];
}

@end


@implementation CodelessDeviceInformationEvent

- (instancetype) initWithCommand:(CodelessDeviceInformationCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.info = command.info;
    return self;
}

@end


@implementation CodelessUartEchoEvent

- (instancetype) initWithCommand:(CodelessUartEchoCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.echo = command.echo;
    return self;
}

@end


@implementation CodelessBinEscEvent

- (instancetype) initWithCommand:(CodelessBinEscCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.sequence = command.sequence;
    self.timePrior = command.timePrior;
    self.timeAfter = command.timeAfter;
    return self;
}

@end


@implementation CodelessAnalogReadEvent

- (instancetype) initWithCommand:(CodelessAdcReadCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.gpio = command.gpio;
    self.state = [command getState];
    return self;
}

@end


@implementation CodelessPwmStatusEvent

- (instancetype) initWithCommand:(CodelessPulseGenerationCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.frequency = command.frequency;
    self.dutyCycle = command.dutyCycle;
    self.duration = command.duration;
    return self;
}

@end


@implementation CodelessPwmStartEvent

- (instancetype) initWithCommand:(CodelessPulseGenerationCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.frequency = command.frequency;
    self.dutyCycle = command.dutyCycle;
    self.duration = command.duration;
    return self;
}

@end


@implementation CodelessPeerRssiEvent

- (instancetype) initWithCommand:(CodelessRssiCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.rssi = command.rssi;
    return self;
}

@end


@implementation CodelessIoConfigEvent

- (instancetype) initWithCommand:(CodelessIoConfigCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.configuration = command.configuration;
    return self;
}

@end


@implementation CodelessIoConfigSetEvent

- (instancetype) initWithCommand:(CodelessIoConfigCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.gpio = command.gpio;
    return self;
}

@end


@implementation CodelessIoStatusEvent

- (instancetype) initWithCommand:(CodelessIoStatusCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.gpio = command.gpio;
    self.status = [command getStatus];
    return self;
}

@end


@implementation CodelessI2cConfigEvent

- (instancetype) initWithCommand:(CodelessI2cConfigCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.addressSize = command.bitCount;
    self.bitrate = command.bitRate;
    self.registerSize = command.registerWidth;
    return self;
}

@end


@implementation CodelessI2cScanEvent

- (instancetype) initWithCommand:(CodelessI2cScanCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.devices = command.devices;
    return self;
}

@end


@implementation CodelessI2cReadEvent

- (instancetype) initWithCommand:(CodelessI2cReadCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.data = command.data;
    return self;
}

@end


@implementation CodelessMemoryTextContentEvent

- (instancetype) initWithCommand:(CodelessMemStoreCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.index = command.memIndex;
    self.text = command.text;
    return self;
}

@end


@implementation CodelessPinCodeEvent

- (instancetype) initWithCommand:(CodelessPinCodeCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.pinCode = command.pinCode;
    return self;
}

@end


@implementation CodelessStoredCommandsEvent

- (instancetype) initWithCommand:(CodelessCmdGetCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.index = command.index;
    self.commands = command.commands;
    return self;
}

@end


@implementation CodelessAdvertisingDataEvent

- (instancetype) initWithCommand:(CodelessAdvertisingDataCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.data = command.data;
    return self;
}

@end


@implementation CodelessScanResponseDataEvent

- (instancetype) initWithCommand:(CodelessAdvertisingResponseCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.data = command.data;
    return self;
}

@end


@implementation CodelessRandomNumberEvent

- (instancetype) initWithCommand:(CodelessRandomNumberCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.number = command.number;
    return self;
}

@end


@implementation CodelessBatteryLevelEvent

- (instancetype) initWithCommand:(CodelessBatteryLevelCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.level = command.level;
    return self;
}

@end


@implementation CodelessBaudRateEvent

- (instancetype) initWithCommand:(CodelessBaudRateCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.baudRate = command.baudRate;
    return self;
}

@end


@implementation CodelessBluetoothAddressEvent

- (instancetype) initWithCommand:(CodelessBluetoothAddressCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.address = command.address;
    self.random = command.random;
    return self;
}

@end


@implementation CodelessBondingEntryPersistenceStatusSetEvent

- (instancetype) initWithCommand:(CodelessBondingEntryStatusCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.index = command.index;
    self.persistent = command.persistent;
    return self;
}

@end


@implementation CodelessBondingEntryPersistenceTableStatusEvent

- (instancetype) initWithCommand:(CodelessBondingEntryStatusCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.persistenceStatusTable = command.tablePersistenceStatus;
    return self;
}

@end


@implementation CodelessBondingEntryEvent

- (instancetype) initWithCommand:(CodelessBondingEntryTransferCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.index = command.index;
    self.entry = command.bondingEntry;
    return self;
}

@end


@implementation CodelessGapStatusEvent

- (instancetype) initWithCommand:(CodelessGapStatusCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.gapRole = command.gapRole;
    self.connected = command.connected;
    return self;
}

@end


@implementation CodelessGapScanResultEvent

- (instancetype) initWithCommand:(CodelessGapScanCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.devices = command.devices;
    return self;
}

@end


@implementation CodelessGapDeviceConnectedEvent

- (instancetype) initWithCommand:(CodelessGapConnectCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.deviceAddress = command.address;
    return self;
}

@end


@implementation CodelessGapDeviceDisconnectedEvent

- (instancetype) initWithCommand:(CodelessGapDisconnectCommand*)command {
    return self = [super initWithCodelessCommand:command];
}

@end


@implementation CodelessConnectionParametersEvent

- (instancetype) initWithCommand:(CodelessConnectionParametersCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.interval = command.interval;
    self.latency = command.latency;
    self.timeout = command.timeout;
    self.action = command.action;
    return self;
}

@end


@implementation CodelessMaxMtuEvent

- (instancetype) initWithCommand:(CodelessMaxMtuCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.mtu = command.mtu;
    return self;
}

@end


@implementation CodelessFlowControlEvent

- (instancetype) initWithCommand:(CodelessFlowControlCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.enabled = command.isEnabled;
    self.rtsGpio = command.rtsGpio;
    self.ctsGpio = command.ctsGpio;
    return self;
}

@end


@implementation CodelessHostSleepEvent

- (instancetype) initWithCommand:(CodelessHostSleepCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.hostSleepMode = command.hostSleepMode;
    self.wakeupByte = command.wakeupByte;
    self.wakeupRetryInterval = command.wakeupRetryInterval;
    self.wakeupRetryTimes = command.wakeupRetryTimes;
    return self;
}

@end


@implementation CodelessSpiConfigEvent

- (instancetype) initWithCommand:(CodelessSpiConfigCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.speed = command.speed;
    self.mode = command.mode;
    self.size = command.size;
    return self;
}

@end


@implementation CodelessSpiReadEvent

- (instancetype) initWithCommand:(CodelessSpiReadCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.data = command.data;
    return self;
}

@end


@implementation CodelessSpiTransferEvent

- (instancetype) initWithCommand:(CodelessSpiTransferCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.data = command.data;
    return self;
}

@end


@implementation CodelessDataLengthEnableEvent

- (instancetype) initWithCommand:(CodelessDataLengthEnableCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.enabled = command.enabled;
    self.txPacketLength = command.txPacketLength;
    self.rxPacketLength = command.rxPacketLength;
    return self;
}

@end


@implementation CodelessEventStatusEvent

- (instancetype) initWithCommand:(CodelessEventConfigCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.eventConfig = command.eventConfig;
    return self;
}

@end


@implementation CodelessEventStatusTableEvent

- (instancetype) initWithCommand:(CodelessEventConfigCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.eventStatusTable = command.eventStatusTable;
    return self;
}

@end


@implementation CodelessBondingEntryClearEvent

- (instancetype) initWithCommand:(CodelessBondingEntryClearCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.index = command.index;
    return self;
}

@end


@implementation CodelessInboundCommandEvent : CodelessCommandEvent

- (instancetype) initWithCommand:(CodelessCommand*)command {
    return self = [super initWithCodelessCommand:command];
}

@end


@implementation CodelessHostCommandEvent : CodelessCommandEvent

- (instancetype) initWithCommand:(CodelessCommand*)command {
    return self = [super initWithCodelessCommand:command];
}

@end


@implementation CodelessPrintEvent : CodelessCommandEvent

- (instancetype) initWithCommand:(CodelessUartPrintCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.text = command.text;
    return self;
}

@end


@implementation CodelessEventCommandsEvent

- (instancetype) initWithCommand:(CodelessEventHandlerCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.eventHandler = command.eventHandler;
    return self;
}

@end


@implementation CodelessEventCommandsTableEvent

- (instancetype) initWithCommand:(CodelessEventHandlerCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.eventHandlerTable = command.eventHandlerTable;
    return self;
}

@end


@implementation CodelessSecurityModeEvent

- (instancetype) initWithCommand:(CodelessSecurityModeCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.mode = command.mode;
    return self;
}

@end


@implementation CodelessHeartbeatEvent

- (instancetype) initWithCommand:(CodelessHeartbeatCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.enabled = command.enabled;
    return self;
}

@end


@implementation CodelessPowerLevelEvent

- (instancetype) initWithCommand:(CodelessPowerLevelConfigCommand*)command {
    self = [super initWithCodelessCommand:command];
    if (!self)
        return nil;
    self.powerLevel = command.powerLevel;
    self.notSupported = command.notSupported;
    return self;
}

@end


@implementation DspsRxDataEvent

- (instancetype) initWithManager:(CodelessManager*)manager data:(NSData*)data {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.data = data;
    return self;
}

@end


@implementation DspsRxFlowControlEvent

- (instancetype) initWithManager:(CodelessManager*)manager flowOn:(BOOL)flowOn {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.flowOn = flowOn;
    return self;
}

@end


@implementation DspsTxFlowControlEvent

- (instancetype) initWithManager:(CodelessManager*)manager flowOn:(BOOL)flowOn {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.flowOn = flowOn;
    return self;
}

@end


@implementation DspsFileChunkEvent

- (instancetype) initWithManager:(CodelessManager*)manager operation:(DspsFileSend*)operation chunk:(int)chunk {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.operation = operation;
    self.chunk = chunk;
    return self;
}

@end


@implementation DspsFileErrorEvent

- (instancetype) initWithManager:(CodelessManager*)manager operation:(DspsFileSend*)operation {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.operation = operation;
    return self;
}

@end


@implementation DspsRxFileDataEvent

- (instancetype) initWithManager:(CodelessManager*)manager operation:(DspsFileReceive*)operation size:(int)size bytesReceived:(int)bytesReceived {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.operation = operation;
    self.size = size;
    self.bytesReceived = bytesReceived;
    return self;
}

@end


@implementation DspsRxFileCrcEvent

- (instancetype)initWithManager:(CodelessManager*)manager operation:(DspsFileReceive*)operation ok:(BOOL)ok {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.operation = operation;
    self.ok = ok;
    return self;
}

@end


@implementation DspsPatternChunkEvent

- (instancetype) initWithManager:(CodelessManager*)manager operation:(DspsPeriodicSend*)operation count:(int)count {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.operation = operation;
    self.count = count;
    return self;
}

@end


@implementation DspsPatternFileErrorEvent

- (instancetype) initWithManager:(CodelessManager*)manager operation:(DspsPeriodicSend*)operation file:(NSString*)file {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.operation = operation;
    self.file = file;
    return self;
}

@end


@implementation DspsStatsEvent

- (instancetype) initWithManager:(CodelessManager*)manager operation:(NSObject*)operation currentSpeed:(int)currentSpeed averageSpeed:(int)averageSpeed {
    self = [super initWithManager:manager];
    if (!self)
        return nil;
    self.operation = operation;
    self.currentSpeed = currentSpeed;
    self.averageSpeed = averageSpeed;
    return self;
}

@end
