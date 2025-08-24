import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:string_similarity/string_similarity.dart';
import '../models/drone_command.dart';

typedef DroneCommandCallback = void Function(DroneCommand? command);

class VoiceCommandService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool isListening = false;
  bool isAvailable = false;
  String lastCommand = '';

  /// Base commands (numeric values can be added later)
  final List<String> baseCommands = [
    'TAKE OFF',
    'LAND',
    'FLY FORWARD',
    'FLY UP',
  ];

  DroneCommandCallback? onCommandRecognized;

  VoiceCommandService({this.onCommandRecognized});

  /// Initialize and start listening
  Future<bool> startListening({
    VoidCallback? onListeningStarted,
    ValueChanged<String>? onError,
  }) async {
    if (isListening) return false;

    try {
      isAvailable = await _speech.initialize();
    } catch (e, stack) {
      isAvailable = false;
      debugPrint('Speech recognizer initialization failed: $e');
      debugPrint('$stack');
      onError?.call('Speech recognition not available');
      return false;
    }

    if (!isAvailable) {
      onError?.call('Speech recognition not available');
      return false;
    }

    isListening = true;
    onListeningStarted?.call();

    _speech.listen(
      onResult: (result) {
        lastCommand = result.recognizedWords.toUpperCase();
        debugPrint('Recognized words: $lastCommand');

        String? baseCommand = _findBestBaseCommand(lastCommand);
        if (baseCommand != null) {
          debugPrint('Best matched base command: $baseCommand');

          // Value left null here; screen will request numeric input if required
          double? value;
          if (requiresValue(baseCommand)) {
            debugPrint(
              'Command $baseCommand requires numeric value. Await user input.',
            );
          }

          onCommandRecognized?.call(
            DroneCommand(baseCommand: baseCommand, value: value),
          );
        } else {
          debugPrint('No matching command found');
          onCommandRecognized?.call(null);
        }
      },
      listenMode: stt.ListenMode.confirmation,
    );

    return true;
  }

  /// Stop listening
  void stopListening({VoidCallback? onListeningStopped}) {
    if (!isListening) return;

    _speech.stop();
    isListening = false;
    onListeningStopped?.call();
  }

  /// Public method: check if a command requires numeric input
  bool requiresValue(String baseCommand) {
    return baseCommand.startsWith('FLY FORWARD') ||
        baseCommand.startsWith('FLY UP');
  }

  /// Private method: find best matching base command
  String? _findBestBaseCommand(String command) {
    String? bestMatch;
    double bestSimilarity = 0.0;

    for (String predefinedCommand in baseCommands) {
      double similarity = command.similarityTo(predefinedCommand);
      if (similarity > bestSimilarity && similarity > 0.5) {
        bestSimilarity = similarity;
        bestMatch = predefinedCommand;
      }
    }

    return bestMatch;
  }
}
