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

#import "CodelessBluetoothManager.h"
#import "CodelessLibEvent.h"
#import "CodelessLibLog.h"
#import "CodelessUtil.h"
#import "CodelessProfile.h"

@interface CodelessBluetoothManager ()

@property CBCentralManager* centralManager;
@property BOOL scanning;
@property NSNumber* pendingScanDuration;

@end

@implementation CodelessBluetoothManager

static NSString* const TAG = @"CodelessBluetoothManager";
+ (NSString*) TAG {
    return TAG;
}

- (id) init {
    self = [super init];
    if (!self)
        return nil;
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    return self;
}

+ (id) instance {
    static CodelessBluetoothManager* instance = nil;
    @synchronized(self) {
        if (!instance)
            instance = [[self alloc] init];
    }
    return instance;
}

- (void) startScanning {
    [self startScanning:0];
}

- (void) startScanning:(int)duration {
    [NSTimer cancelPreviousPerformRequestsWithTarget:self selector:@selector(scanTimer) object:nil];
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        self.pendingScanDuration = @(duration);
        return;
    }
    if (self.scanning)
        return;
    self.scanning = true;
    CodelessLog(TAG, @"Start scanning");
    [self.centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    if (duration > 0)
        [self performSelector:@selector(scanTimer) withObject:nil afterDelay:duration / 1000.];
    [self sendEvent:CodelessLibEvent.ScanStart object:[[CodelessScanStartEvent alloc] initWithManager:self]];
}

- (void) stopScanning {
    [NSTimer cancelPreviousPerformRequestsWithTarget:self selector:@selector(scanTimer) object:nil];
    self.pendingScanDuration = nil;
    if (!self.scanning)
        return;
    self.scanning = false;
    CodelessLog(TAG, @"Stop scanning");
    [self.centralManager stopScan];
    [self sendEvent:CodelessLibEvent.ScanStop object:[[CodelessScanStopEvent alloc] initWithManager:self]];
}

/// Timer to stop the Bluetooth scan automatically after the specified duration.
- (void) scanTimer {
    [self stopScanning];
}

- (void) connectToPeripheral:(CBPeripheral*)peripheral {
    CodelessLog(TAG, @"Connect peripheral: %@", peripheral);
    [self.centralManager connectPeripheral:peripheral options:nil];
}

- (void) disconnectPeripheral:(CBPeripheral*)peripheral {
    CodelessLog(TAG, @"Disconnect peripheral: %@", peripheral);
    [self.centralManager cancelPeripheralConnection:peripheral];
}

/**
 * Parses the raw advertising data to an {@link CodelessAdvData} object.
 * @param data the raw advertising data
 * @return the parsed advertising data
 */
- (CodelessAdvData*) parseAdvertisingData:(NSDictionary<NSString*, id>*)data {
    CodelessAdvData* advData = [CodelessAdvData new];
    advData.raw = data;
    advData.name = data[CBAdvertisementDataLocalNameKey];
    advData.connectable = [(NSNumber*) data[CBAdvertisementDataIsConnectable] boolValue];
    advData.services = data[CBAdvertisementDataServiceUUIDsKey];
    if (data[CBAdvertisementDataOverflowServiceUUIDsKey])
        advData.services = [advData.services arrayByAddingObjectsFromArray:data[CBAdvertisementDataOverflowServiceUUIDsKey]];
    if (data[CBAdvertisementDataManufacturerDataKey]) {
        CodelessByteBuffer* buffer = [CodelessByteBuffer wrap:data[CBAdvertisementDataManufacturerDataKey] order:CodelessByteBufferLittleEndian];
        if (buffer.remaining >= 2) {
            uint16_t manufacturer = [buffer getShort];
            NSData* manufacturerData = [buffer getData:buffer.remaining];
            advData.manufacturer = @{ @(manufacturer) : manufacturerData };
        }
    }

    advData.codeless = [advData.services containsObject:CodelessProfile.CODELESS_SERVICE_UUID];
    advData.dsps = [advData.services containsObject:CodelessProfile.DSPS_SERVICE_UUID];
    advData.suota = [advData.services containsObject:CodelessProfile.SUOTA_SERVICE_UUID];
    advData.iot = [advData.services containsObject:CodelessProfile.IOT_SERVICE_UUID];
    advData.wearable = [advData.services containsObject:CodelessProfile.WEARABLES_580_SERVICE_UUID] || [advData.services containsObject:CodelessProfile.WEARABLES_680_SERVICE_UUID];
    advData.mesh = [advData.services containsObject:CodelessProfile.MESH_PROVISIONING_SERVICE_UUID] || [advData.services containsObject:CodelessProfile.MESH_PROXY_SERVICE_UUID];
    advData.proximity = [advData.services containsObject:CodelessProfile.IMMEDIATE_ALERT_SERVICE_UUID] && [advData.services containsObject:CodelessProfile.LINK_LOSS_SERVICE_UUID];

    // Check for Dialog iBeacon
    NSData* manufacturerData = advData.manufacturer[@(CODELESS_DIALOG_MANUFACTURER_ID)];
    if (manufacturerData && manufacturerData.length == 23) {
        CodelessByteBuffer* buffer = [CodelessByteBuffer wrap:manufacturerData order:CodelessByteBufferBigEndian];
        // Check subtype/length
        if ([buffer get] == 2 && [buffer get] == 21) {
            advData.dialogBeacon = true;
            advData.iBeacon = false;
            advData.beaconUuid = [[NSUUID alloc] initWithUUIDBytes:(const uint8_t*)[buffer getData:16].bytes];
            advData.beaconMajor = [buffer getShort];
            advData.beaconMinor = [buffer getShort];
        }
    }

    // Check for Microsoft beacon
    manufacturerData = advData.manufacturer[@(CODELESS_MICROSOFT_MANUFACTURER_ID)];
    if (manufacturerData && manufacturerData.length == 27) {
        advData.microsoft = true;
    }

    return advData;
}

