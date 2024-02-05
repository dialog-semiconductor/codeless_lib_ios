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
@class CodelessBasicCommand;
@class CodelessDeviceInformationCommand;
@class CodelessResetCommand;
@class CodelessBluetoothAddressCommand;
@class CodelessRssiCommand;
@class CodelessBatteryLevelCommand;
@class CodelessRandomNumberCommand;
@class CodelessBinRequestCommand;
@class CodelessBinRequestAckCommand;
@class CodelessBinExitCommand;
@class CodelessBinExitAckCommand;
@class CodelessConnectionParametersCommand;
@class CodelessMaxMtuCommand;
@class CodelessDataLengthEnableCommand;
@class CodelessAdvertisingDataCommand;
@class CodelessAdvertisingResponseCommand;
@class CodelessIoConfigCommand;
@class CodelessResetIoConfigCommand;
@class CodelessGPIO;
@class CodelessIoConfigCommand;
@class CodelessIoStatusCommand;
@class CodelessAdcReadCommand;
@class CodelessPulseGenerationCommand;
@class CodelessI2cConfigCommand;
@class CodelessI2cScanCommand;
@class CodelessI2cReadCommand;
@class CodelessI2cReadCommand;
@class CodelessI2cWriteCommand;
@class CodelessSpiConfigCommand;
@class CodelessSpiWriteCommand;
@class CodelessSpiReadCommand;
@class CodelessSpiTransferCommand;
@class CodelessUartPrintCommand;
@class CodelessMemStoreCommand;
@class CodelessRandomNumberCommand;
@class CodelessCmdGetCommand;
@class CodelessCmdStoreCommand;
@class CodelessCmdPlayCommand;
@class CodelessTimerStartCommand;
@class CodelessTimerStopCommand;
@class CodelessEventConfigCommand;
@class CodelessEventHandlerCommand;
@class CodelessBaudRateCommand;
@class CodelessUartEchoCommand;
@class CodelessHeartbeatCommand;
@class CodelessHostSleepCommand;
@class CodelessSecurityModeCommand;
@class CodelessPinCodeCommand;
@class CodelessFlowControlCommand;
@class CodelessErrorReportingCommand;
@class CodelessCursorCommand;
@class CodelessDeviceSleepCommand;
@class CodelessPowerLevelConfigCommand;
@class CodelessBondingEntryClearCommand;
@class CodelessBondingEntryStatusCommand;
@class CodelessBondingEntryTransferCommand;
@class CodelessBondingEntry;
@class CodelessPingEvent;
#import "CodelessLibEvent.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Contains helper methods for sending various CodeLess AT commands to the peer device.
 *
 * Each method creates the relevant {@link CodelessCommand command} subclass object,
 * sends the command to the peer device, and returns the command object. If the command
 * completes successfully, a {@link CodelessLibEvent command specific event} may be generated.
 * @see CodelessManager#commandFactory
 * @see <a href="https://lpccs-docs.renesas.com/UM-140-DA145x-CodeLess/index.html">AT commands documentation</a>
 */
@interface CodelessCommands : NSObject

/// The {@link CodelessManager manager} associated with the peer device.
@property (weak) CodelessManager* manager;

/**
 * Creates a %CodelessCommands object.
 * @param manager the {@link CodelessManager manager} associated with the peer device
 */
- (instancetype) initWithManager:(CodelessManager*)manager;

/**
 * Sends the <code>AT+</code> command.
 * <p> On success, a {@link CodelessLibEvent#Ping Ping} event is generated.
 */
- (CodelessBasicCommand*) ping;

/**
 * Sends the <code>AT+I</code> command to get the peer device information.
 * <p> On success, a {@link CodelessLibEvent#DeviceInformation DeviceInformation} event is generated.
 */
- (CodelessDeviceInformationCommand*) getDeviceInfo;

/// Sends the <code>AT+R</code> command to reset the peer device.
- (CodelessResetCommand*) resetDevice;

/**
 * Sends the <code>AT+BDADDR</code> command to get the Bluetooth address of the peer device.
 * <p> On success, a {@link CodelessLibEvent#BluetoothAddress BluetoothAddress} event is generated.
 */
- (CodelessBluetoothAddressCommand*) getBluetoothAddress;

/**
 * Sends the <code>AT+RSSI</code> command to get the connection RSSI measured by the peer device.
 * <p> On success, a {@link CodelessLibEvent#PeerRssi PeerRssi} event is generated.
 */
