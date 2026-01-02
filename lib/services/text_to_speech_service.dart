import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class TextToSpeechService {
  static final TextToSpeechService _instance = TextToSpeechService._internal();
  factory TextToSpeechService() => _instance;
  TextToSpeechService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  // Initialize text-to-speech
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set up event handlers
      _tts.setStartHandler(() {
        _isSpeaking = true;
        print('TTS started');
      });

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        print('TTS completed');
      });

      _tts.setErrorHandler((message) {
        _isSpeaking = false;
        print('TTS error: $message');
      });

      _tts.setCancelHandler(() {
        _isSpeaking = false;
        print('TTS cancelled');
      });

      // Configure TTS settings
      await _configureTts();

      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize text-to-speech: $e');
    }
  }

  Future<void> _configureTts() async {
    // Set language
    await _tts.setLanguage('en-US');

    // Set speech rate (0.0 - 1.0, default 0.5)
    await _tts.setSpeechRate(0.5);

    // Set volume (0.0 - 1.0, default 1.0)
    await _tts.setVolume(1.0);

    // Set pitch (0.5 - 2.0, default 1.0)
    await _tts.setPitch(1.0);

    // Platform-specific settings
    if (!kIsWeb) {
      // iOS specific settings
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    }
  }

  // Speak text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isSpeaking) {
      await stop();
    }

    try {
      await _tts.speak(text);
    } catch (e) {
      print('Failed to speak: $e');
    }
  }

  // Stop speaking
  Future<void> stop() async {
    if (_isSpeaking) {
      await _tts.stop();
      _isSpeaking = false;
    }
  }

  // Pause speaking
  Future<void> pause() async {
    if (_isSpeaking) {
      await _tts.pause();
    }
  }

  // Set speech rate (0.0 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate.clamp(0.0, 1.0));
  }

  // Set volume (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    await _tts.setVolume(volume.clamp(0.0, 1.0));
  }

  // Set pitch (0.5 - 2.0)
  Future<void> setPitch(double pitch) async {
    await _tts.setPitch(pitch.clamp(0.5, 2.0));
  }

  // Set language
  Future<void> setLanguage(String languageCode) async {
    await _tts.setLanguage(languageCode);
  }

  // Get available languages
  Future<List<dynamic>> getLanguages() async {
    return await _tts.getLanguages ?? [];
  }

  // Get available voices
  Future<List<dynamic>> getVoices() async {
    return await _tts.getVoices ?? [];
  }

  // Set voice
  Future<void> setVoice(Map<String, String> voice) async {
    await _tts.setVoice(voice);
  }

  // Get current engine
  Future<String?> getEngine() async {
    return await _tts.getDefaultEngine;
  }

  // Check if speaking
  bool isSpeakingNow() {
    return _isSpeaking;
  }

  // Speak confirmation message for task creation
  Future<void> speakTaskConfirmation(String taskTitle) async {
    await speak('Task created: $taskTitle');
  }

  // Speak confirmation message for event creation
  Future<void> speakEventConfirmation(String eventTitle) async {
    await speak('Event scheduled: $eventTitle');
  }

  // Speak error message
  Future<void> speakError(String error) async {
    await speak('Sorry, $error');
  }

  // Speak welcome message
  Future<void> speakWelcome() async {
    await speak('Welcome to Listo, your personal assistant');
  }
}
