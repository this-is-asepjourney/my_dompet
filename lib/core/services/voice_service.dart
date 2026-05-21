// lib/core/services/voice_service.dart
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;

  Future<bool> initialize() async {
    return _speech.initialize(
      onStatus: (status) => debugPrint('Status: $status'),
      onError: (error) => debugPrint('Error: $error'),
    );
  }

  Future<String> listenForTransaction() async {
    if (!_isListening) {
      final available = await initialize();
      if (available) {
        _isListening = true;
        String? transcription;

        await _speech.listen(
          onResult: (result) {
            transcription = result.recognizedWords;
            _isListening = false;
          },
          listenOptions: SpeechListenOptions(
            listenFor: const Duration(seconds: 5),
            pauseFor: const Duration(seconds: 2),
          ),
        );

        return transcription ?? '';
      }
    }
    return '';
  }

  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }
}
