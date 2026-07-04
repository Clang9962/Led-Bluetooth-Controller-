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
  late Color _selectedColor = Colors.red;
  late int _brightness = 255;
  late bool _isPowerOn = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await Provider.of<BleProvider>(context, listen: false).disconnect();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.device.platformName.isNotEmpty
              ? widget.device.platformName
              : 'XC610 Device'),
        ),
        body: Consumer<BleProvider>(
          builder: (context, bleProvider, _) {
            return SingleChildScrollView(
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
                          const Text('Log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: ListView.builder(
                              itemCount: bleProvider.notificationLog.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    bleProvider.notificationLog[index],
                                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, BleProvider bleProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SizedBox(
            height: 300,
            child: GridView.count(
              crossAxisCount: 4,
              children: [
                Colors.red,
                Colors.green,
                Colors.blue,
                Colors.yellow,
                Colors.purple,
                Colors.orange,
                Colors.cyan,
                Colors.pink,
                Colors.white,
                Colors.black,
              ]
                  .map((color) => GestureDetector(
                onTap: () {
                  setState(() => _selectedColor = color);
                  bleProvider.setColor(
                    _selectedColor.red,
                    _selectedColor.green,
                    _selectedColor.blue,
                  );
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(width: 2),
                  ),
                ),
              ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}
