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
#import "CodelessManager.h"
#import "CodelessBluetoothManager.h"
#import "CodelessProfile.h"
#import "CodelessLibEvent.h"
#import "CodelessUtil.h"
#import "CodelessLibConfig.h"
#import "CodelessLibLog.h"
#import "CodelessCommands.h"
#import "CodelessBinRequestCommand.h"
#import "CodelessBinRequestAckCommand.h"
#import "CodelessBinExitCommand.h"
#import "CodelessLogFile.h"
#import "DspsRxLogFile.h"
#import "CodelessCustomCommand.h"
#import "DspsFileSend.h"
#import "DspsFileReceive.h"
#import "DspsPeriodicSend.h"
#import "CodelessScript.h"


#define CodelessLogPrefix(TAG, fmt, ...) CodelessLog(TAG, "%@" fmt, self.logPrefix, ##__VA_ARGS__)
#define CodelessLogPrefixOpt(enabled, TAG, fmt, ...) CodelessLogOpt(enabled, TAG, "%@" fmt, self.logPrefix, ##__VA_ARGS__)


/// GATT operation wrapper class, used for the GATT operation queue implementation.
@interface CodelessManager_GattOperation : NSObject

/// GATT operation type enumeration.
enum {
    GattOperationReadCharacteristic,
    GattOperationWriteCharacteristic,
    GattOperationWriteCommand,
};

/// Returns the operation type.
@property int type;
/// Returns the associated characteristic.
@property CBCharacteristic* characteristic;
/// Returns the value to be used by the operation.
@property NSData* value;

/// Read characteristic operation.
- (instancetype) initWithCharacteristic:(CBCharacteristic*)characteristic;
/// Write characteristic operation.
- (instancetype) initWithCharacteristic:(CBCharacteristic*)characteristic value:(NSData*)value;
/// Write with response or write command operation.
- (instancetype) initWithCharacteristic:(CBCharacteristic*)characteristic value:(NSData*)value response:(BOOL)response;

/// Called just before the operation is executed.
- (void) onExecute;
/**
 * Checks if the operation is low priority.
 * <p> High priority operations are put before low priority ones in the queue.
 */
- (BOOL) lowPriority;

@end


/**
 * Base class for enqueued DSPS data send operations.
 * <p> Executes a write command operation on the DSPS Server RX characteristic.
 */
@interface CodelessManager_DspsGattOperation : CodelessManager_GattOperation

@property (weak) CodelessManager* manager;

- (instancetype) initWithManager:(CodelessManager*)manager data:(NSData*)data;

@end


/**
 * Enqueued DSPS chunk send operation (not part of a file or periodic send operation).
 *
 * These are operations with high priority. If {@link CodelessLibConfig#GATT_QUEUE_PRIORITY} is enabled and the user
 * tries to send some data while a file transfer is in progress, the data will be added at the front of the queue.
 */
@interface CodelessManager_DspsChunkOperation : CodelessManager_DspsGattOperation

@end


/**
 * Enqueued DSPS chunk send operation, part of a periodic send operation.
 * <p> These are operations with low priority.
 */
@interface CodelessManager_DspsPeriodicChunkOperation : CodelessManager_DspsGattOperation

@property DspsPeriodicSend* operation;
@property int count;
@property int chunk;
@property int totalChunks;

- (instancetype) initWithOperation:(DspsPeriodicSend*)operation count:(int)count data:(NSData*)data chunk:(int)chunk totalChunks:(int)totalChunks;

@end


/**
 * Enqueued DSPS chunk send operation, part of a file send operation.
 * <p> These are operations with low priority.
 */
@interface CodelessManager_DspsFileChunkOperation : CodelessManager_DspsGattOperation

@property DspsFileSend* operation;
@property int chunk;

- (instancetype) initWithOperation:(DspsFileSend*)operation data:(NSData*)data chunk:(int)chunk;

@end


@interface CodelessManager ()

@property CodelessBluetoothManager* bluetoothManager;
@property CBPeripheral* device;
@property int state;
@property int mtu;
@property NSMutableArray<CodelessManager_GattOperation*>* gattQueue;
@property CodelessManager_GattOperation* gattOperationPending;
@property BOOL commandMode;
@property BOOL binaryRequestPending;
@property BOOL binaryExitRequestPending;

// Codeless
@property CodelessCommands* commandFactory;
@property NSMutableArray<CodelessCommand*>* commandQueue;
@property CodelessCommand* commandPending;
@property CodelessCommand* commandInbound;
@property int inboundPending;
@property int outboundResponseLines;
@property NSMutableArray<NSString*>* parsePending;
@property CodelessLogFile* codelessLogFile;
@property NSMutableArray<CodelessScript*>* scripts;

// DSPS
@property BOOL dspsTxFlowOn;
@property NSMutableArray<CodelessManager_GattOperation*>* dspsPending;
@property NSMutableArray<DspsPeriodicSend*>* dspsPeriodic;
@property NSMutableArray<DspsFileSend*>* dspsFiles;
@property DspsFileReceive* dspsFileReceive;
@property DspsRxLogFile* dspsRxLogFile;
@property NSTimeInterval dspsLastInterval;
@property int dspsRxBytesInterval;
@property int dspsRxSpeed;

// Service database
@property BOOL servicesDiscovered;
@property BOOL codelessSupport;
@property BOOL dspsSupport;
@property CBService* codelessService;
@property CBCharacteristic* codelessInbound;
@property CBCharacteristic* codelessOutbound;
@property CBCharacteristic* codelessFlowControl;
@property CBService* dspsService;
@property CBCharacteristic* dspsServerTx;
@property CBCharacteristic* dspsServerRx;
@property CBCharacteristic* dspsFlowControl;
@property CBService* deviceInfoService;
@property NSMutableArray<CBService*>* pendingDiscoverCharacteristics;
@property NSMutableArray<CBCharacteristic*>* pendingEnableNotifications;

@property NSString* logPrefix;

@end

@implementation CodelessManager

static NSString* const TAG = @"CodelessManager";
+ (NSString*) TAG {
    return TAG;
}

+ (int) SPEED_INVALID {
    return DSPS_SPEED_INVALID;
}

- (instancetype) init {
    self = [super init];
    if (!self)
        return nil;
    self.state = CODELESS_STATE_DISCONNECTED;
    self.mtu = CODELESS_MTU_DEFAULT;
    self.gattQueue = [NSMutableArray array];
    self.commandQueue = [NSMutableArray array];
    self.parsePending = [NSMutableArray array];
    self.scripts = [NSMutableArray array];
    self.dspsChunkSize = CodelessLibConfig.DEFAULT_DSPS_CHUNK_SIZE;
    _dspsRxFlowOn = CodelessLibConfig.DEFAULT_DSPS_RX_FLOW_CONTROL;
    self.dspsTxFlowOn = CodelessLibConfig.DEFAULT_DSPS_TX_FLOW_CONTROL;
    self.dspsPending = [NSMutableArray array];
    self.dspsPeriodic = [NSMutableArray array];
    self.dspsFiles = [NSMutableArray array];
    self.dspsRxSpeed = CodelessManager.SPEED_INVALID;
    return self;
}

- (instancetype) initWithBluetoothManager:(CodelessBluetoothManager*)manager device:(CBPeripheral*)device {
    self = [self init];
    if (!self)
        return nil;
    self.bluetoothManager = manager;
    self.device = device;
    self.commandFactory = [[CodelessCommands alloc] initWithManager:self];
    self.logPrefix = [NSString stringWithFormat:@"[%@] ", device.identifier.UUIDString];
    device.delegate = self;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onConnection:) name:CodelessLibEvent.DeviceConnected object:self.bluetoothManager];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onDisconnection:) name:CodelessLibEvent.DeviceDisconnected object:self.bluetoothManager];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onConnectionFailed:) name:CodelessLibEvent.ConnectionFailed object:self.bluetoothManager];
    if (CodelessLibConfig.BLUETOOTH_STATE_MONITOR)
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onBluetoothState:) name:CodelessLibEvent.BluetoothState object:self.bluetoothManager];
    return self;
}

- (void) dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void) sendEvent:(NSString*)event object:(CodelessEvent*)object {
    [NSNotificationCenter.defaultCenter postNotificationName:event object:self userInfo:@{ @"event" : object }];
}

- (void) connect {
    CodelessLogPrefix(TAG, "Connect");
    if (self.state != CODELESS_STATE_DISCONNECTED)
        return;
    self.state = CODELESS_STATE_CONNECTING;
    [self sendEvent:CodelessLibEvent.Connection object:[[CodelessConnectionEvent alloc] initWithManager:self]];
    [self.bluetoothManager connectToPeripheral:self.device];
}

- (void) disconnect {
    CodelessLogPrefix(TAG, "Disconnect");
    [self.bluetoothManager disconnectPeripheral:self.device];
}

- (BOOL) isConnected {
    return self.state >= CODELESS_STATE_CONNECTED;
}

- (BOOL) isConnecting {
    return self.state == CODELESS_STATE_CONNECTING;
}

- (BOOL) isDisconnected {
    return self.state == CODELESS_STATE_DISCONNECTED;
}

- (BOOL) isReady {
    return self.state == CODELESS_STATE_READY;
}

/**
 * Checks if the device is ready.
 * <p> If not, a {@link CodelessLibEvent#Error Error} event is generated.
 */
- (BOOL) checkReady {
    if (!self.isReady) {
        CodelessLogPrefix(TAG, "Device not ready. Operation not allowed.");
        [self sendEvent:CodelessLibEvent.Error object:[[CodelessErrorEvent alloc] initWithManager:self error:CODELESS_ERROR_NOT_READY]];
        return false;
    } else {
        return true;
    }
}

- (BOOL) hasDeviceInfo:(CBUUID*)uuid {
    return self.deviceInfoService && (!uuid || [self findCharacteristicWithUUID:uuid forService:self.deviceInfoService]);
}

- (void) readDeviceInfo:(CBUUID*)uuid {
    if (![self hasDeviceInfo:uuid]) {
        CodelessLogPrefix(TAG, "Device information not available: %@", uuid);
        return;
    }
    [self readCharacteristic:[self findCharacteristicWithUUID:uuid forService:self.deviceInfoService]];
}

/**
 * Called when a device information service characteristic is read successfully.
 * <p> A {@link CodelessLibEvent#DeviceInfo DeviceInfo} event is generated.
 */
- (void) onDeviceInfoRead:(CBCharacteristic*)characteristic {
    CBUUID* uuid = characteristic.UUID;
    NSData* value = characteristic.value;
    NSString* info = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
    if (!info)
        info = @"";
    CodelessLogPrefix(TAG, "Device information [%@]: %@", uuid, info);
    [self sendEvent:CodelessLibEvent.DeviceInfo object:[[CodelessDeviceInfoEvent alloc] initWithManager:self uuid:uuid value:value info:info]];
}

