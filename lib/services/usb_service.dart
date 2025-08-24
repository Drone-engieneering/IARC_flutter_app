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

  void getDevices(void Function(void Function()) setState) async {
    devices = await UsbSerial.listDevices();
    setState(() {});
  }

  void connectUsbDevice(
    UsbDevice device,
    void Function(void Function()) setState,
  ) async {
    _device = device;
    try {
      _port = await device.create();
      await _port?.open();
      await _port?.setDTR(true);
      await _port?.setRTS(true);
      connectionStatus = 'Device connected: ${_device?.deviceName}';
      setState(() {});
    } catch (e) {
      connectionStatus = 'Failed to connect: $e';
      setState(() {});
    }
  }

  void sendData(String data) async {
    if (_port != null) {
      await _port?.write(Uint8List.fromList(data.codeUnits));
    }
  }

  void receiveData() async {
    if (_port != null && _port!.inputStream != null) {
      await _inputStreamSubscription?.cancel();
      _inputStreamSubscription = _port!.inputStream!.listen((Uint8List data) {
        receivedData = String.fromCharCodes(data);
      });
    }
  }

  void disconnectUsbDevice() {
    _inputStreamSubscription?.cancel();
    _port?.close();
    _device = null;
    _port = null;
    receivedData = '';
    connectionStatus = 'No device connected';
  }

  void dispose() {
    _inputStreamSubscription?.cancel();
    _port?.close();
  }
}
