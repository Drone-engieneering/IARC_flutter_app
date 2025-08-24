import 'package:flutter/material.dart';
import '../services/usb_service.dart';
import 'usb_tab.dart';
import '../services/voice_command_service.dart';
import 'voice_command_tab.dart';

class UsbDeviceScreen extends StatefulWidget {
  @override
  _UsbDeviceScreenState createState() => _UsbDeviceScreenState();
}

class _UsbDeviceScreenState extends State<UsbDeviceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UsbService _usbService = UsbService();
  late VoiceCommandService _voiceService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Safe call to setState after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _usbService.getDevices(() => setState(() {}));
    });

    _voiceService = VoiceCommandService(
      onCommandRecognized: (command) async {
        if (command == null) return;

        bool confirmed = await VoiceCommandTab.showConfirmDialog(
          context,
          command.baseCommand,
        );

        if (!confirmed) return;

        double? finalValue = command.value;
        if (_voiceService.requiresValue(command.baseCommand)) {
          finalValue = await VoiceCommandTab.showValueInputDialog(
            context,
            command.baseCommand,
          );
          if (finalValue == null) return;
        }

        _usbService.sendData('${command.baseCommand} ${finalValue ?? ''}');
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usbService.dispose();
    _voiceService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ESP32 USB & Voice Control'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'USB'),
            Tab(text: 'Voice Commands'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          UsbTab(usbService: _usbService),
          VoiceCommandTab(voiceService: _voiceService),
        ],
      ),
    );
  }
}