- (void) sendEvent:(NSString*)event object:(CodelessBluetoothEvent*)object {
    [NSNotificationCenter.defaultCenter postNotificationName:event object:self userInfo:@{ @"event" : object }];
}

#pragma mark - CBCentralManagerDelegate

/**
 * %CBCentralManagerDelegate <code>centralManagerDidUpdateState:</code> implementation.
 * <p> A {@link CodelessLibEvent#BluetoothState BluetoothState} event is generated.
 */
- (void) centralManagerDidUpdateState:(CBCentralManager*)central {
    CodelessLog(TAG, @"Bluetooth state changed to %d", (int) central.state);
    if (self.pendingScanDuration && central.state == CBCentralManagerStatePoweredOn) {
        int duration = self.pendingScanDuration.intValue;
        self.pendingScanDuration = nil;
        [self startScanning:duration];
    }
    [self sendEvent:CodelessLibEvent.BluetoothState object:[[CodelessBluetoothStateEvent alloc] initWithManager:self]];
}

/**
 * %CBCentralManagerDelegate <code>centralManager:didDiscoverPeripheral:advertisementData:RSSI:</code> implementation.
 * <p> A {@link CodelessLibEvent#ScanResult ScanResult} event is generated.
 */
- (void) centralManager:(CBCentralManager*)central didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber*)RSSI {
    CodelessLogOpt(CodelessLibLog.SCAN_RESULT, TAG, @"Discovered %@ [%@]: %@", peripheral.name, peripheral.identifier, advertisementData);
    [self sendEvent:CodelessLibEvent.ScanResult object:[[CodelessScanResultEvent alloc] initWithManager:self device:peripheral advData:[self parseAdvertisingData:advertisementData] rssi:RSSI]];
}

/**
 * %CBCentralManagerDelegate <code>centralManager:didConnectPeripheral:</code> implementation.
 * <p> A {@link CodelessLibEvent#DeviceConnected DeviceConnected} event is generated.
 */
- (void) centralManager:(CBCentralManager*)central didConnectPeripheral:(CBPeripheral*)peripheral {
    CodelessLog(TAG, @"Connected to device: %@", peripheral);
    [self sendEvent:CodelessLibEvent.DeviceConnected object:[[CodelessDeviceConnectedEvent alloc] initWithManager:self device:peripheral]];
}

/**
 * %CBCentralManagerDelegate <code>centralManager:didDisconnectPeripheral:error:</code> implementation.
 * <p> A {@link CodelessLibEvent#DeviceDisconnected DeviceDisconnected} event is generated.
 */
- (void) centralManager:(CBCentralManager*)central didDisconnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error {
    CodelessLog(TAG, @"Disconnected from device: %@", peripheral);
    [self sendEvent:CodelessLibEvent.DeviceDisconnected object:[[CodelessDeviceDisconnectedEvent alloc] initWithManager:self device:peripheral error:error]];
}

/**
 * %CBCentralManagerDelegate <code>centralManager:didFailToConnectPeripheral:error:</code> implementation.
 * <p> A {@link CodelessLibEvent#ConnectionFailed ConnectionFailed} event is generated.
 */
- (void) centralManager:(CBCentralManager*)central didFailToConnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error {
    CodelessLog(TAG, @"Failed to connect to device: %@", peripheral);
    [self sendEvent:CodelessLibEvent.ConnectionFailed object:[[CodelessConnectionFailedEvent alloc] initWithManager:self device:peripheral error:error]];
}

@end


@implementation CodelessAdvData

- (BOOL) other {
    return self.iot || self.wearable || self.mesh || self.proximity;
}

- (BOOL) beacon {
    return self.iBeacon || self.dialogBeacon || self.eddystone || self.microsoft;
}

- (BOOL) unknown {
    return !self.suota && !self.dsps && !self.other && !self.beacon;
}

@end