- (CodelessRssiCommand*) getPeerRssi;

/**
 * Sends the <code>AT+BATT</code> command to get the battery level of the peer device.
 * <p> On success, a {@link CodelessLibEvent#BatteryLevel BatteryLevel} event is generated.
 */
- (CodelessBatteryLevelCommand*) getBatteryLevel;

/**
 * Sends the <code>AT+BINREQ</code> command to request switching to binary (DSPS) mode.
 * <p> On success, {@link CodelessManager#onBinRequestSent} is called.
 */
- (CodelessBinRequestCommand*) requestBinaryMode;

/**
 * Sends the <code>AT+BINREQACK</code> command to accept the peer request to switch to binary (DSPS) mode.
 * <p> On success, {@link CodelessManager#onBinAckSent} is called.
 */
- (CodelessBinRequestAckCommand*) sendBinaryRequestAck;

/**
 * Sends the <code>AT+BINREQEXIT</code> command to request switching to command (CodeLess) mode.
 * <p> On success, {@link CodelessManager#onBinExitSent} is called.
 */
- (CodelessBinExitCommand*) sendBinaryExit;

/**
 * Sends the <code>AT+BINREQEXITACK</code> command to accept the peer request to switch to command (CodeLess) mode.
 * <p> On success, {@link CodelessManager#onBinExitAckSent} is called.
 */
- (CodelessBinExitAckCommand*) sendBinaryExitAck;

/**
 * Sends the <code>AT+CONPAR</code> command to get the current connection parameters.
 * <p> On success, a {@link CodelessLibEvent#ConnectionParameters ConnectionParameters} event is generated.
 */
- (CodelessConnectionParametersCommand*) getConnectionParameters;

/**
 * Sends the <code>AT+CONPAR</code> command to set the connection parameters.
 * <p> On success, a {@link CodelessLibEvent#ConnectionParameters ConnectionParameters} event is generated.
 * @param connectionInterval    the connection interval in multiples of 1.25 ms
 * @param slaveLatency          the slave latency
 * @param supervisionTimeout    the supervision timeout in multiples of 10 ms
 * @param action                specify how to apply the new connection parameters
 */
- (CodelessConnectionParametersCommand*) setConnectionParameters:(int)connectionInterval slaveLatency:(int)slaveLatency supervisionTimeout:(int)supervisionTimeout action:(int)action;

/**
 * Sends the <code>AT+MAXMTU</code> command to get the current maximum MTU.
 * <p> On success, a {@link CodelessLibEvent#MaxMtu MaxMtu} event is generated.
 */
- (CodelessMaxMtuCommand*) getMaxMtu;

/**
 * Sends the <code>AT+MAXMTU</code> command to set the maximum MTU.
 * <p> On success, a {@link CodelessLibEvent#MaxMtu MaxMtu} event is generated.
 * @param mtu the MTU value
 */
- (CodelessMaxMtuCommand*) setMaxMtu:(int)mtu;

/**
 * Sends the <code>AT+DLEEN</code> command to get the DLE feature configuration.
 * <p> On success, a {@link CodelessLibEvent#DataLengthEnable DataLengthEnable} event is generated.
 */
- (CodelessDataLengthEnableCommand*) getDataLength;

/**
 * Sends the <code>AT+DLEEN</code> command to set the DLE feature configuration.
 * <p> On success, a {@link CodelessLibEvent#DataLengthEnable DataLengthEnable} event is generated.
 * @param enabled           enable/disable the DLE feature
 * @param txPacketLength    the DLE TX packet length
 * @param rxPacketLength    the DLE RX packet length
 */
- (CodelessDataLengthEnableCommand*) setDataLength:(BOOL)enabled txPacketLength:(int)txPacketLength rxPacketLength:(int)rxPacketLength;

/**
 * Sends the <code>AT+DLEEN</code> command to enable/disable the DLE feature.
 * <p> Default values are used for TX/RX packet length.
 * @param enabled enable/disable the DLE feature
 * @see #setDataLength:txPacketLength:rxPacketLength:
 */
- (CodelessDataLengthEnableCommand*) setDataLengthEnabled:(BOOL)enabled;

/**
 * Sends the <code>AT+DLEEN</code> command to enable the DLE feature.
 * @see #setDataLengthEnabled:
 */