- (void) getRssi {
    if (self.isConnected)
        [self.device readRSSI];
}

/**
 * Called after the service discovery is complete and the required notifications are enabled.
 * <p> A {@link CodelessLibEvent#Ready Ready} event is generated.
 */
- (void) onDeviceReady {
    CodelessLogPrefix(TAG, "Device ready");
    self.state = CODELESS_STATE_READY;
    if (self.codelessSupport) {
        self.commandMode = CodelessLibConfig.START_IN_COMMAND_MODE;
    }
    if (self.dspsSupport) {
        if (CodelessLibConfig.SET_FLOW_CONTROL_ON_CONNECTION)
            self.dspsRxFlowOn = _dspsRxFlowOn;
        if (CodelessLibConfig.DSPS_STATS) {
            if (!self.commandMode) {
                self.dspsRxBytesInterval = 0;
                self.dspsLastInterval = [NSDate date].timeIntervalSince1970;
                [self performSelector:@selector(dspsUpdateStats) withObject:nil afterDelay:CodelessLibConfig.DSPS_STATS_INTERVAL / 1000.];
            }
        }
    }
    [self sendEvent:CodelessLibEvent.Ready object:[[CodelessReadyEvent alloc] initWithManager:self]];
}

- (BOOL) binaryMode {
    return !self.commandMode;
}

/**
 * Checks if a binary operation can be performed in the current mode.
 * @param outbound <code>true</code> for outgoing data, <code>false</code> for incoming data
 */
- (BOOL) checkBinaryMode:(BOOL)outbound {
    if (outbound) {
        if (!self.dspsSupport) {
            CodelessLogPrefix(TAG, "DSPS not supported");
            [self sendEvent:CodelessLibEvent.Error object:[[CodelessErrorEvent alloc] initWithManager:self error:CODELESS_ERROR_OPERATION_NOT_ALLOWED]];
            return false;
        }
        if (!CodelessLibConfig.ALLOW_OUTBOUND_BINARY_IN_COMMAND_MODE) {
            if (self.commandMode) {
                CodelessLogPrefix(TAG, "Binary data not allowed in command mode");
                [self sendEvent:CodelessLibEvent.Error object:[[CodelessErrorEvent alloc] initWithManager:self error:CODELESS_ERROR_OPERATION_NOT_ALLOWED]];
                return false;
            }
        }
    } else {
        if (!CodelessLibConfig.ALLOW_INBOUND_BINARY_IN_COMMAND_MODE) {
            if (self.commandMode) {
                CodelessLogPrefix(TAG, "Received binary data in command mode");
                return false;
            }
        }
    }
    return true;
}

/**
 * Checks if a command operation can be performed in the current mode.
 * <p> {@link CodelessProfile#modeCommands Mode commands} are allowed in binary mode.
 * @param outbound  <code>true</code> for outgoing data, <code>false</code> for incoming data
 * @param command   the corresponding command, if available
 */
- (BOOL) checkCommandMode:(BOOL)outbound command:(CodelessCommand*)command {
    if (outbound) {
        if (!self.codelessSupport) {
            CodelessLogPrefix(TAG, "Codeless not supported");
            [self sendEvent:CodelessLibEvent.Error object:[[CodelessErrorEvent alloc] initWithManager:self error:CODELESS_ERROR_OPERATION_NOT_ALLOWED]];
            return false;
        }
        if (!CodelessLibConfig.ALLOW_OUTBOUND_COMMAND_IN_BINARY_MODE) {
            if (!self.commandMode && (!command || ![CodelessProfile isModeCommand:command])) {
                CodelessLogPrefix(TAG, "Commands not allowed in binary mode");
                [self sendEvent:CodelessLibEvent.Error object:[[CodelessErrorEvent alloc] initWithManager:self error:CODELESS_ERROR_OPERATION_NOT_ALLOWED]];
                return false;
            }
        }
    } else {
        if (!CodelessLibConfig.ALLOW_INBOUND_COMMAND_IN_BINARY_MODE) {
            if (!self.commandMode && (!command || ![CodelessProfile isModeCommand:command])) {
                CodelessLogPrefix(TAG, "Received command in binary mode");
                return false;
            }
        }
    }
    return true;
}

- (void) setMode:(BOOL)command {
    if (self.commandMode == command)
        return;
    CodelessLogPrefix(TAG, "Change to %@ mode", command ? @"command": @"binary");
    if (!command) {
        if (CodelessLibConfig.MODE_CHANGE_SEND_BINARY_REQUEST)
            [self.commandFactory requestBinaryMode];
        else
            [self.commandFactory sendBinaryRequestAck];
    } else {
        [self.commandFactory sendBinaryExit];
    }
}

- (void) acceptBinaryModeRequest {
    if (!self.binaryRequestPending) {
        CodelessLogPrefix(TAG, "No binary mode request pending");
        return;
    }
    self.binaryRequestPending = false;
    CodelessLogPrefix(TAG, "Binary mode request accepted");
    [self.commandFactory sendBinaryRequestAck];
}

- (void) acceptBinaryModeExitRequest {
    if (!self.binaryExitRequestPending) {
        CodelessLogPrefix(TAG, "No binary mode exit request pending");
        return;
    }
    self.binaryExitRequestPending = false;
    CodelessLogPrefix(TAG, "Binary mode exit request accepted");
    [self.commandFactory sendBinaryExitAck];
}

/// Actions performed when switching from command to binary mode.
- (void) enterBinaryMode {
    if (!self.commandMode)
        return;
    CodelessLogPrefix(TAG, "Enter binary mode");
    self.commandMode = false;
    [self sendEvent:CodelessLibEvent.Mode object:[[CodelessModeEvent alloc] initWithManager:self command:self.commandMode]];

    // Remove pending commands
    for (int i = 0; i < self.commandQueue.count; ++i) {
        if (![CodelessProfile isModeCommand:self.commandQueue[i]])
            [self.commandQueue removeObjectAtIndex:i--];
    }

    if (CodelessLibConfig.CODELESS_LOG)
        [self.codelessLogFile log:@"=========== BINARY MODE =========="];

    if (CodelessLibConfig.DSPS_STATS) {
        self.dspsRxBytesInterval = 0;
        self.dspsLastInterval = [NSDate date].timeIntervalSince1970;
        [self performSelector:@selector(dspsUpdateStats) withObject:nil afterDelay:CodelessLibConfig.DSPS_STATS_INTERVAL / 1000.];
    }
    [self resumeDspsOperations];
}

/// Actions performed when switching from binary to command mode.
- (void) exitBinaryMode {
    if (self.commandMode)
        return;
    CodelessLogPrefix(TAG, "Exit binary mode");
    self.commandMode = true;
    [self sendEvent:CodelessLibEvent.Mode object:[[CodelessModeEvent alloc] initWithManager:self command:self.commandMode]];

    if (CodelessLibConfig.DSPS_STATS) {
        [NSTimer cancelPreviousPerformRequestsWithTarget:self selector:@selector(dspsUpdateStats) object:nil];
    }
    [self pauseDspsOperations:false];

    if (CodelessLibConfig.CODELESS_LOG)
        [self.codelessLogFile log:@"=========== COMMAND MODE =========="];
}

- (void) onBinRequestSent {
}

- (void) onBinRequestReceived {
    if (!self.commandMode) {
        CodelessLogPrefix(TAG, "Already in binary mode");
        [self.commandFactory sendBinaryRequestAck];
        return;
    }
    if (CodelessLibConfig.HOST_BINARY_REQUEST) {
        CodelessLogPrefix(TAG, "Pass binary mode request to host");
        self.binaryRequestPending = true;
        [self sendEvent:CodelessLibEvent.BinaryModeRequest object:[[CodelessBinaryModeRequestEvent alloc] initWithManager:self]];
    } else {
        [self.commandFactory sendBinaryRequestAck];
    }
}

- (void) onBinAckSent {
    [self enterBinaryMode];
}

- (void) onBinAckReceived {
    [self enterBinaryMode];
}

- (void) onBinExitSent {
    [self exitBinaryMode];
}

- (void) onBinExitReceived {
    if (self.commandMode) {
        CodelessLogPrefix(TAG, "Already in command mode");
        [self.commandFactory sendBinaryExitAck];
        return;
    }
    [self exitBinaryMode];
    [self.commandFactory sendBinaryExitAck];
}

- (void) onBinExitAckSent {
}

- (void) onBinExitAckReceived {
}

- (BOOL) isCommandPending {
    return self.commandPending != nil;
}

- (BOOL) isInboundPending {
    return self.inboundPending > 0;
}

- (void) sendTextCommand:(NSString*)line {
    if ([line stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet].length)
        [self sendCommand:[self parseTextCommand:line]];
}

- (void) sendCommandScript:(NSArray<NSString*>*)script {
    NSMutableArray<CodelessCommand*>* commands = [NSMutableArray arrayWithCapacity:script.count];
    for (NSString* line in script) {
        if ([line stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet].length)
            [commands addObject:[self parseTextCommand:line]];
    }
    [self sendCommands:commands];
}

- (void) addScript:(CodelessScript*)script {
    [self.scripts addObject:script];
}

- (void) removeScript:(CodelessScript*)script {
    [self.scripts removeObject:script];
}

