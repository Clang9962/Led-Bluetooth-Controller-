# XC610 LED Bluetooth Controller

A Flutter app for controlling XC610 LED devices via Bluetooth Low Energy (BLE).

## Features

- **BLE Device Discovery**: Scan and connect to XC610 devices
- **Power Control**: Toggle LED on/off
- **Brightness Control**: Adjust brightness with a slider
- **Color Control**: Pick from preset colors
- **Connection Persistence**: Automatically reconnect to last device
- **Communication Log**: View BLE commands and notifications

## Requirements

- Flutter 3.0+
- iOS 12.0+
- Android 5.0+

## Installation

See [BUILDING.md](BUILDING.md) for build instructions.

## Protocol

- **Service UUID**: `FF10`
- **Write Characteristic**: `FF12`
- **Notify Characteristic**: `FF11`
- **Command Prefix**: `A0` (DayBetter protocol)

## Usage

1. Open the app
2. Tap "Start Scan" to find devices
3. Tap a device to connect
4. Use the controls to manage the LED