- (CodelessDataLengthEnableCommand*) enableDataLength;

/**
 * Sends the <code>AT+DLEEN</code> command to disable the DLE feature.
 * @see #setDataLengthEnabled:
 */
- (CodelessDataLengthEnableCommand*) disableDataLength;

/**
 * Sends the <code>AT+ADVDATA</code> command to get the advertising data configuration.
 * <p> On success, an {@link CodelessLibEvent#AdvertisingData AdvertisingData} event is generated.
 */
- (CodelessAdvertisingDataCommand*) getAdvertisingData;

/**
 * Sends the <code>AT+ADVDATA</code> command to set the advertising data configuration.
 * <p> On success, an {@link CodelessLibEvent#AdvertisingData AdvertisingData} event is generated.
 * @param data the advertising data byte array
 */
- (CodelessAdvertisingDataCommand*) setAdvertisingData:(NSData*)data;

/**
 * Sends the <code>AT+ADVRESP</code> command to get the scan response data configuration.
 * <p> On success, a {@link CodelessLibEvent#ScanResponseData ScanResponseData} event is generated.
 */
- (CodelessAdvertisingResponseCommand*) getScanResponseData;

/**
 * Sends the <code>AT+ADVRESP</code> command to set the scan response data configuration.
 * <p> On success, a {@link CodelessLibEvent#ScanResponseData ScanResponseData} event is generated.
 * @param data the scan response data byte array
 */
- (CodelessAdvertisingResponseCommand*) setScanResponseData:(NSData*)data;

/**
 * Sends the <code>AT+IOCFG</code> command to get the IO pin configuration.
 * <p> On success, an {@link CodelessLibEvent#IoConfig IoConfig} event is generated.
 */
- (CodelessIoConfigCommand*) readIoConfig;

/**
 * Sends the <code>AT+Z</code> command to reset the IO pin configuration to the default values.
 * <p> On success, the app should {@link #readIoConfig read the new configuration}.
 */
- (CodelessResetIoConfigCommand*) resetIoConfig;

/**
 * Sends the <code>AT+IOCFG</code> command to set the functionality of an IO pin.
 * <p> On success, an {@link CodelessLibEvent#IoConfigSet IoConfigSet} event is generated.
 * @param gpio {@link CodelessGPIO GPIO} that specifies the selected pin and IO functionality, and, optionally, the initial level
 */
- (CodelessIoConfigCommand*) setIoConfig:(CodelessGPIO*)gpio;

/**
 * Sends the <code>AT+IO</code> command to read the binary status of an input pin.
 * <p> On success, an {@link CodelessLibEvent#IoStatus IoStatus} event is generated.
 * @param gpio {@link CodelessGPIO GPIO} that selects the input pin
 */
- (CodelessIoStatusCommand*) readInput:(CodelessGPIO*)gpio;

/**
 * Sends the <code>AT+IO</code> command to set the status of an output pin.
 * <p> On success, an {@link CodelessLibEvent#IoStatus IoStatus} event is generated.
 * @param gpio      {@link CodelessGPIO GPIO} that selects the output pin
 * @param status    <code>true</code> for high, <code>false</code> for low.
 */
- (CodelessIoStatusCommand*) setOutput:(CodelessGPIO*)gpio status:(BOOL)status;

/**
 * Sends the <code>AT+IO</code> command to set the status of an output pin to low.
 * @param gpio {@link CodelessGPIO GPIO} that selects the output pin
 * @see #setOutput:status:
 */
- (CodelessIoStatusCommand*) setOutputLow:(CodelessGPIO*)gpio;

/**
 * Sends the <code>AT+IO</code> command to set the status of an output pin to high.
 * @param gpio {@link CodelessGPIO GPIO} that selects the output pin
 * @see #setOutput:status:
 */
- (CodelessIoStatusCommand*) setOutputHigh:(CodelessGPIO*)gpio;

/**
 * Sends the <code>AT+ADC</code> command to read the analog state of an input pin.
 * <p> On success, an {@link CodelessLibEvent#AnalogRead AnalogRead} event is generated.
 * @param gpio {@link CodelessGPIO GPIO} that selects the input pin
 */
- (CodelessAdcReadCommand*) readAnalogInput:(CodelessGPIO*)gpio;

/**
 * Sends the <code>AT+PWM</code> command to get the PWM configuration.
 * <p> On success, an {@link CodelessLibEvent#PwmStatus PwmStatus} event is generated.
 */
