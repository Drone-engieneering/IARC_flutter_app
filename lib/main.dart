import 'package:flutter/material.dart';
import 'screens/usb_device_screen.dart';

void main() {
  runApp(
    MaterialApp(title: 'ESP32 USB Communication', home: UsbDeviceScreen()),
  );
}
