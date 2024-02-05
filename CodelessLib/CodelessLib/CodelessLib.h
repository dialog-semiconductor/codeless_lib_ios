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

#import "CodelessBluetoothManager.h"
#import "CodelessCommands.h"
#import "CodelessLibConfig.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"
#import "CodelessManager.h"
#import "CodelessProfile.h"
#import "CodelessScript.h"
#import "CodelessUtil.h"
#import "command/CodelessAdcReadCommand.h"
#import "command/CodelessAdvertisingDataCommand.h"
#import "command/CodelessAdvertisingResponseCommand.h"
#import "command/CodelessAdvertisingStartCommand.h"
#import "command/CodelessAdvertisingStopCommand.h"
#import "command/CodelessBasicCommand.h"
#import "command/CodelessBatteryLevelCommand.h"
#import "command/CodelessBaudRateCommand.h"
#import "command/CodelessBinEscCommand.h"
#import "command/CodelessBinExitAckCommand.h"
#import "command/CodelessBinExitCommand.h"
#import "command/CodelessBinRequestAckCommand.h"
#import "command/CodelessBinRequestCommand.h"
#import "command/CodelessBinResumeCommand.h"
#import "command/CodelessBluetoothAddressCommand.h"
#import "command/CodelessBondingEntryClearCommand.h"
#import "command/CodelessBondingEntryStatusCommand.h"
#import "command/CodelessBondingEntryTransferCommand.h"
#import "command/CodelessBroadcasterRoleSetCommand.h"
#import "command/CodelessCentralRoleSetCommand.h"
#import "command/CodelessCmdGetCommand.h"
#import "command/CodelessCmdPlayCommand.h"
#import "command/CodelessCmdStoreCommand.h"
#import "command/CodelessCommand.h"
#import "command/CodelessConnectionParametersCommand.h"
#import "command/CodelessCursorCommand.h"
#import "command/CodelessCustomCommand.h"
#import "command/CodelessDataLengthEnableCommand.h"
#import "command/CodelessDeviceInformationCommand.h"
#import "command/CodelessDeviceSleepCommand.h"
#import "command/CodelessErrorReportingCommand.h"
#import "command/CodelessEventConfigCommand.h"
#import "command/CodelessEventHandlerCommand.h"
#import "command/CodelessFlowControlCommand.h"
#import "command/CodelessGapConnectCommand.h"
#import "command/CodelessGapDisconnectCommand.h"
#import "command/CodelessGapScanCommand.h"
#import "command/CodelessGapStatusCommand.h"
#import "command/CodelessHeartbeatCommand.h"
#import "command/CodelessHostSleepCommand.h"
#import "command/CodelessI2cConfigCommand.h"
#import "command/CodelessI2cReadCommand.h"
#import "command/CodelessI2cScanCommand.h"
#import "command/CodelessI2cWriteCommand.h"
#import "command/CodelessIoConfigCommand.h"
#import "command/CodelessIoStatusCommand.h"
#import "command/CodelessMaxMtuCommand.h"
#import "command/CodelessMemStoreCommand.h"
#import "command/CodelessPeripheralRoleSetCommand.h"
#import "command/CodelessPinCodeCommand.h"
#import "command/CodelessPowerLevelConfigCommand.h"
#import "command/CodelessPulseGenerationCommand.h"
#import "command/CodelessRandomNumberCommand.h"
#import "command/CodelessResetCommand.h"
#import "command/CodelessResetIoConfigCommand.h"
#import "command/CodelessRssiCommand.h"
#import "command/CodelessSecurityModeCommand.h"
#import "command/CodelessSpiConfigCommand.h"
#import "command/CodelessSpiReadCommand.h"
#import "command/CodelessSpiTransferCommand.h"
#import "command/CodelessSpiWriteCommand.h"
#import "command/CodelessTimerStartCommand.h"
#import "command/CodelessTimerStopCommand.h"
#import "command/CodelessUartEchoCommand.h"
#import "command/CodelessUartPrintCommand.h"
#import "dsps/DspsFileSend.h"
#import "dsps/DspsFileReceive.h"
#import "dsps/DspsPeriodicSend.h"

/**
 * Main import file of the CodeLess library.
 * <p> Imports all library header files.
 */
@interface CodelessLib : NSObject

@end
