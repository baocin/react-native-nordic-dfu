//
//  RNNordicDfu.swift
//  react-native-nordic-dfu
//
//  Created by Nickolans Griffith on 4/6/23.
//

import Foundation
import CoreBluetooth
import iOSDFULibrary

struct Constants {
    static let DFUProgressEvent = "DFUProgress"
    static let DFUStateChangedEvent = "DFUStateChanged"
}

@objc(RNNordicDfu)
class RNNordicDfu: RCTEventEmitter, DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate {
    
    private var deviceAddress: String = ""
    private var resolve: RCTPromiseResolveBlock?
    private var reject: RCTPromiseRejectBlock?
    private var centralManager: CBCentralManager?
    
    override func supportedEvents() -> [String]! {
        return [Constants.DFUProgressEvent, Constants.DFUStateChangedEvent]
    }
    
    func stateDescription(state: DFUState) -> String {
        switch state {
        case .aborted:
            return "DFU_ABORTED"
        case .starting:
            return "DFU_PROCESS_STARTING"
        case .completed:
            return "DFU_COMPLETED"
        case .uploading:
            return "DFU_STATE_UPLOADING"
        case .connecting:
            return "CONNECTING"
        case .validating:
            return "FIRMWARE_VALIDATING"
        case .disconnecting:
            return "DEVICE_DISCONNECTING"
        case .enablingDfuMode:
            return "ENABLING_DFU_MODE"
        default:
            return "UNKNOWN_STATE"
        }
    }
    
    func errorDescription(error: DFUError) -> String {
      switch(error) {
      case .crcError:
          return "DFUErrorCrcError";
      case .bytesLost:
          return "DFUErrorBytesLost";
      case .fileInvalid:
          return "DFUErrorFileInvalid";
      case .failedToConnect:
          return "DFUErrorFailedToConnect";
      case .fileNotSpecified:
          return "DFUErrorFileNotSpecified";
      case .bluetoothDisabled:
          return "DFUErrorBluetoothDisabled";
      case .deviceDisconnected:
          return "DFUErrorDeviceDisconnected";
      case .deviceNotSupported:
          return "DFUErrorDeviceNotSupported";
      case .initPacketRequired:
          return "DFUErrorInitPacketRequired";
      case .unsupportedResponse:
          return "DFUErrorUnsupportedResponse";
      case .readingVersionFailed:
          return "DFUErrorReadingVersionFailed";
      case .remoteLegacyDFUSuccess:
          return "DFUErrorRemoteLegacyDFUSuccess";
      case .remoteSecureDFUSuccess:
          return "DFUErrorRemoteSecureDFUSuccess";
      case .serviceDiscoveryFailed:
          return "DFUErrorServiceDiscoveryFailed";
      case .remoteLegacyDFUCrcError:
          return "DFUErrorRemoteLegacyDFUCrcError";
      case .enablingControlPointFailed:
          return "DFUErrorEnablingControlPointFailed";
      case .extendedInitPacketRequired:
          return "DFUErrorExtendedInitPacketRequired";
      case .receivingNotificationFailed:
          return "DFUErrorReceivingNotificationFailed";
      case .remoteButtonlessDFUSuccess:
          return "DFUErrorRemoteButtonlessDFUSuccess";
      case .remoteLegacyDFUInvalidState:
          return "DFUErrorRemoteLegacyDFUInvalidState";
      case .remoteLegacyDFUNotSupported:
          return "DFUErrorRemoteLegacyDFUNotSupported";
      case .writingCharacteristicFailed:
          return "DFUErrorWritingCharacteristicFailed";
      case .remoteSecureDFUExtendedError:
          return "DFUErrorRemoteSecureDFUExtendedError";
      case .remoteSecureDFUInvalidObject:
          return "DFUErrorRemoteSecureDFUInvalidObject";
      case .remoteLegacyDFUOperationFailed:
          return "DFUErrorRemoteLegacyDFUOperationFailed";
      case .remoteSecureDFUOperationFailed:
          return "DFUErrorRemoteSecureDFUOperationFailed";
      case .remoteSecureDFUUnsupportedType:
          return "DFUErrorRemoteSecureDFUUnsupportedType";
      case .remoteLegacyDFUDataExceedsLimit:
          return "DFUErrorRemoteLegacyDFUDataExceedsLimit";
      case .remoteSecureDFUInvalidParameter:
          return "DFUErrorRemoteSecureDFUInvalidParameter";
      case .remoteSecureDFUSignatureMismatch:
          return "DFUErrorRemoteSecureDFUSignatureMismatch";
      case .remoteSecureDFUOpCodeNotSupported:
          return "DFUErrorRemoteSecureDFUOpCodeNotSupported";
      case .remoteButtonlessDFUOperationFailed:
          return "DFUErrorRemoteButtonlessDFUOperationFailed";
      case .remoteSecureDFUInsufficientResources:
          return "DFUErrorRemoteSecureDFUInsufficientResources";
      case .remoteSecureDFUOperationNotPermitted:
          return "DFUErrorRemoteSecureDFUOperationNotPermitted";
      case .remoteButtonlessDFUOpCodeNotSupported:
          return "DFUErrorRemoteButtonlessDFUOpCodeNotSupported";
      case .remoteExperimentalButtonlessDFUSuccess:
          return "DFUErrorRemoteExperimentalButtonlessDFUSuccess";
      case .remoteExperimentalButtonlessDFUOperationFailed:
          return "DFUErrorRemoteExperimentalButtonlessDFUOperationFailed";
      case .remoteExperimentalButtonlessDFUOpCodeNotSupported:
          return "DFUErrorRemoteExperimentalButtonlessDFUOpCodeNotSupported";
        default:
          return "UNKNOWN_ERROR";
      }
    }
    
