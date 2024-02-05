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
#import <CoreBluetooth/CoreBluetooth.h>

@class CodelessBluetoothManager;
@class CBPeripheral;
@class CodelessCommand;
@class CodelessManager_GattOperation;
@class CodelessLibConfig;
@class CodelessCommands;
@class CodelessLogFile;
@class DspsRxLogFile;
@class DspsPeriodicSend;
@class DspsFileSend;
@class DspsFileReceive;
@class CodelessScript;

NS_ASSUME_NONNULL_BEGIN

/**
 * Manages the connection and communication with the peer CodeLess/DSPS device.
 *
 * ## Usage ##
 * Create a %CodelessManager object by providing the %CBPeripheral you want to interact with.
 * The device can be obtained from a Bluetooth scan using {@link CodelessBluetoothManager}.
 * Use {@link #connect} to connect to the device and {@link #disconnect} to end the connection.
 * After connection, the library will automatically start a service discovery and enable all the
 * required notifications. After that, the library is ready for bidirectional communication with the
 * peer device using CodeLess commands and/or DSPS binary data, depending on the supported services.
 *
 * This class provides methods and functionality that allow the app to send CodeLess commands, receive commands and
 * respond to them, as well as send and receive binary data using the DSPS protocol.
 * For example, see: {@link #state}, {@link #isReady}, {@link #commandFactory},
 * {@link #sendCommand: sendCommand}, {@link #setMode: setMode}, {@link #sendDspsData:chunkSize: sendDspsData},
 * {@link #sendFile:chunkSize:period: sendFile}, {@link #sendPattern:chunkSize:period: sendPattern}, {@link #dspsTxFlowOn}.
 * See {@link CodelessCommand} on how to implement incoming commands.
 *
 * The library generates several events to inform the app about specific actions or results.
 * For example: {@link CodelessLibEvent#Connection Connection}, {@link CodelessLibEvent#Ready Ready}, {@link CodelessLibEvent#Mode Mode},
 * {@link CodelessLibEvent#Error Error}, {@link CodelessLibEvent#CommandSuccess CommandSuccess}, {@link CodelessLibEvent#CommandError CommandError},
 * {@link CodelessLibEvent#InboundCommand InboundCommand}, {@link CodelessLibEvent#HostCommand HostCommand},
 * {@link CodelessLibEvent#DspsRxData DspsRxData}, {@link CodelessLibEvent#DspsTxFlowControl DspsTxFlowControl}.
 * Each command may generate additional events.
 *
 * The library automatically handles mode switching between command (CodeLess) and binary (DSPS) mode, by implementing the mode
 * commands as described in the CodeLess specification. If {@link CodelessLibConfig#HOST_BINARY_REQUEST} is enabled, see
 * {@link #acceptBinaryModeRequest} on how to handle a peer request to switch to binary mode.
 *
 * @see CodelessBluetoothManager
 * @see CodelessCommands
 * @see CodelessLibEvent
 * @see <a href="https://lpccs-docs.renesas.com/UM-140-DA145x-CodeLess/index.html">CodeLess User Manual</a>
 */
@interface CodelessManager : NSObject <CBPeripheralDelegate>

@property (class, readonly) NSString* TAG;

/// Connection state
enum CODELESS_STATE {
    /// The device is disconnected.
    CODELESS_STATE_DISCONNECTED = 0,
    /// Connection in progress.
    CODELESS_STATE_CONNECTING = 1,
    /// The device is connected.
    CODELESS_STATE_CONNECTED = 2,
    /// Service discovery in progress.
    CODELESS_STATE_SERVICE_DISCOVERY = 3,
    /// The device is ready for operation.
    CODELESS_STATE_READY = 4,
};

#define DSPS_SPEED_INVALID   -1
/// Indicates that the speed value hasn't been set yet.
@property (class, readonly) int SPEED_INVALID;