- (CodelessCommand*) parseTextCommand:(NSString*)line {
    line = [line stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    if (CodelessLibConfig.AUTO_ADD_PREFIX && ![CodelessProfile hasPrefix:line])
        line = [CodelessProfile.PREFIX stringByAppendingString:line];

    CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Text command: %@", line);

    if (CodelessLibConfig.CODELESS_LOG)
        [self.codelessLogFile logText:line];

    CodelessCommand* command;
    NSString* id = [CodelessProfile getCommand:line];
    if (!id) {
        command = [[CodelessCustomCommand alloc] initWithManager:self command:line parse:true];
    } else {
        Class commandClass = CodelessProfile.commandMap[id];
        if (!commandClass) {
            command = [[CodelessCustomCommand alloc] initWithManager:self command:line parse:true];
        } else {
            NSString* prefix = [CodelessProfile getPrefix:line];
            line = [CodelessProfile removeCommandPrefix:line];
            command = [CodelessProfile createCommand:self commandClass:commandClass command:line];
            command.prefix = prefix;
        }
    }

    CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Text command identified: %@%@", command, command.isValid ? @"" : @" (invalid)");
    return command;
}

- (void) sendCommand:(CodelessCommand*)command {
    if (![self checkReady] || ![self checkCommandMode:true command:command])
        return;
    [self enqueueCommand:command];
}

- (void) sendCommands:(NSArray<CodelessCommand*>*)commands {
    if (![self checkReady] || ![self checkCommandMode:true command:nil])
        return;
    [self enqueueCommands:commands];
}

/**
 * Enqueues a command to be sent.
 * @param command the command to send
 */
- (void) enqueueCommand:(CodelessCommand*)command {
    if (self.commandPending || self.commandInbound || self.inboundPending > 0) {
        [self.commandQueue addObject:command];
    } else {
        self.commandPending = command;
        [self executeCommand:command];
    }
}

/**
 * Enqueues a series of commands to be sent.
 * @param commands the commands to send
 */
- (void) enqueueCommands:(NSArray<CodelessCommand*>*)commands {
    [self.commandQueue addObjectsFromArray:commands];
    if (!self.commandPending) {
        [self dequeueCommand];
    }
}

/// Dequeues and sends the next command from the command queue.
- (void) dequeueCommand {
    if (self.commandQueue.count == 0 || self.commandInbound || self.inboundPending > 0)
        return;
    self.commandPending = self.commandQueue[0];
    [self.commandQueue removeObjectAtIndex:0];
    [self executeCommand:self.commandPending];
}

/**
 * Actions performed when the pending outgoing command is complete.
 * @param dequeue <code>true</code> to dequeue and send the next command
 */
- (void) commandComplete:(BOOL)dequeue {
    CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Command complete: %@", self.commandPending);
    [self.parsePending removeAllObjects];
    self.commandPending = nil;
    if (dequeue)
        [self dequeueCommand];
}

/// Actions performed when the pending incoming command is complete.
- (void) inboundCommandComplete {
    CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Inbound command complete: %@", self.commandInbound);
    if (CodelessLibConfig.SINGLE_WRITE_RESPONSE)
        [self.parsePending removeAllObjects];
    else
        self.outboundResponseLines = 0;
    self.commandInbound = nil;
    [self dequeueCommand];
}

/// Sends a command to the peer device.
- (void) executeCommand:(CodelessCommand*)command {
    CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Send codeless command: %@", command);
    if (![self checkReady]) {
        [command setComplete];
        [self commandComplete:true];
        return;
    }

    if (!command.parsed)
        [command packCommand];
    NSString* text = command.command;
    if (command.commandID != CODELESS_COMMAND_ID_CUSTOM) {
        NSString* prefix = ![CodelessProfile isModeCommand:command] ? CodelessProfile.PREFIX_REMOTE : CodelessProfile.PREFIX_LOCAL;
        text = [prefix stringByAppendingString:[CodelessProfile removeCommandPrefix:text]];
    } else if (CodelessLibConfig.DISALLOW_INVALID_PREFIX && ![CodelessProfile hasPrefix:text]) {
        CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Invalid prefix: %@", text);
        [self sendEvent:CodelessLibEvent.Error object:[[CodelessErrorEvent alloc] initWithManager:self error:CODELESS_ERROR_INVALID_PREFIX]];
        [command setComplete];
        [self commandComplete:true];
        return;
    }

    if (CodelessLibConfig.DISALLOW_INVALID_COMMAND && !command.parsed && !command.isValid) {
        CodelessLogPrefix(TAG, "Invalid command: %@", text);
        [self sendEvent:CodelessLibEvent.Error object:[[CodelessErrorEvent alloc] initWithManager:self error:CODELESS_ERROR_INVALID_COMMAND]];
        [command setComplete];
        [self commandComplete:true];
        return;
    }

    if (CodelessLibConfig.DISALLOW_INVALID_PARSED_COMMAND && command.parsed && !command.isValid) {
        CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Invalid command: %@", text);
        [self sendEvent:CodelessLibEvent.Error object:[[CodelessErrorEvent alloc] initWithManager:self error:CODELESS_ERROR_INVALID_COMMAND]];
        [command setComplete];
        [self commandComplete:true];
        return;
    }

    CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Codeless command text: %@", text);
    [self sendText:text type:CodelessLineOutboundCommand];
}

- (void) completePendingCommand:(CodelessCommand*)command {
    if (self.commandPending != command) {
        CodelessLogPrefix(TAG, "Not current pending command: %@", command);
        return;
    }
    [self.commandPending setComplete];
    [self commandComplete:true];
}

/**
 * CodeLess communication processing.
 * @param line the communication text
 * @param type the communication type
 */
- (void) processCodelessLine:(NSString*)line type:(int)type {
    CodelessLine* codelessLine = [[CodelessLine alloc] initWithText:line type:type];
    if (CodelessLibConfig.CODELESS_LOG)
        [self.codelessLogFile logLine:codelessLine];
    if (CodelessLibConfig.LINE_EVENTS)
        [self sendEvent:CodelessLibEvent.Line object:[[CodelessLineEvent alloc] initWithManager:self line:codelessLine]];
}

- (void) sendSuccess {
    if (!self.commandInbound) {
        CodelessLogPrefix(TAG, "No inbound command pending");
        return;
    }
    CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Send success: %@", self.commandInbound);
    if (CodelessLibConfig.SINGLE_WRITE_RESPONSE) {
        [self sendText:[self createSingleWriteResponse:true message:nil] type:CodelessLineOutboundResponse];
    } else {
        [self sendText:!CodelessLibConfig.EMPTY_LINE_BEFORE_OK || self.outboundResponseLines > 0 ? CodelessProfile.OK : [@"\n" stringByAppendingString:CodelessProfile.OK] type:CodelessLineOutboundOK];
    }
    if (self.commandInbound.complete)
        [self inboundCommandComplete];
}

- (void) sendSuccess:(NSString*)response {
    if (!self.commandInbound) {
        CodelessLogPrefix(TAG, "No inbound command pending");
        return;
    }
    if (CodelessLibConfig.SINGLE_WRITE_RESPONSE) {
        if (CodelessLibLog.CODELESS) {
            CodelessLogPrefix(TAG, "Send response: %@ %@", self.commandInbound, response);
            CodelessLogPrefix(TAG, "Send success: %@", self.commandInbound);
        }
        [self sendText:[[response stringByAppendingString:@"\n"] stringByAppendingString:CodelessProfile.OK] type:CodelessLineOutboundResponse];
        if (self.commandInbound.complete)
            [self inboundCommandComplete];
    } else {
        [self sendResponse:response];
        [self sendSuccess];
    }
}

- (void) sendError:(NSString*)error {
    if (!self.commandInbound) {
        CodelessLogPrefix(TAG, "No inbound command pending");
        return;
    }
    CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Send error: %@ %@", self.commandInbound, error);
    if (CodelessLibConfig.SINGLE_WRITE_RESPONSE) {
        [self sendText:[self createSingleWriteResponse:false message:error]  type:CodelessLineOutboundError];
    } else {
        [self sendText:!CodelessLibConfig.EMPTY_LINE_BEFORE_ERROR || self.outboundResponseLines > 0 ? error : [@"\n" stringByAppendingString:error] type:CodelessLineOutboundError];
    }
    if (self.commandInbound.complete)
        [self inboundCommandComplete];
}

- (void) sendResponse:(NSString*)response {
    if (!self.commandInbound) {
        CodelessLogPrefix(TAG, "No inbound command pending");
        return;
    }
    CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Send response: %@ %@", self.commandInbound, response);
    if (CodelessLibConfig.SINGLE_WRITE_RESPONSE) {
        [self.parsePending addObject:response];
    } else {
        [self sendText:response type:CodelessLineOutboundResponse];
    }
}

- (void) completeInboundCommand:(CodelessCommand*)command {
    if (self.commandInbound != command) {
        CodelessLogPrefix(TAG, "Not current inbound command: %@", command);
        return;
    }
    [self.commandInbound setComplete];
    [self inboundCommandComplete];
}

/**
 * Sends an error message to the peer device, if the parsing of the incoming command failed.
 * @param error the error message
 */
- (void) sendParseError:(NSString*)error {
    CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Send error: %@", error);
    error = [CodelessProfile.ERROR_PREFIX stringByAppendingString:error];
    if (CodelessLibConfig.SINGLE_WRITE_RESPONSE) {
        [self sendText:[[error stringByAppendingString:@"\n"] stringByAppendingString:CodelessProfile.ERROR] type:CodelessLineOutboundError];
    } else {
        [self sendText:error type:CodelessLineOutboundError];
        [self sendText:CodelessProfile.ERROR type:CodelessLineOutboundError];
        self.outboundResponseLines = 0;
    }
}

/**
 * Creates the combined response text for a single write operation.
 * <p> Used if {@link CodelessLibConfig#SINGLE_WRITE_RESPONSE} is enabled.
 **/
- (NSString*) createSingleWriteResponse:(BOOL)success message:(NSString*)message {
    NSMutableString* text = [NSMutableString string];
    for (NSString* line in self.parsePending) {
        [text appendString:line];
        [text appendString:@"\n"];
    }
    [self.parsePending removeAllObjects];
    if (message) {
        [text appendString:message];
        [text appendString:@"\n"];
    }
    if (success) {
        if (CodelessLibConfig.EMPTY_LINE_BEFORE_OK && text.length == 0)
            [text appendString:@"\n"];
        [text appendString:CodelessProfile.OK];
    } else {
        if (CodelessLibConfig.EMPTY_LINE_BEFORE_ERROR && text.length == 0)
            [text appendString:@"\n"];
        [text appendString:CodelessProfile.ERROR];
    }
    return [NSString stringWithString:text];
}

/// Sends the specified text to the peer device, by writing to the CodeLess Inbound characteristic.
- (void) sendText:(NSString*)text type:(int)type {
    if (CodelessLibConfig.CODELESS_LOG || CodelessLibConfig.LINE_EVENTS) {
        for (NSString* line in [text componentsSeparatedByString:@"\n"]) {
            int lineType = type;
            if (line.length == 0)
                lineType = CodelessLineOutboundEmpty;
            else if ([CodelessProfile isSuccess:line])
                lineType = CodelessLineOutboundOK;
            [self processCodelessLine:line type:lineType];
        }
    }

    if (!CodelessLibConfig.SINGLE_WRITE_RESPONSE && type != CodelessLineOutboundCommand)
        self.outboundResponseLines++;

    if (![text hasSuffix:@"\n"] && CodelessLibConfig.APPEND_END_OF_LINE && (CodelessLibConfig.END_OF_LINE_AFTER_COMMAND || type != CodelessLineOutboundCommand))
        text = [text stringByAppendingString:@"\n"];
    if (![CodelessLibConfig.END_OF_LINE isEqualToString:@"\n"])
        text = [text stringByReplacingOccurrencesOfString:@"\n" withString:CodelessLibConfig.END_OF_LINE];

    NSData* data = [text dataUsingEncoding:CodelessLibConfig.CHARSET];
    if (CodelessLibConfig.TRAILING_ZERO || !CodelessLibConfig.APPEND_END_OF_LINE || type == CodelessLineOutboundCommand && !CodelessLibConfig.END_OF_LINE_AFTER_COMMAND) {
        uint8_t zero = 0;
        NSMutableData* appendZero = data.mutableCopy;
        [appendZero appendBytes:&zero length:1];
        data = [NSData dataWithData:appendZero];
    }
    [self writeCharacteristic:self.codelessInbound value:data];
}

/// Parses the text that was received from the peer device as response to the pending outgoing command.
- (void) parseCommandResponse:(NSString*)line {
    if (line.length == 0) {
        if (self.parsePending.count == 0) {
            if (CodelessLibConfig.CODELESS_LOG || CodelessLibConfig.LINE_EVENTS)
                [self processCodelessLine:line type:CodelessLineInboundEmpty];
        } else {
            [self.parsePending addObject:line];
        }
        return;
    }
    if ([CodelessProfile isSuccess:line]) {
        CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Received OK");
        for (NSString* response in self.parsePending) {
            if (response.length == 0) {
                if (CodelessLibConfig.CODELESS_LOG || CodelessLibConfig.LINE_EVENTS)
                    [self processCodelessLine:response type:CodelessLineInboundEmpty];
                continue;
            }
            if (CodelessLibConfig.CODELESS_LOG || CodelessLibConfig.LINE_EVENTS)
                [self processCodelessLine:response type:CodelessLineInboundResponse];
            [self.commandPending parseResponse:response];
        }
        [self.parsePending removeAllObjects];
        if (CodelessLibConfig.CODELESS_LOG || CodelessLibConfig.LINE_EVENTS)
            [self processCodelessLine:line type:CodelessLineInboundOK];
        [self.commandPending onSuccess];
    } else if ([CodelessProfile isError:line]) {
        CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Received ERROR");
        NSMutableString* error = [NSMutableString string];
        for (NSString* msg in self.parsePending) {
            if (msg.length == 0) {
                if (CodelessLibConfig.CODELESS_LOG || CodelessLibConfig.LINE_EVENTS)
                    [self processCodelessLine:msg type:CodelessLineInboundEmpty];
                continue;
            }
            if (CodelessLibConfig.CODELESS_LOG || CodelessLibConfig.LINE_EVENTS)
                [self processCodelessLine:msg type:CodelessLineInboundError];
            if ([CodelessProfile isPeerInvalidCommand:msg])
                [self.commandPending setPeerInvalid];
            if ([CodelessProfile isErrorCodeMessage:msg]) {
                CodelessErrorCodeMessage* ec = [CodelessProfile parseErrorCodeMessage:msg];
                [self.commandPending setErrorCode:ec.code message:ec.message];
            }
            if (error.length > 0)
                [error appendString:@"\n"];
            [error appendString:msg];
        }
        [self.parsePending removeAllObjects];
        if (CodelessLibConfig.CODELESS_LOG || CodelessLibConfig.LINE_EVENTS)
            [self processCodelessLine:line type:CodelessLineInboundError];
        [self.commandPending onError:error.length > 0 ? [NSString stringWithString:error] : line];
    } else if ([CodelessProfile isErrorMessage:line]) {
        CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Received potential error: %@", line);
        [self.parsePending addObject:line];
    } else {
        CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Received response: %@", line);
        if (self.parsePending.count == 0 && self.commandPending.parsePartialResponse) {
            if (CodelessLibConfig.CODELESS_LOG || CodelessLibConfig.LINE_EVENTS)
                [self processCodelessLine:line type:CodelessLineInboundResponse];
            [self.commandPending parseResponse:line];
        } else {
            [self.parsePending addObject:line];
        }
    }
    if (self.commandPending && self.commandPending.complete)
        [self commandComplete:false];
}

/// Parses the text that was received from the peer device as an incoming command.
- (void) parseInboundCommand:(NSString*)line {
    CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Received command: %@", line);
    if (CodelessLibConfig.CODELESS_LOG || CodelessLibConfig.LINE_EVENTS)
        [self processCodelessLine:line type:CodelessLineInboundCommand];

    if (self.commandInbound) {
        CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Inbound command in progress. Ignore inbound data.");
        return;
    }

    CodelessCommand* hostCommand = nil;
    NSString* id = [CodelessProfile getCommand:line];
    if (!id) {
        if (CodelessLibConfig.HOST_INVALID_COMMANDS) {
            hostCommand = [[CodelessCustomCommand alloc] initWithManager:self command:line parse:true];
        } else {
            [self sendParseError:CodelessProfile.INVALID_COMMAND];
        }
    } else {
        Class commandClass = CodelessProfile.commandMap[id];
        if (!commandClass) {
            if (CodelessLibConfig.HOST_UNSUPPORTED_COMMANDS) {
                hostCommand = [[CodelessCustomCommand alloc] initWithManager:self command:line parse:true];
            } else {
                [self sendParseError:CodelessProfile.COMMAND_NOT_SUPPORTED];
            }
        } else {
            line = [CodelessProfile removeCommandPrefix:line];
            CodelessCommand* command = [CodelessProfile createCommand:self commandClass:commandClass command:line];
            if ([CodelessLibConfig.hostCommands containsObject:@(command.commandID)]) {
                hostCommand = command;
            } else if ([CodelessLibConfig.supportedCommands containsObject:@(command.commandID)]) {
                if (![self checkCommandMode:false command:command])
                    return;
                CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Library command: %@", command);
                self.commandInbound = command;
                [self.commandInbound setInbound];
                [self sendEvent:CodelessLibEvent.InboundCommand object:[[CodelessInboundCommandEvent alloc] initWithCommand:self.commandInbound]];
                if (!command.isValid) {
                    CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Invalid command: %@ %@", command, command.error);
                    [self.commandInbound setComplete];
                    [self sendError:[CodelessProfile.ERROR_PREFIX stringByAppendingString:self.commandInbound.error]];
                } else {
                    [self.commandInbound processInbound];
                }
            } else {
                [self sendParseError:CodelessProfile.COMMAND_NOT_SUPPORTED];
            }
        }
    }

    if (hostCommand) {
        if (![self checkCommandMode:false command:hostCommand])
            return;
        CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Host command: %@", hostCommand);
        self.commandInbound = hostCommand;
        [self.commandInbound setInbound];
        [self sendEvent:CodelessLibEvent.HostCommand object:[[CodelessHostCommandEvent alloc] initWithCommand:self.commandInbound]];
    }
}

/**
 * Actions performed when a Codeless Flow Control characteristic notification is received.
 * <p> The CodeLess Outbound characteristic is read to get the incoming data.
 */
- (void) onCodelessFlowControl:(NSData*)data {
    if (data.length > 0 && ((uint8_t*)data.bytes)[0] == CODELESS_DATA_PENDING) {
        self.inboundPending++;
        CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Pending codeless inbound data: %d", self.inboundPending);
        [self readCharacteristic:self.codelessOutbound];
    } else {
        CodelessLogPrefix(TAG, "Invalid codeless flow control value: %@", [CodelessUtil hexArrayLog:data]);
    }
}

/**
 * Actions performed when the Codeless Outbound characteristic is read successfully.
 * <p> The incoming data may be an incoming command or a response to an outgoing command.
 */
- (void) onCodelessInbound:(NSData*)data {
    CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Codeless inbound data: %@", [CodelessUtil hexArrayLog:data]);

    // Remove trailing zero
    if (data.length > 0 && ((uint8_t*)data.bytes)[data.length - 1] == 0)
        data = [NSData dataWithBytes:data.bytes length:data.length - 1];

    if (data.length == 0)
        CodelessLogPrefixOpt(CodelessLibLog.CODELESS, TAG, "Received empty buffer");

    NSString* inbound = [[NSString alloc] initWithData:data encoding:CodelessLibConfig.CHARSET];
    inbound = [inbound stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
    inbound = [inbound stringByReplacingOccurrencesOfString:@"\n\r" withString:@"\n"];
    inbound = [inbound stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    if ([inbound hasSuffix:@"\n"])
        inbound = [inbound substringToIndex:inbound.length - 1];
    NSArray<NSString*>* lines = [inbound componentsSeparatedByString:@"\n"];

    self.inboundPending--;

    for (__strong NSString* line in lines) {
        line = [line stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        if (self.commandPending) {
            [self parseCommandResponse:line];
        } else {
            if (line.length == 0) {
                if (CodelessLibConfig.CODELESS_LOG || CodelessLibConfig.LINE_EVENTS)
                    [self processCodelessLine:line type:CodelessLineInboundEmpty];
                continue;
            }
            [self parseInboundCommand:line];
        }
    }

    if (!self.commandPending || self.commandPending.complete)
        [self dequeueCommand];
}

- (void) sendBinaryText:(NSString*)text {
    [self sendDspsText:text];
}

- (void) sendHexData:(NSString*)hex {
    [self sendDspsHexData:hex];
}

- (void) sendBinaryData:(NSData*)data {
    [self sendDspsData:data chunkSize:self.dspsChunkSize];
}

- (void) sendBinaryData:(NSData*)data chunkSize:(int)chunkSize {
    [self sendDspsData:data chunkSize:chunkSize];
}

- (void) sendDspsText:(NSString*)text {
    CodelessLogPrefixOpt(CodelessLibLog.DSPS_DATA, TAG, "DSPS TX text: %@", text);
    [self sendDspsData:[text dataUsingEncoding:CodelessLibConfig.CHARSET]];
}

- (void) sendDspsHexData:(NSString*)hex {
    CodelessLogPrefixOpt(CodelessLibLog.DSPS_DATA, TAG, "DSPS TX hex: %@", hex);
    NSData* data = [CodelessUtil hex2bytes:hex];
    if (data)
        [self sendDspsData:data];
    else
        CodelessLogPrefix(TAG, "Invalid hex data: %@", hex);
}

- (void) sendDspsData:(NSData*)data {
    [self sendDspsData:data chunkSize:self.dspsChunkSize];
}

- (void) sendDspsData:(NSData*)data chunkSize:(int)chunkSize {
    if (![self checkReady] || ![self checkBinaryMode:true])
        return;
    CodelessLogPrefixOpt(CodelessLibLog.DSPS_DATA, TAG, "DSPS TX data: %@", [CodelessUtil hexArrayLog:data]);
    if (chunkSize > self.dspsChunkSize)
        chunkSize = self.dspsChunkSize;
    if (data.length <= chunkSize) {
        if (self.dspsTxFlowOn) {
            [self enqueueGattOperation:[[CodelessManager_DspsChunkOperation alloc] initWithManager:self data:data]];
        } else if (self.dspsPending.count <= CodelessLibConfig.DSPS_PENDING_MAX_SIZE) {
            [self.dspsPending addObject:[[CodelessManager_DspsChunkOperation alloc] initWithManager:self data:data]];
        } else {
            CodelessLogPrefixOpt(CodelessLibLog.DSPS, TAG, "DSPS TX data dropped (flow off, queue full)");
        }
    } else {
        NSMutableArray<CodelessManager_GattOperation*>* chunks = [NSMutableArray array];
        for (int i = 0; i < data.length; i += chunkSize) {
            [chunks addObject:[[CodelessManager_DspsChunkOperation alloc] initWithManager:self data:[NSData dataWithBytes:(uint8_t*)data.bytes + i length:MIN(chunkSize, data.length - i)]]];
        }
        if (self.dspsTxFlowOn) {
            [self enqueueGattOperations:chunks];
        } else if (self.dspsPending.count <= CodelessLibConfig.DSPS_PENDING_MAX_SIZE) {
            [self.dspsPending addObjectsFromArray:chunks];
        } else {
            CodelessLogPrefixOpt(CodelessLibLog.DSPS, TAG, "DSPS TX data dropped (flow off, queue full)");
        }
    }
}

/**
 * Actions performed when binary (DSPS) data are received from the peer device.
 * <p> A {@link CodelessLibEvent#DspsRxData DspsRxData} event is generated.
 * @param data the received binary data
 */
- (void) onDspsData:(NSData*)data {
    CodelessLogPrefixOpt(CodelessLibLog.DSPS_DATA, TAG, "DSPS RX data: %@", [CodelessUtil hexArrayLog:data]);
    if (![self checkBinaryMode:false])
        return;
    if (self.dspsEcho)
        [self sendDspsData:data];
    if (self.dspsFileReceive)
        [self.dspsFileReceive onDspsData:data];
    if (CodelessLibConfig.DSPS_RX_LOG && (!self.dspsFileReceive || CodelessLibConfig.DSPS_RX_FILE_LOG_DATA))
        [self.dspsRxLogFile log:data];
    if (CodelessLibConfig.DSPS_STATS)
        self.dspsRxBytesInterval += data.length;
    [self sendEvent:CodelessLibEvent.DspsRxData object:[[DspsRxDataEvent alloc] initWithManager:self data:data]];
}

/**
 * Sets the DSPS RX flow control configuration.
 *
 * The appropriate value is written to the DSPS Flow Control characteristic.
 * A {@link CodelessLibEvent#DspsRxFlowControl DspsRxFlowControl} event is generated.
 * @param on <code>true</code> to set RX flow to on (allow incoming data), <code>false</code> to set it to off
 */
- (void) setDspsRxFlowOn:(BOOL)on {
    _dspsRxFlowOn = on;
    CodelessLogPrefixOpt(CodelessLibLog.DSPS, TAG, "DSPS RX flow control: %@", _dspsRxFlowOn ? @"ON" : @"OFF");
    uint8_t value = _dspsRxFlowOn ? (uint8_t) CODELESS_DSPS_XON : (uint8_t) CODELESS_DSPS_XOFF;
    NSData* data = [NSData dataWithBytes:&value length:1];
    [self writeCharacteristic:_dspsFlowControl value:data response:false];
    [self sendEvent:CodelessLibEvent.DspsRxFlowControl object:[[DspsRxFlowControlEvent alloc] initWithManager:self flowOn:_dspsRxFlowOn]];
}

/**
 * Actions performed when a DSPS Flow Control characteristic notification is received.
 * <p> A {@link CodelessLibEvent#DspsTxFlowControl DspsTxFlowControl} event is generated.
 * @param data the notification data
 */
- (void) onDspsFlowControl:(NSData*)data {
    int value = data.length > 0 ? ((uint8_t*)data.bytes)[0] : INT_MIN;
    BOOL prev = self.dspsTxFlowOn;
    switch (value) {
        case CODELESS_DSPS_XON:
            self.dspsTxFlowOn = true;
            break;
        case CODELESS_DSPS_XOFF:
            self.dspsTxFlowOn = false;
            break;
        default:
            CodelessLogPrefix(TAG, "Invalid DSPS TX flow control value: %d", value);
            return;
    }

    if (prev == self.dspsTxFlowOn)
        return;

    CodelessLogPrefixOpt(CodelessLibLog.DSPS, TAG, "DSPS TX flow control: %@", self.dspsTxFlowOn ? @"ON" : @"OFF");
    [self sendEvent:CodelessLibEvent.DspsTxFlowControl object:[[DspsTxFlowControlEvent alloc] initWithManager:self flowOn:self.dspsTxFlowOn]];

    if (self.dspsTxFlowOn) {
        [self resumeDspsOperations];
    } else {
        [self pauseDspsOperations:true];
    }
}

- (DspsFileSend*) sendFile:(NSString*)file chunkSize:(int)chunkSize period:(int)period {
    DspsFileSend* operation = [[DspsFileSend alloc] initWithManager:self file:file chunkSize:chunkSize period:period];
    if (operation.isLoaded)
        [operation start];
    return operation;
}

- (DspsFileSend*) sendFile:(NSString*)file period:(int)period {
    return [self sendFile:file chunkSize:self.dspsChunkSize period:period];
}

- (DspsFileSend*) sendFile:(NSString*)file {
    return [self sendFile:file chunkSize:self.dspsChunkSize period:0];
}

// INTERNAL
- (void) startFile:(DspsFileSend*)operation resume:(BOOL)resume {
    if (![self checkReady] || ![self checkBinaryMode:true])
        return;
    if (!resume)
        [self.dspsFiles addObject:operation];
    if (!self.dspsTxFlowOn)
        return;
    if (operation.period > 0) {
        [operation performSelector:@selector(sendChunk) withObject:nil afterDelay:resume ? operation.period / 1000. : 0];
    } else {
        CodelessLogPrefixOpt(CodelessLibLog.DSPS_FILE_CHUNK, TAG, "Queue all file chunks: %@", operation);
        NSMutableArray<CodelessManager_GattOperation*>* chunks = [NSMutableArray array];
        for (int i = resume ? operation.chunk : 0; i < operation.totalChunks; i++) {
            [chunks addObject:[[CodelessManager_DspsFileChunkOperation alloc] initWithOperation:operation data:operation.chunks[i] chunk:i + 1]];
        }
        [self enqueueGattOperations:chunks];
    }
}

// INTERNAL
- (void) stopFile:(DspsFileSend*)operation {
    [self.dspsFiles removeObject:operation];
    [NSTimer cancelPreviousPerformRequestsWithTarget:operation selector:@selector(sendChunk) object:nil];
    [self removePendingDspsFileChunkOperations:operation];
}

// INTERNAL
- (void) sendFileData:(DspsFileSend*)operation {
    [self enqueueGattOperation:[[CodelessManager_DspsFileChunkOperation alloc] initWithOperation:operation data:[operation getCurrentChunk] chunk:operation.chunk + 1]];
}

- (DspsPeriodicSend*) sendPattern:(NSString*)file chunkSize:(int)chunkSize period:(int)period {
    DspsPeriodicSend* operation = [[DspsPeriodicSend alloc] initWithManager:self file:file chunkSize:chunkSize period:period];
    if (operation.isLoaded)
        [operation start];
    return operation;
}

- (DspsPeriodicSend*) sendPattern:(NSString*)file period:(int)period {
    return [self sendPattern:file chunkSize:self.dspsChunkSize period:period];
}

- (DspsPeriodicSend*) sendPattern:(NSString*)file {
    return [self sendPattern:file chunkSize:self.dspsChunkSize period:0];
}

// INTERNAL
- (void) startPeriodic:(DspsPeriodicSend*)operation {
    if (![self checkReady] || ![self checkBinaryMode:true])
        return;
    [self.dspsPeriodic addObject:operation];
    if (self.dspsTxFlowOn)
        [operation sendData];
}

// INTERNAL
- (void) stopPeriodic:(DspsPeriodicSend*)operation {
    [self.dspsPeriodic removeObject:operation];
    [NSTimer cancelPreviousPerformRequestsWithTarget:operation selector:@selector(sendData) object:nil];
    [self removePendingDspsPeriodicChunkOperations:operation];
}

// INTERNAL
- (void) sendPeriodicData:(DspsPeriodicSend*)operation {
    NSData* data = operation.data;
    int chunkSize =  operation.chunkSize;
    if (chunkSize > self.dspsChunkSize)
        chunkSize = self.dspsChunkSize;
    int totalChunks = data.length / chunkSize + (data.length % chunkSize != 0 ? 1 : 0);
    if (totalChunks == 1) {
        [self enqueueGattOperation:[[CodelessManager_DspsPeriodicChunkOperation alloc] initWithOperation:operation count:operation.count data:operation.data chunk:1 totalChunks:1]];
    } else {
        NSMutableArray<CodelessManager_GattOperation*>* chunks = [NSMutableArray array];
        for (int i = 0; i < data.length; i += chunkSize) {
            NSData* chunk = [NSData dataWithBytes:(uint8_t*)data.bytes + i length:MIN(chunkSize, data.length - i)];
            [chunks addObject:[[CodelessManager_DspsPeriodicChunkOperation alloc] initWithOperation:operation count:operation.count data:chunk chunk:i / chunkSize + 1 totalChunks:totalChunks]];
        }
        [self enqueueGattOperations:chunks];
    }
}

/**
 * Pauses any active DSPS send operations.
 * @param keepPending <code>true</code> to keep pending outgoing data in a buffer, <code>false</code> to discard them
 */
- (void) pauseDspsOperations:(BOOL)keepPending {
    // Remove pending operations
    for (DspsPeriodicSend* operation in self.dspsPeriodic) {
        [NSTimer cancelPreviousPerformRequestsWithTarget:operation selector:@selector(sendData) object:nil];
        int count = [self removePendingDspsPeriodicChunkOperations:operation];
        if (count > 0)
            [operation setResumeCount:count];
    }
    for (DspsFileSend* operation in self.dspsFiles) {
        [NSTimer cancelPreviousPerformRequestsWithTarget:operation selector:@selector(sendChunk) object:nil];
        int chunk = [self removePendingDspsFileChunkOperations:operation];
        if (chunk > 0)
            [operation setResumeChunk:chunk];
    }
    [self removePendingDspsChunkOperations:keepPending];
    if (!keepPending)
        [self.dspsPending removeAllObjects];
}

/// Resumes any active DSPS send operations and sends any buffered data.
- (void) resumeDspsOperations {
    // Send pending data
    [self enqueueGattOperations:self.dspsPending];
    [self.dspsPending removeAllObjects];
    // Resume operations
    for (DspsPeriodicSend* operation in self.dspsPeriodic) {
        [operation performSelector:@selector(sendData) withObject:nil afterDelay:operation.period / 1000.];
    }
    for (DspsFileSend* operation in self.dspsFiles) {
        [self startFile:operation resume:true];
    }
}

// INTERNAL
- (void) startFileReceive:(DspsFileReceive*)operation {
    if (![self checkReady] || ![self checkBinaryMode:true])
        return;
    if (self.dspsFileReceive)
        [self.dspsFileReceive stop];
    self.dspsFileReceive = operation;
}

// INTERNAL
- (void) stopFileReceive:(DspsFileReceive*)operation {
    if (self.dspsFileReceive == operation)
        self.dspsFileReceive = nil;
}

- (DspsFileReceive*) receiveFile {
    DspsFileReceive* operation = [[DspsFileReceive alloc] initWithManager:self];
    [operation start];
    return operation;
}

/**
 * Performs statistics calculations, called every {@link CodelessLibConfig#DSPS_STATS_INTERVAL}.
 * <p> A {@link CodelessLibEvent#DspsStats DspsStats} event is generated.
 */
- (void) dspsUpdateStats {
    if (self.commandMode)
        return;
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    if (now == self.dspsLastInterval)
        now += 0.001;
    self.dspsRxSpeed = (int) (self.dspsRxBytesInterval / (now - self.dspsLastInterval));
    self.dspsLastInterval = now;
    self.dspsRxBytesInterval = 0;
    [self performSelector:@selector(dspsUpdateStats) withObject:nil afterDelay:CodelessLibConfig.DSPS_STATS_INTERVAL / 1000.];
    [self sendEvent:CodelessLibEvent.DspsStats object:[[DspsStatsEvent alloc] initWithManager:self operation:nil currentSpeed:self.dspsRxSpeed averageSpeed:CodelessManager.SPEED_INVALID]];
}

/**
 * Called when the the peer device is connected.
 *
 * A {@link CodelessLibEvent#Connection Connection} event is generated.
 * After connection, a service discovery is started automatically and a {@link CodelessLibEvent#ServiceDiscovery ServiceDiscovery} event is generated.
 */
- (void) onConnection:(NSNotification*)notification {
    CodelessDeviceConnectedEvent* event = notification.userInfo[@"event"];
    if (![event.device isEqual:self.device])
        return;
    CodelessLogPrefix(TAG, "Connected");
    self.state = CODELESS_STATE_CONNECTED;
    [self sendEvent:CodelessLibEvent.Connection object:[[CodelessConnectionEvent alloc] initWithManager:self]];
    CodelessLogPrefix(TAG, "Discover services");
    self.state = CODELESS_STATE_SERVICE_DISCOVERY;
    [self sendEvent:CodelessLibEvent.ServiceDiscovery object:[[CodelessServiceDiscoveryEvent alloc] initWithManager:self complete:false]];
    [self.device discoverServices:@[CodelessProfile.CODELESS_SERVICE_UUID, CodelessProfile.DSPS_SERVICE_UUID, CodelessProfile.DEVICE_INFORMATION_SERVICE_UUID]];
    [self initialize];
}

/**
 * Called when the peer device is disconnected.
 * <p> A {@link CodelessLibEvent#Connection Connection} event is generated.
 */
- (void) onDisconnection:(NSNotification*)notification {
    CodelessDeviceDisconnectedEvent* event = notification.userInfo[@"event"];
    if (![event.device isEqual:self.device])
        return;
    CodelessLogPrefix(TAG, "Disconnected: error=%@", event.error);
    self.state = CODELESS_STATE_DISCONNECTED;
    [self reset];
    [self sendEvent:CodelessLibEvent.Connection object:[[CodelessConnectionEvent alloc] initWithManager:self]];
}

/**
 * Called when the connection to the peer device fails.
 * <p> A {@link CodelessLibEvent#Connection Connection} event is generated.
 */
- (void) onConnectionFailed:(NSNotification*)notification {
    CodelessConnectionFailedEvent* event = notification.userInfo[@"event"];
    if (![event.device isEqual:self.device])
        return;
    CodelessLogPrefix(TAG, "Connection failed: error=%@", event.error);
    self.state = CODELESS_STATE_DISCONNECTED;
    [self sendEvent:CodelessLibEvent.Connection object:[[CodelessConnectionEvent alloc] initWithManager:self]];
}

/// Handles Bluetooth state changes.
- (void) onBluetoothState:(NSNotification*)notification {
    CodelessBluetoothStateEvent* event = notification.userInfo[@"event"];
    if (event.state.intValue != CBCentralManagerStatePoweredOn && !self.isDisconnected) {
        CodelessLogPrefix(TAG, "Disconnected: Bluetooth OFF");
        self.state = CODELESS_STATE_DISCONNECTED;
        [self reset];
        [self sendEvent:CodelessLibEvent.Connection object:[[CodelessConnectionEvent alloc] initWithManager:self]];
    }
}

/// Initializes the manager when the peer device is connected.
- (void) initialize {
    if (CodelessLibConfig.CODELESS_LOG)
        self.codelessLogFile = [[CodelessLogFile alloc] initWithManager:self];
    if (CodelessLibConfig.DSPS_RX_LOG)
        self.dspsRxLogFile = [[DspsRxLogFile alloc] initWithManager:self];
}

/// Resets the manager when the peer device is disconnected.
- (void) reset {
    self.mtu = CODELESS_MTU_DEFAULT;

    [self.dspsPending removeAllObjects];
    for (DspsPeriodicSend* operation in [NSArray arrayWithArray:self.dspsPeriodic])
        [operation stop];
    for (DspsFileSend* operation in [NSArray arrayWithArray:self.dspsFiles])
        [operation stop];
    if (self.dspsFileReceive)
        [self.dspsFileReceive stop];

    if (CodelessLibConfig.DSPS_STATS)
        [NSTimer cancelPreviousPerformRequestsWithTarget:self selector:@selector(dspsUpdateStats) object:nil];

    if (CodelessLibConfig.CODELESS_LOG && self.codelessLogFile)
        [self.codelessLogFile close];
    if (CodelessLibConfig.DSPS_RX_LOG && self.dspsRxLogFile)
        [self.dspsRxLogFile close];

    self.gattOperationPending = nil;
    [self.gattQueue removeAllObjects];

    self.commandMode = false;
    self.binaryRequestPending = false;
    self.binaryExitRequestPending = false;

    [self.commandQueue removeAllObjects];
    self.commandPending = nil;
    self.commandInbound = nil;
    self.inboundPending = 0;
    self.outboundResponseLines = 0;
    [self.parsePending removeAllObjects];
    [self.scripts removeAllObjects];

    _dspsRxFlowOn = CodelessLibConfig.DEFAULT_DSPS_RX_FLOW_CONTROL;
    self.dspsTxFlowOn = CodelessLibConfig.DEFAULT_DSPS_TX_FLOW_CONTROL;

    self.servicesDiscovered = false;
    self.codelessSupport = false;
    self.dspsSupport = false;
    self.codelessService = nil;
    self.codelessInbound = nil;
    self.codelessOutbound = nil;
    self.codelessFlowControl = nil;
    self.dspsService = nil;
    self.dspsServerTx = nil;
    self.dspsServerRx = nil;
    self.dspsFlowControl = nil;
    self.deviceInfoService = nil;
}

/**
 * Searches for a service by UUID.
 * @param UUID the service UUID
 * @return the found service, or <code>nil</code> if not found
 */
- (CBService*) findServiceWithUUID:(CBUUID*)UUID {
    for (CBService* service in self.device.services) {
        if ([service.UUID isEqual:UUID])
            return service;
    }
    return nil;
}

/**
 * Searches for a characteristic by UUID.
 * @param UUID      the characteristic UUID
 * @param service   the containing service UUID
 * @return the found characteristic, or <code>nil</code> if not found
 */
- (CBCharacteristic*) findCharacteristicWithUUID:(CBUUID*)UUID forService:(CBService*)service {
    for (CBCharacteristic* characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:UUID])
            return characteristic;
    }
    return nil;
}

/**
 * %CBPeripheralDelegate <code>peripheral:didDiscoverServices:</code> implementation.
 *
 * It searches for the required services (CodeLess/DSPS) and initiates the characteristic discovery for each service.
 * If the service discovery is complete, a {@link CodelessLibEvent#ServiceDiscovery ServiceDiscovery} event is generated.
 * It initializes the {@link mtu MTU} value.
 */
- (void) peripheral:(CBPeripheral*)peripheral didDiscoverServices:(nullable NSError*)error {
    if (!error)
        CodelessLogPrefix(TAG, "Services discovered");
    else
        CodelessLogPrefix(TAG, "Service discovery error: %@", error);
    self.pendingDiscoverCharacteristics = [NSMutableArray array];
    self.pendingEnableNotifications = [NSMutableArray array];

    self.mtu = [self.device maximumWriteValueLengthForType:CBCharacteristicWriteWithoutResponse] + 3;
    CodelessLogPrefix(TAG, "MTU: %d", self.mtu);
    if (CodelessLibConfig.DSPS_CHUNK_SIZE_INCREASE_TO_MTU || self.dspsChunkSize > self.mtu - 3)
        self.dspsChunkSize = self.mtu - 3;

    self.deviceInfoService = [self findServiceWithUUID:CodelessProfile.DEVICE_INFORMATION_SERVICE_UUID];
    if (self.deviceInfoService) {
        [self.pendingDiscoverCharacteristics addObject:self.deviceInfoService];
        [self.device discoverCharacteristics:nil forService:self.deviceInfoService];
    }

    self.codelessService = [self findServiceWithUUID:CodelessProfile.CODELESS_SERVICE_UUID];
    CodelessLogPrefix(TAG, "Codeless service %@", self.codelessService ? @"found" : @"not found");
    if (self.codelessService) {
        [self.pendingDiscoverCharacteristics addObject:self.codelessService];
        [self.device discoverCharacteristics:nil forService:self.codelessService];
    }

    self.dspsService = [self findServiceWithUUID:CodelessProfile.DSPS_SERVICE_UUID];
    CodelessLogPrefix(TAG, "DSPS service %@", self.dspsService ? @"found" : @"not found");
    if (self.dspsService) {
        [self.pendingDiscoverCharacteristics addObject:self.dspsService];
        [self.device discoverCharacteristics:nil forService:self.dspsService];
    }

    if (!self.pendingDiscoverCharacteristics.count) {
        self.servicesDiscovered = true;
        self.state = CODELESS_STATE_CONNECTED;
        [self sendEvent:CodelessLibEvent.ServiceDiscovery object:[[CodelessServiceDiscoveryEvent alloc] initWithManager:self complete:true]];
    }
}

/**
 * %CBPeripheralDelegate <code>peripheral:didDiscoverCharacteristicsForService:error:</code> implementation.
 *
 * It searches for the required characteristics in CodeLess and DSPS services and enables notifications.
 * If the service discovery is complete, a {@link CodelessLibEvent#ServiceDiscovery ServiceDiscovery} event is generated.
 */
- (void) peripheral:(CBPeripheral*)peripheral didDiscoverCharacteristicsForService:(CBService*)service error:(nullable NSError*)error {
    CodelessLogPrefix(TAG, "Characteristics discovered: %@ error=%@", service.UUID, error);
    [self.pendingDiscoverCharacteristics removeObject:service];

    if ([service isEqual:self.codelessService]) {
        self.codelessInbound = [self findCharacteristicWithUUID:CodelessProfile.CODELESS_INBOUND_COMMAND_UUID forService:self.codelessService];
        if (!self.codelessInbound)
            CodelessLogPrefix(TAG, "Missing codeless inbound characteristic %@", CodelessProfile.CODELESS_INBOUND_COMMAND_UUID);

        self.codelessOutbound = [self findCharacteristicWithUUID:CodelessProfile.CODELESS_OUTBOUND_COMMAND_UUID forService:self.codelessService];
        if (!self.codelessOutbound)
            CodelessLogPrefix(TAG, "Missing codeless outbound characteristic %@", CodelessProfile.CODELESS_OUTBOUND_COMMAND_UUID);

        self.codelessFlowControl = [self findCharacteristicWithUUID:CodelessProfile.CODELESS_FLOW_CONTROL_UUID forService:self.codelessService];
        if (!self.codelessFlowControl)
            CodelessLogPrefix(TAG, "Missing codeless flow control characteristic %@", CodelessProfile.CODELESS_FLOW_CONTROL_UUID);

        self.codelessSupport = self.codelessInbound && self.codelessOutbound && self.codelessFlowControl;
        if (self.codelessSupport)
            [self.pendingEnableNotifications addObject:self.codelessFlowControl];
    }

    if ([service isEqual:self.dspsService]) {
        self.dspsServerTx = [self findCharacteristicWithUUID:CodelessProfile.DSPS_SERVER_TX_UUID forService:self.dspsService];
        if (!self.dspsServerTx)
            CodelessLogPrefix(TAG, "Missing DSPS server TX characteristic %@", CodelessProfile.DSPS_SERVER_TX_UUID);

        self.dspsServerRx = [self findCharacteristicWithUUID:CodelessProfile.DSPS_SERVER_RX_UUID forService:self.dspsService];
        if (!self.dspsServerRx)
            CodelessLogPrefix(TAG, "Missing DSPS server RX characteristic %@", CodelessProfile.DSPS_SERVER_RX_UUID);

        self.dspsFlowControl = [self findCharacteristicWithUUID:CodelessProfile.DSPS_FLOW_CONTROL_UUID forService:self.dspsService];
        if (!self.dspsFlowControl)
            CodelessLogPrefix(TAG, "Missing DSPS flow control characteristic %@", CodelessProfile.DSPS_FLOW_CONTROL_UUID);

        self.dspsSupport = self.dspsServerTx && self.dspsServerRx && self.dspsFlowControl;
        if (self.dspsSupport) {
            [self.pendingEnableNotifications addObject:self.dspsServerTx];
            [self.pendingEnableNotifications addObject:self.dspsFlowControl];
        }
    }

    if (!self.pendingDiscoverCharacteristics.count) {
        self.servicesDiscovered = true;
        self.state = CODELESS_STATE_CONNECTED;
        [self sendEvent:CodelessLibEvent.ServiceDiscovery object:[[CodelessServiceDiscoveryEvent alloc] initWithManager:self complete:true]];

        if (self.pendingEnableNotifications.count) {
            for (CBCharacteristic* characteristic in self.pendingEnableNotifications) {
                [self enableNotifications:characteristic];
            }
        } else {
            self.pendingEnableNotifications = nil;
        }
    }
}

/// Initiates a write descriptor operation to enable notifications for a characteristic.
- (void) enableNotifications:(CBCharacteristic*)characteristic {
    if (!self.isConnected)
        return;
    CodelessLogPrefix(TAG, "Enable notifications: %@", characteristic.UUID);
    [self.device setNotifyValue:true forCharacteristic:characteristic];
}

/**
 * %CBPeripheralDelegate <code>peripheral:didUpdateNotificationStateForCharacteristic:error:</code> implementation.
 * <p> A {@link CodelessLibEvent#Ready Ready} event is generated after all required notifications are enabled.
 */
- (void) peripheral:(CBPeripheral*)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic*)characteristic error:(nullable NSError*)error {
    CodelessLogPrefixOpt(CodelessLibLog.GATT_OPERATION, TAG, "didUpdateNotificationStateForCharacteristic: %@", characteristic.UUID);
    if (!error) {
        if (self.pendingEnableNotifications) {
            [self.pendingEnableNotifications removeObject:characteristic];
            if (!self.pendingEnableNotifications.count) {
                self.pendingEnableNotifications = nil;
                [self onDeviceReady];
            }
        }
    } else {
        CodelessLogPrefix(TAG, "Failed to enable notifications: %@ %@", characteristic.UUID, error);
        [self sendEvent:CodelessLibEvent.Error object:[[CodelessErrorEvent alloc] initWithManager:self error:CODELESS_ERROR_GATT_OPERATION]];
        if ([self.pendingEnableNotifications containsObject:characteristic])
            [self sendEvent:CodelessLibEvent.Error object:[[CodelessErrorEvent alloc] initWithManager:self error:CODELESS_ERROR_INIT_SERVICES]];
    }
}

/// Enqueues a read characteristic operation in the GATT operation queue.
- (void) readCharacteristic:(CBCharacteristic*)characteristic {
    [self enqueueGattOperation:[[CodelessManager_GattOperation alloc] initWithCharacteristic:characteristic]];
}

/// Executes a read characteristic operation.
- (void) executeReadCharacteristic:(CBCharacteristic*)characteristic {
    CodelessLogPrefixOpt(CodelessLibLog.GATT_OPERATION, TAG, "Read characteristic: %@", characteristic.UUID);
    [self.device readValueForCharacteristic:characteristic];
}

/// %CBPeripheralDelegate <code>peripheral:didUpdateValueForCharacteristic:error:</code> implementation.
- (void) peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(nullable NSError*)error {
    CodelessLogPrefixOpt(CodelessLibLog.GATT_OPERATION, TAG, "didUpdateValueForCharacteristic: %@ %@", characteristic.UUID, [CodelessUtil hexArrayLog:characteristic.value]);
    BOOL read = self.gattOperationPending.type == GattOperationReadCharacteristic && [self.gattOperationPending.characteristic isEqual:characteristic];
    if (read && CodelessLibConfig.GATT_DEQUEUE_BEFORE_PROCESSING)
        [self dequeueGattOperation];

    if (!error) {
        if ([characteristic isEqual:self.codelessOutbound]) {
            [self onCodelessInbound:characteristic.value];
        } else if ([characteristic isEqual:self.codelessFlowControl]) {
            [self onCodelessFlowControl:characteristic.value];
        } else if ([characteristic isEqual:self.dspsServerTx]) {
            [self onDspsData:characteristic.value];
        } else if ([characteristic isEqual:self.dspsFlowControl]){
            [self onDspsFlowControl:characteristic.value];
        } else if ([characteristic.service isEqual:self.deviceInfoService]) {
            [self onDeviceInfoRead:characteristic];
        }
    } else {
        CodelessLogPrefix(TAG, "Failed to read characteristic: %@, %@", characteristic.UUID, error);
        [self sendEvent:CodelessLibEvent.Error object:[[CodelessErrorEvent alloc] initWithManager:self error:CODELESS_ERROR_GATT_OPERATION]];
    }

    if (read && !CodelessLibConfig.GATT_DEQUEUE_BEFORE_PROCESSING)
        [self dequeueGattOperation];
}

/// Enqueues a write characteristic operation in the GATT operation queue.
- (void) writeCharacteristic:(CBCharacteristic*)characteristic value:(NSData*)value {
    [self enqueueGattOperation:[[CodelessManager_GattOperation alloc] initWithCharacteristic:characteristic value:value]];
}

/**
 * Enqueues a write characteristic operation in the GATT operation queue.
 * @param response <code>true</code> for write with response, <code>false</code> for write command
 */
- (void) writeCharacteristic:(CBCharacteristic*)characteristic value:(NSData*)value response:(BOOL)response {
    [self enqueueGattOperation:[[CodelessManager_GattOperation alloc] initWithCharacteristic:characteristic value:value response:response]];
}

/// Executes a write characteristic operation.
- (void) executeWriteCharacteristic:(CBCharacteristic*)characteristic value:(NSData*)value response:(BOOL)response {
    CodelessLogPrefixOpt(CodelessLibLog.GATT_OPERATION, TAG, "Write characteristic%@: %@ %@", !response ? @" (no response)" : @"", characteristic.UUID, [CodelessUtil hexArrayLog:value]);
    [self.device writeValue:value forCharacteristic:characteristic type:response ? CBCharacteristicWriteWithResponse : CBCharacteristicWriteWithoutResponse];
}

/// %CBPeripheralDelegate <code>peripheral:didWriteValueForCharacteristic:error:</code> implementation.
- (void) peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic*)characteristic error:(nullable NSError*)error {
    CodelessLogPrefixOpt(CodelessLibLog.GATT_OPERATION, TAG, "didWriteValueForCharacteristic: %@", characteristic.UUID);
    if (CodelessLibConfig.GATT_DEQUEUE_BEFORE_PROCESSING)
        [self dequeueGattOperation];

    if (error) {
        CodelessLogPrefix(TAG, "Failed to write characteristic: %@ %@", characteristic.UUID, error);
        [self sendEvent:CodelessLibEvent.Error object:[[CodelessErrorEvent alloc] initWithManager:self error:CODELESS_ERROR_GATT_OPERATION]];
        if ([characteristic isEqual:self.codelessInbound]) {
            if (self.commandPending) {
                [self.commandPending onError:CodelessProfile.GATT_OPERATION_ERROR];
                [self commandComplete:true];
            } else if (self.commandInbound) {
                [self.commandInbound setComplete];
                [self inboundCommandComplete];
            }
        }
    }

    if (!CodelessLibConfig.GATT_DEQUEUE_BEFORE_PROCESSING)
        [self dequeueGattOperation];
}