- (CodelessPulseGenerationCommand*) getPwm;

/**
 * Sends the <code>AT+PWM</code> command to generate a PWM pulse with the specified configuration.
 * <p> On success, a {@link CodelessLibEvent#PwmStart PwmStart} event is generated.
 * @param frequency     the frequency of the pulse in Hz
 * @param dutyCycle     the duty cycle of the pulse
 * @param duration      the duration of the pulse in ms
 */
- (CodelessPulseGenerationCommand*) setPwm:(int)frequency dutyCycle:(int)dutyCycle duration:(int)duration;

/**
 * Sends the <code>AT+I2CCFG</code> command to configure the I2C bus.
 * <p> On success, an {@link CodelessLibEvent#I2cConfig I2cConfig} event is generated.
 * @param addressSize   the I2C address bit-count
 * @param bitrate       the I2C bus bitrate in KHz
 * @param registerSize  the I2C register bit-count
 */
- (CodelessI2cConfigCommand*) setI2cConfig:(int)addressSize bitRate:(int)bitRate registerSize:(int)registerSize;

/**
 * Sends the <code>AT+I2CSCAN</code> command to scan the I2C bus for devices.
 * <p> On success, an {@link CodelessLibEvent#I2cScan I2cScan} event is generated.
 */
- (CodelessI2cScanCommand*) i2cScan;

/**
 * Sends the <code>AT+I2CREAD</code> command to read the value of an I2C register.
 * <p> On success, an {@link CodelessLibEvent#I2cRead I2cRead} event is generated.
 * @param address       the I2C address
 * @param i2cRegister   the register to read
 */
- (CodelessI2cReadCommand*) i2cRead:(int)address i2cRegister:(int)i2cRegister;

/**
 * Sends the <code>AT+I2CREAD</code> command to read one or more bytes starting from the specified I2C register.
 * <p> On success, an {@link CodelessLibEvent#I2cRead I2cRead} event is generated.
 * @param address       the I2C address
 * @param i2cRegister   the register to read
 * @param count         the number of bytes to read
 */
- (CodelessI2cReadCommand*) i2cRead:(int)address i2cRegister:(int)i2cRegister count:(int)count;

/**
 * Sends the <code>AT+I2CWRITE</code> command to write a byte value to an I2C register.
 * @param address       the I2C address
 * @param i2cRegister   the register to write
 * @param value         the value to write
 */
- (CodelessI2cWriteCommand*) i2cWrite:(int)address i2cRegister:(int)i2cRegister value:(int)value;

/**
 * Sends the <code>AT+SPICFG</code> command to get the SPI configuration.
 * <p> On success, a {@link CodelessLibEvent#SpiConfig SpiConfig} event is generated.
 */
- (CodelessSpiConfigCommand*) readSpiConfig;

/**
 * Sends the <code>AT+SPICFG</code> command to set the SPI configuration.
 * <p> On success, a {@link CodelessLibEvent#SpiConfig SpiConfig} event is generated.
 * @param speed     the SPI clock value (0: 2 MHz, 1: 4 MHz, 2: 8 MHz)
 * @param mode      the SPI mode (clock polarity and phase)
 * @param size      the SPI word bit-count
 */
- (CodelessSpiConfigCommand*) setSpiConfig:(int)speed mode:(int)mode size:(int)size;

/**
 * Sends the <code>AT+SPIWR</code> command to write a byte array value to the attached SPI device.
 * @param hexString the byte array value to write as a hex string
 */
- (CodelessSpiWriteCommand*) spiWrite:(NSString*)hexString;

/**
 * Sends the <code>AT+SPIRD</code> command to read one or more bytes from the attached SPI device.
 * <p> On success, a {@link CodelessLibEvent#SpiRead SpiRead} event is generated.
 * @param count the number of bytes to read
 */
- (CodelessSpiReadCommand*) spiRead:(int)count;

/**
 * Sends the <code>AT+SPITR</code> command to write a byte array value to the attached SPI device while reading the response.
 * <p> On success, a {@link CodelessLibEvent#SpiTransfer SpiTransfer} event is generated.
 * @param hexString the byte array value to write as a hex string
 */
- (CodelessSpiTransferCommand*) spiTransfer:(NSString*)hexString;

/**
 * Sends the <code>AT+PRINT</code> command to print some text to the UART of the peer device.
 * @param text the text to print
 */
