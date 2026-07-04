import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import '../providers/ble_provider.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  Color _selectedColor = Colors.red;
  int _brightness = 255;
  bool _isPowerOn = true;

  void _showColorPicker(BuildContext context, BleProvider bleProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick Color'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.circle, color: Colors.red, size: 40),
              onPressed: () {
                setState(() => _selectedColor = Colors.red);
                bleProvider.setColor(255, 0, 0);
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.circle, color: Colors.green, size: 40),
              onPressed: () {
                setState(() => _selectedColor = Colors.green);
                bleProvider.setColor(0, 255, 0);
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.circle, color: Colors.blue, size: 40),
              onPressed: () {
                setState(() => _selectedColor = Colors.blue);
                bleProvider.setColor(0, 0, 255);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bleProvider = Provider.of<BleProvider>(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await bleProvider.disconnect();
        if (context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.device.platformName.isNotEmpty
              ? widget.device.platformName
              : 'XC610 Device'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Power Control
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Power', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Switch(
                        value: _isPowerOn,
                        onChanged: (value) {
                          setState(() => _isPowerOn = value);
                          bleProvider.setPower(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Brightness Control
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Brightness', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Slider(
                        value: _brightness.toDouble(),
                        min: 0,
                        max: 255,
                        divisions: 255,
                        label: _brightness.toString(),
                        onChanged: (value) {
                          setState(() => _brightness = value.toInt());
                        },
                        onChangeEnd: (value) {
                          bleProvider.setBrightness(_brightness);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Color Control
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Color', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _showColorPicker(context, bleProvider),
                        child: const Text('Pick Color'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notification Log
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Logs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          itemCount: bleProvider.notificationLog.length,
                          itemBuilder: (context, idx) => Text(bleProvider.notificationLog[idx]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
