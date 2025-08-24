import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';
import '../services/usb_service.dart';

class UsbTab extends StatefulWidget {
  final UsbService usbService;
  UsbTab({required this.usbService});

  @override
  _UsbTabState createState() => _UsbTabState();
}

class _UsbTabState extends State<UsbTab> {
  UsbDevice? selectedDevice;

  @override
  void initState() {
    super.initState();
    // Safe way to update state after widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.usbService.getDevices(() => setState(() {}));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButton<UsbDevice>(
            hint: Text('Select a USB Device'),
            value: selectedDevice,
            isExpanded: true,
            items: widget.usbService.devices.map((device) {
              return DropdownMenuItem<UsbDevice>(
                value: device,
                child: Text(device.productName ?? device.deviceId.toString()),
              );
            }).toList(),
            onChanged: (device) async {
              if (device != null) {
                setState(() {
                  selectedDevice = device;
                  widget.usbService.connectionStatus = 'Connecting...';
                });
                await widget.usbService.connectUsbDevice(
                  device,
                  () => setState(() {}),
                );
              }
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => widget.usbService.sendData("Hello ESP32"),
            child: Text('Send Data to ESP32'),
          ),
          SizedBox(height: 10),
          Text('Received Data:', style: TextStyle(fontWeight: FontWeight.bold)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(widget.usbService.receivedData),
          ),
          SizedBox(height: 20),
          Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(widget.usbService.connectionStatus),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                widget.usbService.disconnectUsbDevice(() => setState(() {})),
            child: Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}