- (CodelessUartPrintCommand*) print:(NSString*)text;

/**
 * Sends the <code>AT+MEM</code> command to store text data in a memory slot.
 * <p> On success, a {@link CodelessLibEvent#MemoryTextContent MemoryTextContent} event is generated.
 * @param index     the memory slot index (0-3)
 * @param content   the text to store
 */
- (CodelessMemStoreCommand*) setMemContent:(int)index content:(NSString*)content;

/**
 * Sends the <code>AT+MEM</code> command to get the text data stored in a memory slot.
 * <p> On success, a {@link CodelessLibEvent#MemoryTextContent MemoryTextContent} event is generated.
 * @param index the memory slot index (0-3)
 */
- (CodelessMemStoreCommand*) getMemContent:(int)index;

/**
 * Sends the <code>AT+RANDOM</code> command to get a random value from the peer device.
 * <p> On success, a {@link CodelessLibEvent#RandomNumber RandomNumber} event is generated.
 */
- (CodelessRandomNumberCommand*) getRandom;

/**
 * Sends the <code>AT+CMD</code> command to get the list of the stored commands in a command slot.
 * <p> On success, a {@link CodelessLibEvent#StoredCommands StoredCommands} event is generated.
 * @param index the command slot index (0-3)
 */
- (CodelessCmdGetCommand*) getStoredCommands:(int)index;

/**
 * Sends the <code>AT+CMDSTORE</code> command to store a list of commands in a command slot.
 * @param index             the command slot index (0-3)
 * @param commandString     the commands to store (semicolon separated)
 */
- (CodelessCmdStoreCommand*) storeCommands:(int)index commandString:(NSString*)commandString;

/**
 * Sends the <code>AT+CMDPLAY</code> command to execute the list of the stored commands in a command slot.
 * @param index the command slot index to execute (0-3)
 */
- (CodelessCmdPlayCommand*) playCommands:(int)index;

/**
 * Sends the <code>AT+TMRSTART</code> command to start a timer that will trigger the execution of a list of stored commands.
 * @param timerIndex    the timer index to start (0-3)
 * @param commandIndex  the command slot index to execute when the timer expires (0-3)
 * @param delay         the timer delay in multiples of 10 ms
 */
- (CodelessTimerStartCommand*) startTimer:(int)timerIndex commandIndex:(int)commandIndex delay:(int)delay;

/**
 * Sends the <code>AT+TMRSTOP</code> command to stop a timer if it is still running.
 * @param timerIndex the timer index to stop (0-3)
 */
- (CodelessTimerStopCommand*) stopTimer:(int)timerIndex;

/**
 * Sends the <code>AT+EVENT</code> command to activate or deactivate one of the predefined events.
 * <p> On success, an {@link CodelessLibEvent#EventStatus EventStatus} event is generated.
 * @param eventType     the event type (1: initialization, 2: connection, 3: disconnection, 4: wakeup)
 * @param status        <code>true</code> to activate the event, <code>false</code> to deactivate it
 */
- (CodelessEventConfigCommand*) setEventConfig:(int)eventType status:(BOOL)status;

/**
 * Sends the <code>AT+EVENT</code> command to get the activation status of the predefined events.
 * <p> On success, an {@link CodelessLibEvent#EventStatusTable EventStatusTable} event is generated.
 */
- (CodelessEventConfigCommand*) getEventConfigTable;

/**
 * Sends the <code>AT+HNDL</code> command to set the commands to be executed on one of the predefined events.
 * <p> On success, an {@link CodelessLibEvent#EventCommands EventCommands} event is generated.
 * @param eventType         the event type (1: connection, 2: disconnection, 3: wakeup)
 * @param commandString     the commands to be executed (semicolon separated)
 */
- (CodelessEventHandlerCommand*) setEventHandler:(int)eventType commandString:(NSString*)commandString;

/**
 * Sends the <code>AT+HNDL</code> command to get the commands to be executed on each of the predefined events.
 * <p> On success, an {@link CodelessLibEvent#EventCommandsTable EventCommandsTable} event is generated.
 */
- (CodelessEventHandlerCommand*) getEventHandlers;

/**
 * Sends the <code>AT+BAUD</code> command to get the UART baud rate.
 * <p> On success, a {@link CodelessLibEvent#BaudRate BaudRate} event is generated.
 */
- (CodelessBaudRateCommand*) getBaudRate;