/// %CBPeripheralDelegate <code>peripheral:peripheralIsReadyToSendWriteWithoutResponse:</code> implementation.
- (void) peripheralIsReadyToSendWriteWithoutResponse:(CBPeripheral*)peripheral {
    CodelessLogPrefixOpt(CodelessLibLog.GATT_OPERATION, TAG, "peripheralIsReadyToSendWriteWithoutResponse");
    [self dequeueGattOperation];
}

/**
 * %CBPeripheralDelegate <code>peripheral:didReadRSSI:error:</code> implementation.
 * <p> A {@link CodelessLibEvent#Rssi Rssi} event is generated.
 */
- (void) peripheral:(CBPeripheral*)peripheral didReadRSSI:(NSNumber*)RSSI error:(nullable NSError*)error {
    if (!error) {
        CodelessLogPrefixOpt(CodelessLibLog.GATT_OPERATION, TAG, "RSSI: %d", RSSI.intValue);
        [self sendEvent:CodelessLibEvent.Rssi object:[[CodelessRssiEvent alloc] initWithManager:self rssi:RSSI]];
    } else {
        CodelessLogPrefix(TAG, "Failed to read RSSI");
    }
}

- (BOOL) isGattOperationPending {
    return self.gattOperationPending != nil;
}

/**
 * Enqueues a GATT operation in the GATT operation queue.
 * <p> If the queue is empty, the operation starts immediately.
 */