/// The CodelessBluetoothManager to be used for the connection.
@property (readonly) CodelessBluetoothManager* bluetoothManager;
/// The associated device.
@property (readonly) CBPeripheral* device;
/// The connection {@link #CODELESS_STATE state}.
@property (readonly) int state;
/// The connection MTU.
@property (readonly) int mtu;
/// The pending GATT operation.
@property (readonly) CodelessManager_GattOperation* gattOperationPending;
/// <code>true</code> if the device is in command (CodeLess) mode.
@property (readonly) BOOL commandMode;
// Codeless
/// The command creation helper object.
@property (readonly) CodelessCommands* commandFactory;
/// The pending outgoing command.
@property (readonly) CodelessCommand* commandPending;
/// The pending incoming command.
@property (readonly) CodelessCommand* commandInbound;
/**
 * The number of CodeLess data that must be read.
 *
 * This number is increased for every CodeLess Flow Control notification.
 * The library reads the CodeLess Outbound characteristic to get the incoming data.
 */
@property (readonly) int inboundPending;
// DSPS
/// The DSPS chunk size.
/// <p> WARNING: The chunk size must not exceed the value (MTU - 3), otherwise chunks will be truncated when sent.
@property int dspsChunkSize;
/**
 * <code>true</code> if the DSPS RX flow control in on.
 *
 * When set, the appropriate value is written to the DSPS Flow Control characteristic.
 * A {@link CodelessLibEvent#DspsRxFlowControl DspsRxFlowControl} event is generated.
 */
@property (nonatomic) BOOL dspsRxFlowOn;
/**
 * <code>true</code> if the DSPS TX flow control in on.
 *
 * When TX flow control is off, the library stops sending binary data to the peer device.
 * Any active file and periodic send operations are paused. Outgoing binary data that are
 * sent by the app at this time are kept in a buffer. When the peer device notifies that
 * it can receive data, by setting the TX flow control to on, all active operations are
 * resumed and any pending data in the buffer are sent.
 *
 * NOTE: Any binary data that have already been passed to the iOS BLE stack when TX
 * flow control is set to off will be sent. The library cannot control this behavior.
 */
@property (readonly) BOOL dspsTxFlowOn;
/// The DSPS echo configuration.
/// <p> If echo is enabled, all incoming binary data are sent back to the peer device.
@property BOOL dspsEcho;
/// The active DSPS file receive operation, if available.
@property (readonly) DspsFileReceive* dspsFileReceive;
/// The calculated current receive speed.
/// <p> Available only if {@link CodelessLibConfig#DSPS_STATS statistics} are enabled.
@property (readonly) int dspsRxSpeed;
// Service database
/// <code>true</code> if the service discovery is complete.
@property (readonly) BOOL servicesDiscovered;
/// <code>true</code> if the peer device supports CodeLess.
@property (readonly) BOOL codelessSupport;
/// <code>true</code> if the peer device supports DSPS.
@property (readonly) BOOL dspsSupport;
/// The log prefix, used for log messages.
@property (readonly) NSString* logPrefix;

/**
 * Creates a CodelessManager to manage the connection with the specified device.
 * @param manager   the CodelessBluetoothManager to be used for the connection
 * @param device    the device to connect to
 */
- (instancetype) initWithBluetoothManager:(CodelessBluetoothManager*)manager device:(CBPeripheral*)device;

/// Connects to the peer device.
- (void) connect;
/// Disconnects from the peer device.
- (void) disconnect;
/// Checks if the device is connected.
- (BOOL) isConnected;
/// Checks if the connection is in progress.
- (BOOL) isConnecting;
/// Checks if the peer device is ready for Codeless/DSPS operations.
/// <p> The device becomes ready after the service discovery is complete and the required notifications are enabled.
- (BOOL) isReady;
/// Checks if the device is disconnected.
- (BOOL) isDisconnected;

/**
 * Checks if the device has one of the device information service characteristics.
 * @param uuid the UUID of the characteristic to check, or <code>nil</code> to just check for the service
 */
- (BOOL) hasDeviceInfo:(CBUUID*)uuid;
/**
 * Reads one of the device information service characteristics.
 * @param uuid the UUID of the characteristic to read
 */
