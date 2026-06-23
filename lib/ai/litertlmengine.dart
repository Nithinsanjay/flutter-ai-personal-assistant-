import 'package:flutter/services.dart';
import 'dart:typed_data';

class LiteRTLLMEngine {
  static const MethodChannel _methodChannel = MethodChannel(
    'source.app.ai/llm_bridge',
  );

  String? _currentModelPath;
  bool _isInitialized = false;

  bool isInitialized() => _isInitialized;
  String? getCurrentModelPath() => _currentModelPath;

  /// Commands the native Kotlin engine to run its GPU -> CPU hardware fallback setup
  Future<void> initialize(String modelPath) async {
    try {
      await _methodChannel.invokeMethod('initialize', {'modelPath': modelPath});
      _isInitialized = true;
      _currentModelPath = modelPath;
    } on PlatformException catch (e) {
      _isInitialized = false;
      _currentModelPath = null;
      throw Exception("Native Engine Initialization Error: ${e.message}");
    }
  }

  /// Maps down to the Kotlin Flow to push streaming output tokens back to the UI
  Stream<String> generateResponseStreaming(
    String prompt, {
    Uint8List? imageBytes,
  }) async* {
    if (!_isInitialized)
      throw StateError("Cannot stream data. Engine is not active.");

    final String uniqueRequestId = DateTime.now().millisecondsSinceEpoch
        .toString();

    try {
      await _methodChannel.invokeMethod('startStreaming', {
        'requestId': uniqueRequestId,
        'prompt': prompt,
        'imageBytes': imageBytes,
      });
    } on PlatformException catch (e) {
      yield "Native Stream Failure: ${e.message}";
      return;
    }

    // Connect to the specific streaming channel matching the active prompt request
    final EventChannel responseChannel = EventChannel(
      'source.app.ai/llm_stream_$uniqueRequestId',
    );

    await for (final dynamic tokenChunk
        in responseChannel.receiveBroadcastStream()) {
      if (tokenChunk is String) {
        yield tokenChunk;
      }
    }
  }

  /// Releases local memory allocations and shuts down background structures
  Future<void> close() async {
    try {
      await _methodChannel.invokeMethod('close');
    } finally {
      _isInitialized = false;
      _currentModelPath = null;
    }
  }
}