- (void) enqueueGattOperation:(CodelessManager_GattOperation*)operation {
    if (!self.isConnected)
        return;
    if (@available(ios 11, *)) {
        if (self.gattOperationPending) {
            if (!CodelessLibConfig.GATT_QUEUE_PRIORITY)
                [self.gattQueue addObject:operation];
            else
                [self enqueueGattOperationWithPriority:operation];
        } else {
            [self executeGattOperation:operation];
        }
    } else {
        [self executeGattOperation:operation];
        return;
    }
}

/**
 * Enqueues a series of GATT operations in the GATT operation queue.
 * <p> If the queue is empty, the first operation starts immediately.
 */
- (void) enqueueGattOperations:(NSArray<CodelessManager_GattOperation*>*)operations {
    if (!self.isConnected || !operations.count)
        return;
    if (@available(ios 11, *)) {
        if (!CodelessLibConfig.GATT_QUEUE_PRIORITY)
            [self.gattQueue addObjectsFromArray:operations];
        else
            [self enqueueGattOperationsWithPriority:operations];
        if (!self.gattOperationPending) {
            [self dequeueGattOperation];
        }
    } else {
        for (CodelessManager_GattOperation* operation in operations) {
            [self executeGattOperation:operation];
        }
        return;
    }
}

/**
 * Enqueues a GATT operation in the GATT operation queue, taking {@link CodelessManager_GattOperation#lowPriority priority} into account.
 * <p> Used if {@link CodelessLibConfig#GATT_QUEUE_PRIORITY} is enabled.
 */
