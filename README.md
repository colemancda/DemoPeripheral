# DemoPeripheral
Make your ARM Linux device (e.g. BeagleBone, Raspberry Pi, Orange Pi) into an iBeacon and Bluetooth Low Energy peripheral with Swift.

## Setup (iOS)

1. Install Xcode 8 Beta 4
2. Install [Swift 3.0 2016-08-04 Snapshot](https://swift.org/builds/development/xcode/swift-DEVELOPMENT-SNAPSHOT-2016-08-04-a/swift-DEVELOPMENT-SNAPSHOT-2016-08-04-a-osx.pkg)

## Setup (Linux)


1. Install [Swift 3.0 for ARM Linux](http://dev.iachieved.it/iachievedit/swift-3-0-on-a-beaglebone-black/), make sure to use [2016-08-05 build](http://swift-arm.ddns.net/job/Swift-3.0-ARM-Incremental/93/artifact/swift-3.0-2016-08-05-BBB-ubuntu14.04.tar.gz).
2. Clone this repo `git clone https://github.com/colemancda/DemoPeripheral`
2. Go inside DemoPeripheral `cd DemoPeripheral`
3. Build (will generate errors) `swift build`
4. Patch code, in `Packages/CStatfs-1.0.0/module.modulemap` replace `x86_64-linux-gnu` with `arm-linux-gnueabihf`
5. Build again `swift build`
6. Run `sudo .build/debug/Peripheral`

You will see this logging in your console

```
Starting Peripheral Daemon...
Peripheral: Started GATT Server
Initialized Peripheral 0bd6311b-d0c9-425c-928b-89cc5bc0170c
```

You can also explore with [LightBlue](https://itunes.apple.com/us/app/lightblue-explorer-bluetooth/id557428110).
