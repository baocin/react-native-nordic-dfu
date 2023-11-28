# react-native-nordic-dfu [![npm version](https://badge.fury.io/js/react-native-nordic-dfu.svg)](https://badge.fury.io/js/react-native-nordic-dfu) [![CircleCI](https://circleci.com/gh/Pilloxa/react-native-nordic-dfu.svg?style=svg)](https://circleci.com/gh/Pilloxa/react-native-nordic-dfu) [![Known Vulnerabilities](https://snyk.io/test/github/pilloxa/react-native-nordic-dfu/badge.svg)](https://snyk.io/test/github/pilloxa/react-native-nordic-dfu)

This library allows you to do a Device Firmware Update (DFU) of your nrf51 or
nrf52 chip from Nordic Semiconductor. It works for both iOS and Android.

For more info about the DFU process, see: [Resources](#resources)

This is a fork from the main library!
If need the main documentation you can find it [here](https://github.com/Pilloxa/react-native-nordic-dfu).
This fork contains the latest verisons of `iOSDFULibrary` & `Android-BLE-Library`.

### Installation

Install and link the NPM package per usual with

```bash
npm install --save https://github.com/Salt-PepperEngineering/react-native-nordic-dfu
```

or

```bash
yarn add https://github.com/Salt-PepperEngineering/react-native-nordic-dfu
```

For React Native below 60.0 version

```bash
react-native link react-native-nordic-dfu
```

### Project Setup

Unfortunately, the ios project is written in Objective-C so you will need to use `use_frameworks! :linkage => :static`.
Note: We are considering rewriting the ios module on Swift, but it depends very much on how much free time we have and how much we needed right now.

`Podfile`:

```ruby
target "YourApp" do

  ...
  pod "react-native-nordic-dfu", path: "../node_modules/react-native-nordic-dfu"
  ...
  use_frameworks! :linkage => :static
  ...

end
```

`AppDelegate.mm`:

```
...
#import "RNNordicDfu.h"
...

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  ...

  [RNNordicDfu setCentralManagerGetter:^() {
           return [[CBCentralManager alloc] initWithDelegate:nil queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
       }];

         // Reset manager delegate since the Nordic DFU lib "steals" control over it
             [RNNordicDfu setOnDFUComplete:^() {
                 NSLog(@"onDFUComplete");
             }];
             [RNNordicDfu setOnDFUError:^() {
                 NSLog(@"onDFUError");
             }];
  ...

}
```

## Resources

- [DFU Introduction](http://infocenter.nordicsemi.com/topic/com.nordic.infocenter.sdk5.v11.0.0/examples_ble_dfu.html?cp=6_0_0_4_3_1 "BLE Bootloader/DFU")
- [Secure DFU Introduction](http://infocenter.nordicsemi.com/topic/com.nordic.infocenter.sdk5.v12.0.0/ble_sdk_app_dfu_bootloader.html?cp=4_0_0_4_3_1 "BLE Secure DFU Bootloader")
- [How to create init packet](https://github.com/NordicSemiconductor/Android-nRF-Connect/tree/master/init%20packet%20handling "Init packet handling")
- [nRF51 Development Kit (DK)](http://www.nordicsemi.com/eng/Products/nRF51-DK "nRF51 DK") (compatible with Arduino Uno Revision 3)
- [nRF52 Development Kit (DK)](http://www.nordicsemi.com/eng/Products/Bluetooth-Smart-Bluetooth-low-energy/nRF52-DK "nRF52 DK") (compatible with Arduino Uno Revision 3)