- (void) readDeviceInfo:(CBUUID*)uuid;
/**
 * Reads the connection RSSI.
 * <p> On success, a {@link CodelessLibEvent#Rssi} event is generated.
 */
- (void) getRssi;

/// Checks if the device is in binary (DSPS) mode.
- (BOOL) binaryMode;
/**
 * Sets the operation mode.
 *
 * If the mode needs to change, the appropriate mode command is sent to change the mode.
 * After the mode command transaction is complete, the mode will change and
 * a {@link CodelessLibEvent#Mode Mode} event will be generated.
 * @param command <code>true</code> for command mode, <code>false</code> for binary mode
 */
- (void) setMode:(BOOL)command;
/**
 * Accepts the binary mode request that was sent by the peer device.
 *
 * If <code>AT+BINREQ</code> is received and {@link CodelessLibConfig#HOST_BINARY_REQUEST} is enabled,
 * a {@link CodelessLibEvent#BinaryModeRequest BinaryModeRequest} event is generated.
 * The app should call this function to accept the mode change.
 * The library responds with <code>AT+BINREQACK</code> and enters binary mode.
 */
- (void) acceptBinaryModeRequest;
/**
 * Accepts the binary mode exit request that was sent by the peer device.
 * <p> NOTE: This is deprecated. The library responds automatically with <code>AT+BINREQEXITACK</code> and exits binary mode.
 */
- (void) acceptBinaryModeExitRequest;
/// Called when <code>AT+BINREQ</code> is sent successfully.
- (void) onBinRequestSent;
/**
 * Called when <code>AT+BINREQ</code> is received.
 *
 * If a mode switch is needed and {@link CodelessLibConfig#HOST_BINARY_REQUEST} is enabled,
 * a {@link CodelessLibEvent#BinaryModeRequest BinaryModeRequest} event is generated,
 * otherwise the library responds automatically with <code>AT+BINREQACK</code>.
 *
 * The app should call {@link #acceptBinaryModeRequest} to accept the request.
 */
- (void) onBinRequestReceived;
/**
 * Called when <code>AT+BINREQACK</code> is sent successfully.
 * <p> The library switches to binary mode (if needed).
 */
- (void) onBinAckSent;
/**
 * Called when <code>AT+BINREQACK</code> is received.
 * <p> The library switches to binary mode (if needed).
 */
- (void) onBinAckReceived;
/**
 * Called when <code>AT+BINREQEXIT</code> is sent successfully.
 * <p> The library switches to command mode (if needed).
 */
- (void) onBinExitSent;
/**
 * Called when <code>AT+BINREQEXIT</code> is received.
 * <p> The library responds with <code>AT+BINREQEXITACK</code> and switches to command mode (if needed).
 */
- (void) onBinExitReceived;
/// Called when <code>AT+BINREQEXITACK</code> is sent successfully.
- (void) onBinExitAckSent;
/// Called when <code>AT+BINREQEXITACK</code> is received.
- (void) onBinExitAckReceived;

/// Checks if an outgoing command is pending (sent and waiting for response).
- (BOOL) isCommandPending;
/**
 * Checks if there are incoming CodeLess data that must be read.
 * <p> The library handles this automatically.
 */
- (BOOL) isInboundPending;
/**
 * Sends a text command to the peer device.
 * <p> The command is parsed to a {@link CodelessCommand} subclass object.
 * @param line the text command
 */
- (void) sendTextCommand:(NSString*)line;
/**
 * Sends a series of text commands to the peer device.
 * @param script the command script (one command per line)
 * @see CodelessScript
 */
- (void) sendCommandScript:(NSArray<NSString*>*)script;
/// NOTE: Deprecated
- (void) addScript:(CodelessScript*)script;
/// NOTE: Deprecated
- (void) removeScript:(CodelessScript*)script;
/**
 * Parses a text command to a {@link CodelessCommand} subclass object.
 * @param line the text command
 * @return the command subclass object
 */
- (CodelessCommand*) parseTextCommand:(NSString*)line;
/**
 * Sends a command to the peer device.
 * @param command the command to send
 */