/**
 * Sends the <code>AT+BAUD</code> command to set the UART baud rate.
 * <p> On success, a {@link CodelessLibEvent#BaudRate BaudRate} event is generated.
 * @param baudRate the UART baud rate
 */
- (CodelessBaudRateCommand*) setBaudRate:(int)baudRate;

/**
 * Sends the <code>AT+E</code> command to get the UART echo state.
 * <p> On success, a {@link CodelessLibEvent#UartEcho UartEcho} event is generated.
 */
- (CodelessUartEchoCommand*) getUartEcho;

/**
 * Sends the <code>AT+E</code> command to set the UART echo state.
 * <p> On success, a {@link CodelessLibEvent#UartEcho UartEcho} event is generated.
 * @param echo <code>true</code> for UART echo on, <code>false</code> for off
 */
- (CodelessUartEchoCommand*) setUartEcho:(BOOL)echo;

/**
 * Sends the <code>AT+HRTBT</code> command to get the heartbeat signal status.
 * <p> On success, a {@link CodelessLibEvent#Heartbeat Heartbeat} event is generated.
 */
- (CodelessHeartbeatCommand*) getHeartbeatStatus;

/**
 * Sends the <code>AT+HRTBT</code> command to enable or disable the heartbeat signal.
 * <p> On success, a {@link CodelessLibEvent#Heartbeat Heartbeat} event is generated.
 * @param enable <code>true</code> to enable the heartbeat signal, <code>false</code> to disable it
 */
- (CodelessHeartbeatCommand*) setHeartbeatStatus:(BOOL)enable;

/**
 * Sends the <code>AT+F</code> command to enable or disable error reporting.
 * @param enabled <code>true</code> to enable error reporting, <code>false</code> to disable it
 */
- (CodelessErrorReportingCommand*) setErrorReporting:(BOOL)enabled;

/// Sends the <code>AT+CURSOR</code> command to place a time cursor in a SmartSnippets power profiler plot.
- (CodelessCursorCommand*) timeCursor;

/// Sends the <code>AT+SLEEP</code> command to instruct the peer device controller to enter sleep mode.
- (CodelessDeviceSleepCommand*) sleep;

/// Sends the <code>AT+SLEEP</code> command to instruct the peer device controller to disable sleep mode.
- (CodelessDeviceSleepCommand*) awake;

/**
 * Sends the <code>AT+HOSTSLP</code> command to get the peer device host sleep configuration.
 * <p> On success, a {@link CodelessLibEvent#HostSleep HostSleep} event is generated.
 */
- (CodelessHostSleepCommand*) getHostSleepStatus;

/**
 * Sends the <code>AT+HOSTSLP</code> command to set the peer device host sleep configuration.
 * <p> On success, a {@link CodelessLibEvent#HostSleep HostSleep} event is generated.
 * @param hostSleepMode         the host sleep mode to use
 * @param wakeupByte            the byte value to use in order to wake up the host
 * @param wakeupRetryInterval   the interval between wakeup retries (ms)
 * @param wakeupRetryTimes      the number of wakeup retries
 */
- (CodelessHostSleepCommand*) setHostSleepStatus:(int)hostSleepMode wakeupByte:(int)wakeupByte wakeupRetryInterval:(int)wakeupRetryInterval wakeupRetryTimes:(int)wakeupRetryTimes;

/**
 * Sends the <code>AT+PWRLVL</code> command to get the peer device Bluetooth output power level.
 * <p> On success, a {@link CodelessLibEvent#PowerLevel PowerLevel} event is generated.
 */
- (CodelessPowerLevelConfigCommand*) getPowerLevel;

/**
 * Sends the <code>AT+PWRLVL</code> command to set the peer device Bluetooth output power level.
 * <p> On success, a {@link CodelessLibEvent#PowerLevel PowerLevel} event is generated.
 * @param powerLevel the Bluetooth output power level {@link CodelessProfile#CODELESS_COMMAND_OUTPUT_POWER_LEVEL index}
 */
- (CodelessPowerLevelConfigCommand*) setPowerLevel:(int)powerLevel;

/**
 * Sends the <code>AT+SEC</code> command to get the security mode configuration.
 * <p> On success, a {@link CodelessLibEvent#SecurityMode SecurityMode} event is generated.
 */
- (CodelessSecurityModeCommand*) getSecurityMode;

