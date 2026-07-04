import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/xc610_uuids.dart';

class BleProvider extends ChangeNotifier {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _notifyCharacteristic;
  bool _isConnected = false;
  int _rssi = 0;
  List<String> _notificationLog = [];

  // Getters
  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _isConnected;
  int get rssi => _rssi;
  List<String> get notificationLog => _notificationLog;

  late SharedPreferences _prefs;

  BleProvider() {
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Reconnect to last device
  Future<void> reconnectLast() async {
    await _initPreferences();
    String? lastDeviceId = _prefs.getString('lastDeviceId');
    if (lastDeviceId != null) {
      try {
        List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
        BluetoothDevice? device = devices.firstWhere(
          (d) => d.remoteId.str == lastDeviceId,
          orElse: () => throw Exception('Device not found'),
        );
        await connectToDevice(device);
      } catch (e) {
        if (kDebugMode) print('Failed to reconnect: $e');
      }
    }
  }

  // Connect to device
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      _isConnected = true;

      // Save device ID
      await _prefs.setString('lastDeviceId', device.remoteId.str);

      // Discover services
      await _discoverServices();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Connection error: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  // Discover services and characteristics
  Future<void> _discoverServices() async {
    if (_connectedDevice == null) return;

    try {
      List<BluetoothService> services = await _connectedDevice!.discoverServices();

      for (BluetoothService service in services) {
        if (service.uuid.str.toUpperCase() == Xc610Uuids.serviceUuid) {
          for (BluetoothCharacteristic char in service.characteristics) {
            if (char.uuid.str.toUpperCase() == Xc610Uuids.writeCharacteristicUuid) {
              _writeCharacteristic = char;
            }
            if (char.uuid.str.toUpperCase() == Xc610Uuids.notifyCharacteristicUuid) {
              _notifyCharacteristic = char;
              // Enable notifications
              if (char.properties.notify) {
                await _notifyCharacteristic!.setNotifyValue(true);
                _notifyCharacteristic!.onValueReceived.listen((List<int> value) {
                  _addNotificationLog('Received: ${value.map((e) => e.toRadixString(16)).join(' ')}')
                });
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('Service discovery error: $e');
    }
  }

  // Send command
  Future<void> sendCommand(List<int> command) async {
    if (_writeCharacteristic == null) return;

    try {
      // Add prefix
      List<int> fullCommand = [Xc610Uuids.commandPrefix, ...command];
      await _writeCharacteristic!.write(fullCommand);
      _addNotificationLog('Sent: ${fullCommand.map((e) => e.toRadixString(16)).join(' ')}')
    } catch (e) {
      if (kDebugMode) print('Send error: $e');
    }
  }

  // Power control
  Future<void> setPower(bool on) async {
    await sendCommand([Xc610Uuids.powerOn, on ? 1 : 0]);
  }

  // Brightness control
  Future<void> setBrightness(int brightness) async {
    brightness = brightness.clamp(0, 255);
    await sendCommand([Xc610Uuids.brightness, brightness]);
  }

  // Color control (RGB)
  Future<void> setColor(int r, int g, int b) async {
    await sendCommand([Xc610Uuids.color, r & 0xFF, g & 0xFF, b & 0xFF]);
  }

  // Disconnect
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (e) {
        if (kDebugMode) print('Disconnect error: $e');
      }
    }
    _connectedDevice = null;
    _isConnected = false;
    _writeCharacteristic = null;
    _notifyCharacteristic = null;
    notifyListeners();
  }

  // Add to notification log
  void _addNotificationLog(String message) {
    _notificationLog.insert(0, '${DateTime.now().toIso8601String()}: $message');
    if (_notificationLog.length > 50) {
      _notificationLog.removeLast();
    }
    notifyListeners();
  }
}
