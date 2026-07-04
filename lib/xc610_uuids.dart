// XC610 BLE UUIDs and commands

class Xc610Uuids {
  // Service UUID
  static const String serviceUuid = 'FF10';

  // Characteristic UUIDs
  static const String writeCharacteristicUuid = 'FF12';
  static const String notifyCharacteristicUuid = 'FF11';

  // Command prefix (DayBetter protocol)
  static const int commandPrefix = 0xA0;

  // Command bytes
  static const int powerOn = 0x01;
  static const int powerOff = 0x00;
  static const int brightness = 0x02;
  static const int color = 0x03;
  static const int mode = 0x04;
  static const int speed = 0x05;
}