- (void) enqueueGattOperationWithPriority:(CodelessManager_GattOperation*)operation {
    if (!self.gattQueue.count || !self.gattQueue.lastObject.lowPriority || operation.lowPriority) {
        [self.gattQueue addObject:operation];
    } else if (self.gattQueue.firstObject.lowPriority) {
        [self.gattQueue insertObject:operation atIndex:0];
    } else {
        for (int i = 0; i < self.gattQueue.count; ++i) {
            if (self.gattQueue[i].lowPriority) {
                [self.gattQueue insertObject:operation atIndex:i];
                break;
            }
        }
    }
}

/**
 * Enqueues a series of GATT operations in the GATT operation queue, taking {@link CodelessManager_GattOperation#lowPriority priority} into account.
 * <p> Used if {@link CodelessLibConfig#GATT_QUEUE_PRIORITY} is enabled.
 * <p> NOTE: All operations in the series must have the same priority.
 */
- (void) enqueueGattOperationsWithPriority:(NSArray<CodelessManager_GattOperation*>*)operations {
    if (!self.gattQueue.count || !self.gattQueue.lastObject.lowPriority || operations[0].lowPriority) {
        [self.gattQueue addObjectsFromArray:operations];
    } else {
        for (int i = 0; i < self.gattQueue.count; ++i) {
            if (self.gattQueue[i].lowPriority) {
                for (CodelessManager_GattOperation* operation in operations) {
                    [self.gattQueue insertObject:operation atIndex:i++];
                }
                break;
            }
        }
    }
}

