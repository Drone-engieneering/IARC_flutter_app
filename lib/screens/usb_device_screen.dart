import 'package:flutter/material.dart';
import '../services/usb_service.dart';
import '../services/voice_command_service.dart';

class UsbDeviceScreen extends StatefulWidget {
  @override
  _UsbDeviceScreenState createState() => _UsbDeviceScreenState();
}

class _UsbDeviceScreenState extends State<UsbDeviceScreen> {
  final UsbService _usbService = UsbService();
  late VoiceCommandService _voiceService;

  String commandStatus = 'No command recognized yet';

  @override
  void initState() {
    super.initState();
    _usbService.getDevices(setState);

    _voiceService = VoiceCommandService(
      onCommandRecognized: (command) {
        setState(() {
          commandStatus = command;
        });
        // Optionally, send to ESP immediately:
        _usbService.sendData(command);
      },
    );
  }

  @override
  void dispose() {
    _usbService.dispose();
    _voiceService.stopListening();
    super.dispose();
  }

  void _toggleRecording() async {
    if (_voiceService.isListening) {
      _voiceService.stopListening(
        onListeningStopped: () {
          setState(() {}); // updates button text
        },
      );
    } else {
      bool started = await _voiceService.startListening(
        onListeningStarted: () {
          setState(() {}); // updates button text
        },
        onError: (msg) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        },
      );
      if (!started) {
        setState(() {}); // ensures button text stays correct
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ESP32 USB Communication')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton(
                hint: Text('Select a USB Device'),
                items: _usbService.devices.map((device) {
                  return DropdownMenuItem(
                    value: device,
                    child: Text(device.deviceName),
                  );
                }).toList(),
                onChanged: (device) {
                  if (device != null) {
                    _usbService.connectUsbDevice(device, setState);
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _toggleRecording,
                child: Text(
                  _voiceService.isListening
                      ? 'Recording... Click to stop'
                      : 'Start Recording',
                ),
              ),
              SizedBox(height: 10),
              Text('Recognized Command: $commandStatus'),
              Divider(height: 40),
              ElevatedButton(
                onPressed: () => _usbService.sendData("Hello ESP32"),
                child: Text('Send Data to ESP32'),
              ),
              ElevatedButton(
                onPressed: _usbService.receiveData,
                child: Text('Receive Data from ESP32'),
              ),
              SizedBox(height: 20),
              Text('Received Data:'),
              Text(_usbService.receivedData),
              SizedBox(height: 20),
              Text(_usbService.connectionStatus),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _usbService.disconnectUsbDevice,
                child: Text('Disconnect'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