- (void) sendCommand:(CodelessCommand*)command;
/**
 * Sends a series of commands to the peer device.
 * @param commands the commands to send
 * @see CodelessScript
 */
- (void) sendCommands:(NSArray<CodelessCommand*>*)commands;
/**
 * Completes the specified outgoing command, if it is currently pending.
 * @param command the command to complete
 */
- (void) completePendingCommand:(CodelessCommand*)command;
/**
 * Sends a success response to the peer device.
 * <p> Use this to respond to a supported incoming command.
 * @see CodelessCommand#sendSuccess
 */
- (void) sendSuccess;
/**
 * Sends a success response to the peer device, prepended with the specified response message.
 * <p> Use this to respond to a supported incoming command.
 * @param response the response message
 * @see CodelessCommand#sendSuccess:
 */
- (void) sendSuccess:(NSString*)response;
/**
 * Sends an error response to the peer device, prepended with the specified error message.
 * <p> Use this to respond to a supported incoming command with an error.
 * @param error the error message
 * @see CodelessCommand#sendError:
 */
- (void) sendError:(NSString*)error;
/**
 * Sends a response message to the peer device.
 *
 * Use this to respond to a supported incoming command with a message.
 * The command is still pending after a call to this method.
 * You can add more response messages or complete the command.
 *
 * If {@link CodelessLibConfig#SINGLE_WRITE_RESPONSE} is enabled the response is not sent immediately.
 * It will be sent along with the success or error response.
 * @param response the response message
 * @see #sendSuccess:
 * @see #sendError:
 */
- (void) sendResponse:(NSString*)response;
/**
 * Completes the specified incoming command, if it is currently pending.
 * @param command the command to complete
 * @see #sendSuccess:
 * @see #sendError:
 */
- (void) completeInboundCommand:(CodelessCommand*)command;

/**
 * Sends text data to the peer device.
 * @param text the text data to send
 * @see #sendDspsData:chunkSize:
 */
- (void) sendBinaryText:(NSString*)text;
/**
 * Sends binary data to the peer device.
 * @param hex the binary data to send as a hex string
 * @see #sendDspsData:chunkSize:
 */
- (void) sendHexData:(NSString*)hex;
/**
 * Sends binary data to the peer device.
 * @param data the binary data to send
 * @see #sendDspsData:chunkSize:
 */
- (void) sendBinaryData:(NSData*)data;
/**
 * Sends binary data to the peer device.
 * @param data      the binary data to send
 * @param chunkSize the chunk size to use when splitting the data
 * @see #sendDspsData:chunkSize:
 */
- (void) sendBinaryData:(NSData*)data chunkSize:(int)chunkSize;
/**
 * Sends text data to the peer device.
 * @param text the text data to send
 * @see #sendDspsData:chunkSize:
 */
- (void) sendDspsText:(NSString*)text;
/**
 * Sends binary data to the peer device.
 * @param hex the binary data to send as a hex string
 * @see #sendDspsData:chunkSize:
 */
- (void) sendDspsHexData:(NSString*)hex;
/**
 * Sends binary data to the peer device.
 * @param data the binary data to send
 * @see #sendDspsData:chunkSize:
 */
- (void) sendDspsData:(NSData*)data;
/**
 * Sends binary data to the peer device.
 *
 * If the data size is less than the chunk size, the data are sent in one write operation.
 * Otherwise they are split into chunks which are enqueued to be sent in multiple writes.
 * When TX flow control is off, the data are kept in a buffer to be sent when flow control
 * is set to on by the peer device.
 *
 * WARNING: The chunk size must not exceed the value (MTU - 3), otherwise chunks will be truncated when sent.
 * @param data      the binary data to send
 * @param chunkSize the chunk size to use when splitting the data
 */
- (void) sendDspsData:(NSData*)data chunkSize:(int)chunkSize;

