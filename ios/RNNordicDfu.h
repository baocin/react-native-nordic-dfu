#import <CoreBluetooth/CoreBluetooth.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(RNNordicDfu, RCTEventEmitter)

RCT_EXTERN_METHOD(startDFU:(NSString *)deviceAddress
                  deviceName:(NSString *)deviceName
                  filePath:(NSString *)filePath
                  alternativeAdvertisingNameEnabled:(BOOL *)alternativeAdvertisingNameEnabled
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