    func dfuStateDidChange(to state: iOSDFULibrary.DFUState) {
        var evtBody: Dictionary = ["deviceAddress": deviceAddress, "state": stateDescription(state: state)]
        sendEvent(withName: Constants.DFUStateChangedEvent, body: evtBody)
        
        if (state == .completed) {
            var resolveBody: Dictionary = ["deviceAddress": deviceAddress]
            if let resolve = resolve {
                resolve(resolveBody)
            }
        }
    }
    
    func dfuError(_ error: iOSDFULibrary.DFUError, didOccurWithMessage message: String) {
        let evtBody: Dictionary = ["deviceAddress": self.deviceAddress,
                                   "state": "DFU_FAILED"];

        sendEvent(withName: Constants.DFUStateChangedEvent, body: evtBody)
    }
    
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        let evtBody: [String : Any] = [
            "deviceAddress": self.deviceAddress,
            "currentPart": NSNumber(value: part),
            "partsTotal": NSNumber(value: totalParts),
            "speed": NSNumber(value: currentSpeedBytesPerSecond),
            "avgSpeed": NSNumber(value: avgSpeedBytesPerSecond)
        ]
        
        sendEvent(withName: Constants.DFUProgressEvent, body: evtBody)
    }
    
    func logWith(_ level: iOSDFULibrary.LogLevel, message: String) {
        print("logWith: \(level) message: \(message)")
    }
    
    @objc func startDFU(_ deviceAddress: String, deviceName: String, filePath: String, alternativeAdvertisingNameEnabled: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        self.resolve = resolve
        self.reject = reject
        self.deviceAddress = deviceAddress
        
        guard let manager = self.centralManager else {
            reject("nil_central_manager", "Call to getCentralManager returned nil", nil)
            return
        }
        
        guard let uuid = UUID(uuidString: deviceAddress) else {
            reject("invalid_device_address", "Device address is invalid", nil)
            return
        }
        
        sleep(1)
        
        let peripherals: [CBPeripheral] = manager.retrievePeripherals(withIdentifiers: [uuid])
        
        if (peripherals.isEmpty) {
            reject("unable_to_find_device", "Could not find device with deviceAddress", nil)
            return
        }
        
        if let peripheral = peripherals.first, let url = URL(string: filePath) {
            let firmware = DFUFirmware(urlToZipFile: url)
            let initator = DFUServiceInitiator()
            initator.logger = self
            initator.delegate = self
            initator.progressDelegate = self
            initator.alternativeAdvertisingNameEnabled = alternativeAdvertisingNameEnabled
            initator.packetReceiptNotificationParameter = 1
            sleep(2)
            let _ = initator.start(target: peripheral)
        }
    }
}