/// Executes the next GATT operation from the GATT operation queue.
- (void) dequeueGattOperation {
    self.gattOperationPending = nil;
    if (!self.gattQueue.count)
        return;
    [self executeGattOperation:self.gattQueue.firstObject];
    [self.gattQueue removeObjectAtIndex:0];
}

/// Executes a GATT operation.
- (void) executeGattOperation:(CodelessManager_GattOperation*)operation {
    self.gattOperationPending = operation;
    [operation onExecute];
    switch (operation.type) {
        case GattOperationReadCharacteristic:
            [self executeReadCharacteristic:operation.characteristic];
            break;
        case GattOperationWriteCharacteristic:
        case GattOperationWriteCommand:
            [self executeWriteCharacteristic:operation.characteristic value:operation.value response:operation.type == GattOperationWriteCharacteristic];
            break;
    }
}

/**
 * Removes any enqueued operations from the GATT operation queue that are not part of a file or periodic send operation.
 * @param keep <code>true</code> to keep enqueued outgoing data in a buffer, <code>false</code> to discard them
 */
- (void) removePendingDspsChunkOperations:(BOOL)keep {
    for (int i = 0; i < self.gattQueue.count; ++i) {
        if ([self.gattQueue[i] isKindOfClass:CodelessManager_DspsChunkOperation.class]) {
            if (keep)
                [self.dspsPending addObject:self.gattQueue[i]];
            [self.gattQueue removeObjectAtIndex:i--];
        }
    }
}

