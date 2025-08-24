import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:string_similarity/string_similarity.dart';

typedef CommandCallback = void Function(String recognizedCommand);

class VoiceCommandService {
  stt.SpeechToText _speech = stt.SpeechToText();
  bool isListening = false;
  bool isAvailable = false;
  String lastCommand = '';
  List<String> commands = ['TAKE OFF', 'LAND'];

  CommandCallback? onCommandRecognized;

  VoiceCommandService({this.onCommandRecognized});

  /// Initialize and start listening
  Future<bool> startListening({
    VoidCallback? onListeningStarted,
    ValueChanged<String>? onError,
  }) async {
    if (isListening) {
      debugPrint('startListening called, but already listening');
      return false;
    }

    debugPrint('Initializing speech recognizer...');
    try {
      isAvailable = await _speech.initialize();
      debugPrint('Speech recognizer initialized: $isAvailable');
    } catch (e, stack) {
      isAvailable = false;
      debugPrint('Speech recognizer initialization failed: $e');
      debugPrint('$stack');
      onError?.call('Speech recognition not available');
      return false;
    }

    if (!isAvailable) {
      debugPrint('Speech recognition not available on this device');
      onError?.call('Speech recognition not available');
      return false;
    }

    debugPrint('Starting to listen...');
    isListening = true;
    onListeningStarted?.call();

    _speech.listen(
      onResult: (result) {
        lastCommand = result.recognizedWords;
        debugPrint('Recognized words: $lastCommand');
        String bestMatch = _findBestMatch(lastCommand);
        if (bestMatch.isNotEmpty && onCommandRecognized != null) {
          debugPrint('Best matched command: $bestMatch');
          onCommandRecognized!(bestMatch);
        }
      },
      listenMode: stt.ListenMode.confirmation,
    );

    return true;
  }

  void stopListening({VoidCallback? onListeningStopped}) {
    if (!isListening) {
      debugPrint('stopListening called, but not currently listening');
      return;
    }
    debugPrint('Stopping listening...');
    _speech.stop();
    isListening = false;
    onListeningStopped?.call();
  }

  String _findBestMatch(String command) {
    String bestMatch = '';
    double bestSimilarity = 0.0;

    for (String predefinedCommand in commands) {
      double similarity = command.similarityTo(predefinedCommand);
      if (similarity > bestSimilarity) {
        bestSimilarity = similarity;
        bestMatch = predefinedCommand;
      }
    }

    return bestMatch;
  }
}