/**
 * Sends the <code>AT+SEC</code> command to set the security mode configuration.
 * <p> On success, a {@link CodelessLibEvent#SecurityMode SecurityMode} event is generated.
 * @param mode the security {@link CodelessProfile#CODELESS_COMMAND_SECURITY_MODE mode} to use
 */
- (CodelessSecurityModeCommand*) setSecurityMode:(int)mode;

/**
 * Sends the <code>AT+PIN</code> command to get the pin code for the pairing process.
 * <p> On success, a {@link CodelessLibEvent#PinCode PinCode} event is generated.
 */
- (CodelessPinCodeCommand*) getPinCode;

/**
 * Sends the <code>AT+PIN</code> command to set the pin code for the pairing process.
 * <p> On success, a {@link CodelessLibEvent#PinCode PinCode} event is generated.
 * @param code the pin code (six-digit)
 */
- (CodelessPinCodeCommand*) setPinCode:(int)code;

/**
 * Sends the <code>AT+FLOWCONTROL</code> command to get the UART hardware flow control configuration.
 * <p> On success, a {@link CodelessLibEvent#FlowControl FlowControl} event is generated.
 */
- (CodelessFlowControlCommand*) getFlowControl;

/**
 * Sends the <code>AT+FLOWCONTROL</code> command to set the UART hardware flow control configuration.
 * <p> On success, a {@link CodelessLibEvent#FlowControl FlowControl} event is generated.
 * @param enabled   <code>true</code> to enable UART RTS/CTS flow control, <code>false</code> to disable it
 * @param rts       {@link CodelessGPIO GPIO} that selects the pin for the RTS signal
 * @param cts       {@link CodelessGPIO GPIO} that selects the pin for the CTS signal
 */
- (CodelessFlowControlCommand*) setFlowControl:(BOOL)enabled rts:(CodelessGPIO*)rts cts:(CodelessGPIO*)cts;

/**
 * Sends the <code>AT+CLRBNDE</code> command to clear an entry from the bonding database.
 * <p> On success, a {@link CodelessLibEvent#BondingEntryClear BondingEntryClear} event is generated.
 * @param index the bonding entry to clear (1-5, 0xFF: all entries)
 */
- (CodelessBondingEntryClearCommand*) clearBondingDatabaseEntry:(int)index;

/**
 * Sends the <code>AT+CLRBNDE</code> command to clear the whole bonding database.
 * <p> On success, a {@link CodelessLibEvent#BondingEntryClear BondingEntryClear} event is generated.
 */
- (CodelessBondingEntryClearCommand*) clearBondingDatabase;

/**
 * Sends the <code>AT+CHGBNDP</code> command to get the persistence status of all entries in the bonding database.
 * <p> On success, a {@link CodelessLibEvent#BondingEntryPersistenceTableStatus BondingEntryPersistenceTableStatus} event is generated.
 */
- (CodelessBondingEntryStatusCommand*) getBondingDatabasePersistenceStatus;

/**
 * Sends the <code>AT+CHGBNDP</code> command to set the persistence status of an entry in the bonding database.
 * <p> On success, a {@link CodelessLibEvent#BondingEntryPersistenceStatusSet BondingEntryPersistenceStatusSet} event is generated.
 * @param index         the bonding entry to clear (1-5, 0xFF: all entries)
 * @param persistent    <code>true</code> to enable persistence, <code>false</code> to disable it
 */
- (CodelessBondingEntryStatusCommand*) setBondingEntryPersistenceStatus:(int)index persistent:(BOOL)persistent;

/**
 * Sends the <code>AT+IEBNDE</code> command to get a bonding entry configuration.
 * <p> On success, a {@link CodelessLibEvent#BondingEntry BondingEntry} event is generated.
 * @param index the bonding entry to get (1-5)
 */
- (CodelessBondingEntryTransferCommand*) getBondingDatabase:(int)index;

/**
 * Sends the <code>AT+IEBNDE</code> command to set a bonding entry configuration.
 * <p> On success, a {@link CodelessLibEvent#BondingEntry BondingEntry} event is generated.
 * @param index the bonding entry to set (1-5)
 * @param entry the bonding entry {@link CodelessBondingEntry configuration}
 */
- (CodelessBondingEntryTransferCommand*) setBondingDatabase:(int)index bondingEntry:(CodelessBondingEntry*)entry;

@end

NS_ASSUME_NONNULL_END
