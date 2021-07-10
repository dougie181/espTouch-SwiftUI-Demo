# espTouchSwiftUIExample

## Background
For those of you that use the esp32 in your hardware projects, this is an example IOS SwiftUI project that configures the WiFi using the SmartConfig / ESP-Touch approach ([ESP-Touch](https://www.espressif.com/en/products/software/esp-touch/overview)).

If you use the Arduino IDE to program your esp32, then there already exists a sample sketch that should help getting this working for you ([WiFiSmartConfig](https://github.com/espressif/arduino-esp32/blob/master/libraries/WiFi/examples/WiFiSmartConfig/WiFiSmartConfig.ino)).

Espressif have an example app on the app store along with the base code available on github and as a CocoaPod.

This version was tested and working against IOS 14.0 (as at 10 July 2021).

##Requirements
- Xcode 12.5.1
- IOS 14.0 or later
- Xcode
- Cocoapods


## Installation
#### CocoaPods
To install cocoapods, please refer to [https://guides.cocoapods.org/using/getting-started.html](https://guides.cocoapods.org/using/getting-started.html), or 

```
% sudo gem install cocoapods
% pod setup
```
###Building the project
To run this project,

```
% git clone https://github.com/dougie181/espTouch-SwiftUI-Example.git
% cd espTouch-SwiftUI-Example
% pod install
```

**Note:** If you are getting the following log file entries when attempting to communicate with the esp32:

>client: sendto fail, but just ignore it
>: No route to host

Then it is likely that the cocoapods version of EspTouchforIOS is not the latest. I've used these additional steps to resolve.

```
% cd Pods
% rm -rf EspressifTouchSDK 
% git clone https://github.com/EspressifApps/EspressifTouchSDK.git
```

To build the project, make sure you open the xcworkspace file

```
% open esp32SmartConfigDemo.xcworkspace
```

## Acknowlegements
Thanks goes to the following:
* https://github.com/EspressifApp/EsptouchForIOS
* https://github.com/Jowsing/ESPTouchSwift

## License
espTouchSwiftUIExample is available under the MIT license. See the LICENSE file for more info.
