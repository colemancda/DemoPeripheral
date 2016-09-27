# DemoPeripheral
Turn your ARM Linux device (e.g. BeagleBone, Raspberry Pi, Orange Pi) into an iBeacon and Bluetooth Low Energy peripheral with Swift. Includes iOS app for interacting with the peripheral via Bluetooth.

## Setup (iOS)

Install [Carthage](https://github.com/Carthage/Carthage) dependencies 

```
carthage update
```

## Setup (Linux)


1. Install [Swift 3.0 for ARM Linux](http://dev.iachieved.it/iachievedit/swift-3-0-on-a-beaglebone-black/), make sure to use [2016-09-26 build](http://swift-arm.ddns.net/job/Swift-3.0-ARMv7-ubuntu1410/lastSuccessfulBuild/artifact/swift-3.0-2016-09-26-armv7-ubuntu14.04.tar.gz).
2. Install `BluetoothLinux` [dependencies](https://github.com/PureSwift/BluetoothLinux#dependencies).
3. Clone and Build (will generate errors)

```
git clone https://github.com/colemancda/DemoPeripheral
cd DemoPeripheral
swift build
```

4. Patch code, in `Packages/CStatfs-1.0.0/module.modulemap` replace `x86_64-linux-gnu` with `arm-linux-gnueabihf`
6. Build and run 

```
swift build
sudo .build/debug/Peripheral
```

## Interaction

You should see the following in your console

```
Starting Peripheral Daemon...
Peripheral: Started GATT Server
Initialized Peripheral 0bd6311b-d0c9-425c-928b-89cc5bc0170c
```

You can also explore with [LightBlue](https://itunes.apple.com/us/app/lightblue-explorer-bluetooth/id557428110).
