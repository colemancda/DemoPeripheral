# DemoPeripheral
PureSwift/BluetoothLinux Example

# Setup

## Clone this repo

    git clone https://github.com/colemancda/DemoPeripheral

## Go inside DemoPeripheral

    cd DemoPeripheral

## Build (will generate errors)

    swift build

## Patch code

In

    Packages/CStatfs-1.0.0/module.modulemap

Replace

    x86_64-linux-gnu
   
by

    arm-linux-gnueabihf

## Build again

    swift build

## Run

    sudo .build/debug/Peripheral

You will see this logging in your console

    Starting Peripheral Daemon...
    Peripheral: Started GATT Server
    Initialized Peripheral 0bd6311b-d0c9-425c-928b-89cc5bc0170c

You can explore with [LightBlue](https://itunes.apple.com/us/app/lightblue-explorer-bluetooth/id557428110
)
