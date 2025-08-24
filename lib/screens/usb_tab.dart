import 'package:flutter/material.dart';
import '../services/usb_service.dart';

class UsbTab extends StatelessWidget {
  final UsbService usbService;

  UsbTab({required this.usbService});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButton(
            hint: Text('Select a USB Device'),
            items: usbService.devices.map((device) {
              return DropdownMenuItem(
                value: device,
                child: Text(device.deviceName),
              );
            }).toList(),
            onChanged: (device) {
              if (device != null) {
                usbService.connectUsbDevice(device, (_) => {});
              }
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => usbService.sendData("Hello ESP32"),
            child: Text('Send Data to ESP32'),
          ),
          ElevatedButton(
            onPressed: usbService.receiveData,
            child: Text('Receive Data from ESP32'),
          ),
          SizedBox(height: 20),
          Text('Received Data:'),
          Text(usbService.receivedData),
          SizedBox(height: 20),
          Text(usbService.connectionStatus),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: usbService.disconnectUsbDevice,
            child: Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}