/**
 * Removes any enqueued operations from the GATT operation queue that are part of a periodic send operation.
 * @param operation the periodic send operation
 * @return the counter of the first enqueued operation (used to set the resume counter)
 */
- (int) removePendingDspsPeriodicChunkOperations:(DspsPeriodicSend*)operation {
    int count = -1;
    for (int i = 0; i < self.gattQueue.count; ++i) {
        if ([self.gattQueue[i] isKindOfClass:CodelessManager_DspsPeriodicChunkOperation.class] && ((CodelessManager_DspsPeriodicChunkOperation*)self.gattQueue[i]).operation == operation) {
            CodelessManager_DspsPeriodicChunkOperation* periodicChunkOperation = (CodelessManager_DspsPeriodicChunkOperation*) self.gattQueue[i];
            if (count == -1 && periodicChunkOperation.chunk == 1)
                count = periodicChunkOperation.count;
            [self.gattQueue removeObjectAtIndex:i--];
        }
    }
    return count;
}

/**
 * Removes any enqueued operations from the GATT operation queue that are part of a file send operation.
 * @param operation the file send operation
 * @return the chunk number of the first enqueued operation (used to set the resume chunk)
 */
- (int) removePendingDspsFileChunkOperations:(DspsFileSend*)operation {
    int chunk = -1;
    for (int i = 0; i < self.gattQueue.count; ++i) {
        if ([self.gattQueue[i] isKindOfClass:CodelessManager_DspsFileChunkOperation .class] && ((CodelessManager_DspsFileChunkOperation*)self.gattQueue[i]).operation == operation) {
            if (chunk == -1)
                chunk = ((CodelessManager_DspsFileChunkOperation*)self.gattQueue[i]).chunk - 1;
            [self.gattQueue removeObjectAtIndex:i--];
        }
    }
    return chunk;
}

@end


@implementation CodelessManager_GattOperation

- (instancetype) initWithCharacteristic:(CBCharacteristic*)characteristic {
    self = [super init];
    if (!self)
        return nil;
    self.characteristic = characteristic;
    self.type = GattOperationReadCharacteristic;
    return self;
}

- (instancetype) initWithCharacteristic:(CBCharacteristic*)characteristic value:(NSData*)value {
    self = [super init];
    if (!self)
        return nil;
    self.characteristic = characteristic;
    self.type = GattOperationWriteCharacteristic;
    self.value = value;
    return self;
}

- (instancetype) initWithCharacteristic:(CBCharacteristic*)characteristic value:(NSData*)value response:(BOOL)response {
    self = [super init];
    if (!self)
        return nil;
    self.characteristic = characteristic;
    self.type = response ? GattOperationWriteCharacteristic : GattOperationWriteCommand;
    self.value = value;
    return self;
}

- (void) onExecute {
}

- (BOOL) lowPriority {
    return false;
}

@end


@implementation CodelessManager_DspsGattOperation

- (instancetype) initWithManager:(CodelessManager*)manager data:(NSData*)data {
    self = [super initWithCharacteristic:manager.dspsServerRx value:data response:false];
    if (!self)
        return nil;
    self.manager = manager;
    return self;
}

@end


@implementation CodelessManager_DspsChunkOperation

- (void) onExecute {
    CodelessLogOpt(CodelessLibLog.DSPS_CHUNK, TAG, "%@Send DSPS chunk: %@", self.manager.logPrefix, [CodelessUtil hexArrayLog:self.value]);
}

@end


@implementation CodelessManager_DspsPeriodicChunkOperation

- (instancetype) initWithOperation:(DspsPeriodicSend*)operation count:(int)count data:(NSData*)data chunk:(int)chunk totalChunks:(int)totalChunks {
    self = [super initWithManager:operation.manager data:data];
    if (!self)
        return nil;
    self.operation = operation;
    self.count = count;
    self.chunk = chunk;
    self.totalChunks = totalChunks;
    return self;
}

- (BOOL) lowPriority {
    return true;
}

- (void) onExecute {
    CodelessLogOpt(CodelessLibLog.DSPS_PERIODIC_CHUNK, TAG, "%@Send periodic DSPS chunk: count %d (%d of %d) %@",
            self.manager.logPrefix, self.count, self.chunk, self.totalChunks, [CodelessUtil hexArrayLog:self.value]);
    if (CodelessLibConfig.DSPS_STATS)
        [self.operation updateBytesSent:self.value.length];
    if (self.operation.pattern) {
        self.operation.patternSentCount = (self.count - 1) % self.operation.patternMaxCount;
        [self.manager sendEvent:CodelessLibEvent.DspsPatternChunk object:[[DspsPatternChunkEvent alloc] initWithManager:self.manager operation:self.operation count:self.operation.patternSentCount]];
    }
}

@end


@implementation CodelessManager_DspsFileChunkOperation

- (instancetype) initWithOperation:(DspsFileSend*)operation data:(NSData*)data chunk:(int)chunk {
    self = [super initWithManager:operation.manager data:data];
    if (!self)
        return nil;
    self.operation = operation;
    self.chunk = chunk;
    return self;
}

- (BOOL) lowPriority {
    return true;
}

- (void) onExecute {
    CodelessLogOpt(CodelessLibLog.DSPS_FILE_CHUNK, TAG, "%@Send file chunk: %@ (%d of %d) %@",
            self.manager.logPrefix, self.operation, self.chunk, self.operation.totalChunks, [CodelessUtil hexArrayLog:self.value]);
    self.operation.sentChunks = self.chunk;
    if (CodelessLibConfig.DSPS_STATS)
        [self.operation updateBytesSent:self.value.length];
    if (self.chunk == self.operation.totalChunks) {
        CodelessLogOpt(CodelessLibLog.DSPS, TAG, "%@File sent: %@", self.manager.logPrefix, self.operation);
        [self.operation setComplete];
        [self.manager.dspsFiles removeObject:self.operation];
    }
    [self.manager sendEvent:CodelessLibEvent.DspsFileChunk object:[[DspsFileChunkEvent alloc] initWithManager:self.manager operation:self.operation chunk:self.chunk]];
}

@end
