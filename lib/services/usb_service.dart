import 'dart:async';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';

class UsbService {
  UsbPort? _port;
  UsbDevice? _device;
  List<UsbDevice> devices = [];
  String receivedData = '';
  String connectionStatus = 'No device connected';
  StreamSubscription<Uint8List>? _inputStreamSubscription;

  /// Get list of USB devices
  Future<void> getDevices(void Function() updateUI) async {
    devices = await UsbSerial.listDevices();
    updateUI();
  }

  /// Connect to a USB device
  Future<void> connectUsbDevice(
    UsbDevice device,
    void Function() updateUI,
  ) async {
    _device = device;

    try {
      _port = await device.create();
      if (_port == null) {
        connectionStatus = 'Failed to open port';
        updateUI();
        return;
      }

      await _port!.open();
      await _port!.setDTR(true);
      await _port!.setRTS(true);

      connectionStatus =
          'Device connected: ${_device?.productName ?? "Unknown"}';
      updateUI();

      // Start listening automatically
      _startListening(updateUI);
    } catch (e) {
      connectionStatus = 'Failed to connect: $e';
      updateUI();
    }
  }

  /// Send data to the connected device
  Future<void> sendData(String data) async {
    if (_port != null) {
      await _port!.write(Uint8List.fromList(data.codeUnits));
    }
  }

  /// Internal: start listening to incoming data
  void _startListening(void Function() updateUI) {
    _inputStreamSubscription?.cancel();
    if (_port?.inputStream != null) {
      _inputStreamSubscription = _port!.inputStream!.listen(
        (Uint8List data) {
          String newData = String.fromCharCodes(data);
          receivedData += newData;
          updateUI();
        },
        onError: (error) {
          connectionStatus = 'Error reading data: $error';
          updateUI();
        },
        cancelOnError: true,
      );
    }
  }

  /// Disconnect USB device
  Future<void> disconnectUsbDevice(void Function() updateUI) async {
    await _inputStreamSubscription?.cancel();
    await _port?.close();
    _device = null;
    _port = null;
    receivedData = '';
    connectionStatus = 'No device connected';
    updateUI();
  }

  void dispose() async {
    await _inputStreamSubscription?.cancel();
    await _port?.close();
  }
}