/**
 * Creates and starts a DSPS file send operation.
 * @param file      the file to send
 * @param chunkSize the chunk size to use when splitting the file
 * @param period    the chunks enqueueing period (ms).
 *                  Set to 0 to enqueue all chunks (may be slower for large files).
 * @return the DSPS file send operation
 */
- (DspsFileSend*) sendFile:(NSString*)file chunkSize:(int)chunkSize period:(int)period;
/**
 * Creates and starts a DSPS file send operation, using the current chunk size.
 * @param file      the file to send
 * @param period    the chunks enqueueing period (ms).
 *                  Set to 0 to enqueue all chunks (may be slower for large files).
 * @return the DSPS file send operation
 */
- (DspsFileSend*) sendFile:(NSString*)file period:(int)period;
/**
 * Creates and starts a DSPS file send operation, using the current chunk size.
 * <p> All chunks are enqueued at once (may be slower for large files).
 * @param file the file to send
 * @return the DSPS file send operation
 */
- (DspsFileSend*) sendFile:(NSString*)file;
/**
 * Starts or resumes a DSPS file send operation.
 * <p> WARNING: For internal use only. Use one of the {@link #sendFile:chunkSize:period: sendFile} methods instead.
 */
- (void) startFile:(DspsFileSend*)operation resume:(BOOL)resume;
/**
 * Stops a DSPS file send operation.
 * <p> WARNING: For internal use only. Use {@link DspsFileSend#stop} instead.
 */
- (void) stopFile:(DspsFileSend*)operation;
/**
 * Enqueues the next file chunk of a DSPS file send operation.
 * <p> WARNING: For internal use only.
 */
- (void) sendFileData:(DspsFileSend*)operation;
/**
 * Creates and starts a DSPS periodic pattern send operation.
 * @param file      the file containing the pattern prefix
 * @param chunkSize the pattern packet size
 * @param period    the packet enqueueing period (ms)
 * @return the DSPS periodic send operation
 */
- (DspsPeriodicSend*) sendPattern:(NSString*)file chunkSize:(int)chunkSize period:(int)period;
/**
 * Creates and starts a DSPS periodic pattern send operation, using the current chunk size.
 * @param file      the file containing the pattern prefix
 * @param period    the packet enqueueing period (ms)
 * @return the DSPS periodic send operation
 */
- (DspsPeriodicSend*) sendPattern:(NSString*)file period:(int)period;
/**
 * Creates and starts a DSPS periodic pattern send operation, using the current chunk size.
 * @param file the file containing the pattern prefix
 * @return the DSPS periodic send operation
 */
- (DspsPeriodicSend*) sendPattern:(NSString*)file;
/**
 * Starts or resumes a DSPS periodic send operation.
 * <p> WARNING: For internal use only. Use one of the {@link #sendPattern:chunkSize:period: sendPattern} or {@link DspsPeriodicSend#start} methods instead.
 */
- (void) startPeriodic:(DspsPeriodicSend*)operation;
/**
 * Stops a DSPS periodic send operation.
 * <p> WARNING: For internal use only. Use {@link DspsPeriodicSend#stop} instead.
 */
- (void) stopPeriodic:(DspsPeriodicSend*)operation;
/**
 * Enqueues the next packet of a DSPS periodic send operation.
 * <p> WARNING: For internal use only.
 */
- (void) sendPeriodicData:(DspsPeriodicSend*)operation;
/**
 * Starts a DSPS file receive operation.
 * <p> WARNING: For internal use only. Use {@link #receiveFile} instead.
 */
- (void) startFileReceive:(DspsFileReceive*)operation;
/**
 * Stops a DSPS file receive operation.
 * <p> WARNING: For internal use only. Use {@link DspsFileReceive#stop} instead.
 */
- (void) stopFileReceive:(DspsFileReceive*)operation;
/**
 * Creates and starts a DSPS file receive operation.
 * <p> Only a single file receive operation can be active.
 * @return the DSPS file receive operation
 */
- (DspsFileReceive*) receiveFile;

/// Checks if a GATT operation is pending.
- (BOOL) isGattOperationPending;

@end

NS_ASSUME_NONNULL_END
