import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import '../providers/ble_provider.dart';
import 'device_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Stream<List<ScanResult>> _scanResults;
  late Stream<bool> _isScanningStream;

  @override
  void initState() {
    super.initState();
    _scanResults = FlutterBluePlus.scanResults;
    _isScanningStream = FlutterBluePlus.isScanning;
    _attemptReconnect();
  }

  void _attemptReconnect() async {
    final bleProvider = Provider.of<BleProvider>(context, listen: false);
    await bleProvider.reconnectLast();
  }

  void _startScan() {
    FlutterBluePlus.startScan();
  }

  void _stopScan() {
    FlutterBluePlus.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('XC610 Controller'),
      ),
      body: Consumer<BleProvider>(
        builder: (context, bleProvider, _) {
          if (bleProvider.isConnected) {
            return DeviceScreen(device: bleProvider.connectedDevice!);
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _startScan,
                  child: const Text('Start Scan'),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<ScanResult>>(
                  stream: _scanResults,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: Text('No devices found'));
                    }

                    List<ScanResult> results = snapshot.data!;
                    return ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        ScanResult result = results[index];
                        return ListTile(
                          title: Text(result.device.platformName.isNotEmpty
                              ? result.device.platformName
                              : 'Unknown Device'),
                          subtitle: Text(result.device.remoteId.str),
                          trailing: Text('${result.rssi} dBm'),
                          onTap: () async {
                            _stopScan();
                            await bleProvider.connectToDevice(result.device);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
