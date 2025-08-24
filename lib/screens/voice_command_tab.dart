import 'package:flutter/material.dart';
import '../services/voice_command_service.dart';

class VoiceCommandTab extends StatefulWidget {
  final VoiceCommandService voiceService;

  VoiceCommandTab({required this.voiceService});

  @override
  _VoiceCommandTabState createState() => _VoiceCommandTabState();

  // Static dialogs for reuse in main screen
  static Future<bool> showConfirmDialog(
    BuildContext context,
    String command,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Confirm Command'),
              content: Text('Do you want to execute "$command"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Reject'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Accept'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  static Future<double?> showValueInputDialog(
    BuildContext context,
    String command,
  ) async {
    TextEditingController controller = TextEditingController();
    return await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Specify value for "$command"'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Enter value in meters'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                double? value = double.tryParse(controller.text);
                Navigator.of(context).pop(value);
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}

class _VoiceCommandTabState extends State<VoiceCommandTab> {
  String commandStatus = 'No command recognized yet';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _toggleRecording,
            child: Text(
              widget.voiceService.isListening
                  ? 'Recording... Click to stop'
                  : 'Start Recording',
            ),
          ),
          SizedBox(height: 20),
          Text('Recognized Command: $commandStatus'),
        ],
      ),
    );
  }

  void _toggleRecording() async {
    if (widget.voiceService.isListening) {
      widget.voiceService.stopListening(
        onListeningStopped: () {
          setState(() {});
        },
      );
    } else {
      bool started = await widget.voiceService.startListening(
        onListeningStarted: () {
          setState(() {});
        },
        onError: (msg) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        },
      );
      if (!started) setState(() {});
    }
  }
}
