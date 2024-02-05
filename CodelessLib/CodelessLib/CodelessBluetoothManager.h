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

NS_ASSUME_NONNULL_BEGIN

/**
 * Provides Bluetooth scan and connect functionality and advertising data parsing.
 *
 * It creates the %CBCentralManager API object and implements the %CBCentralManagerDelegate protocol.
 *
 * ## Usage ##
 * Create a %CodelessBluetoothManager {@link #instance object} from your UI code and register for the relevant scan events.
 * Use the {@link #startScanning} and {@link #stopScanning} methods to start and stop scanning.
 * A {@link CodelessLibEvent#ScanResult ScanResult} event is generated on each advertising event,
 * containing the found device and parsed advertising data.
 *
 * After a device is found, you can create a CodelessManager object for the device and {@link CodelessManager#connect connect} to it.
 * @see CodelessManager
 * @see CodelessLibEvent
 * @see CodelessAdvData
 */
@interface CodelessBluetoothManager : NSObject <CBCentralManagerDelegate>

@property (class, readonly) NSString* TAG;

/// The single CodelessBluetoothManager instance.
+ (CodelessBluetoothManager*) instance;

/**
 * Starts a Bluetooth scan with no set duration.
 * <p> A {@link CodelessLibEvent#ScanStart ScanStart} event is generated when scanning has started.
 * <p> The scan will continue until {@link #stopScanning} is called.
 */
- (void) startScanning;
/**
 * Starts a Bluetooth scan with the specified duration.
 * <p> A {@link CodelessLibEvent#ScanStart ScanStart} event is generated when scanning has started.
 * <p> The scan will stop automatically.
 * @param duration the scan duration (ms)
 */
- (void) startScanning:(int)duration;
/**
 * Stops the active Bluetooth scan.
 * <p> A {@link CodelessLibEvent#ScanStop ScanStop} event is generated when scanning has stopped.
 */
- (void) stopScanning;
/**
 * Used by the library to initiate the connection to the peer device.
 * @param peripheral the device to connect to
 * @see CodelessManager#connect
 */
- (void) connectToPeripheral:(CBPeripheral*)peripheral;
/**
 * Used by the library to disconnect from the peer device.
 * @param peripheral to device to disconnect from
 * @see CodelessManager#disconnect
 */
- (void) disconnectPeripheral:(CBPeripheral*)peripheral;

/// The associated CBCentralManager object.
@property (readonly) CBCentralManager* centralManager;
/// <code>true</code> if a Bluetooth scan is currently active.
@property (readonly) BOOL scanning;

@end


/**
 * Parsed advertising data.
 * <p> NOTE: The iOS Bluetooth stack filters the advertising data, so only a subset of the raw data is available.
 */
@interface CodelessAdvData : NSObject

enum {
    /// Dialog Semiconductor manufacturer ID.
    CODELESS_DIALOG_MANUFACTURER_ID = 0x00D2,
    /// Apple manufacturer ID.
    CODELESS_APPLE_MANUFACTURER_ID = 0x004C,
    /// Microsoft manufacturer ID.
    CODELESS_MICROSOFT_MANUFACTURER_ID = 0x0006,
};

/// The raw advertising data from the API.
@property NSDictionary<NSString*, id>* raw;
/// The advertised device name.
@property NSString* name;
/// <code>true</code> if the device is connectable.
@property BOOL connectable;
/// List of advertised services.
@property NSArray<CBUUID*>* services;
/// Manufacturer specific data (mapped by manufacturer ID).
@property NSDictionary<NSNumber*, NSData*>* manufacturer;

/// <code>true</code> if CodeLess service is advertised, <code>false</code> otherwise.
@property BOOL codeless;
/// <code>true</code> if DSPS service is advertised, <code>false</code> otherwise.
@property BOOL dsps;
/// <code>true</code> if SUOTA service is advertised, <code>false</code> otherwise.
@property BOOL suota;
/// <code>true</code> if Dialog IoT-Sensors service is advertised, <code>false</code> otherwise.
@property BOOL iot;
/// <code>true</code> if Dialog Wearable service is advertised, <code>false</code> otherwise.
@property BOOL wearable;
/// <code>true</code> if one of the Mesh services is advertised, <code>false</code> otherwise.
@property BOOL mesh;
/// <code>true</code> if the proximity profile services are advertised, <code>false</code> otherwise.
@property BOOL proximity;

/// <code>true</code> if the advertising data define an iBeacon.
@property BOOL iBeacon;
/// <code>true</code> if the advertising data define an iBeacon, using Dialog's manufacturer ID.
@property BOOL dialogBeacon;
/// The iBeacon UUID.
@property NSUUID* beaconUuid;
/// The iBeacon major number.
@property uint16_t beaconMajor;
/// The iBeacon minor number.
@property uint16_t beaconMinor;
/// <code>true</code> if the advertising data define an Eddystone beacon.
/// <p> NOTE: Checking for Eddystone beacons is not implemented.
@property BOOL eddystone;
/// <code>true</code> if the advertising data define a Microsoft beacon.
@property BOOL microsoft;

/// Checks if the advertising data contain known services other than Codeless, DSPS, SUOTA.
- (BOOL) other;
/// Checks if the advertising data define a beacon.
- (BOOL) beacon;
/// Checks if the advertising data do not contain any of the known services.
- (BOOL) unknown;

@end

NS_ASSUME_NONNULL_END
