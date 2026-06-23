import 'dart:typed_data';
import 'litertlmengine.dart';
import 'litertlmloader.dart';

class AIManager {
  // Enforce a structured thread-safe Singleton design pattern
  AIManager._internal();
  static final AIManager instance = AIManager._internal();

  final LiteRTLLMEngine _llmEngine = LiteRTLLMEngine();
  final LiteRTModelLoader _modelLoader = LiteRTModelLoader();

  bool _isInitializing = false;

  bool isInitialized() => _llmEngine.isInitialized();
  bool isInitializing() => _isInitializing;
  String? getCurrentModelPath() => _llmEngine.getCurrentModelPath();

  /// Coordinates path validation and sets up the active C++ system layers
  Future<void> initialize(String modelPath) async {
    if (isInitialized() && getCurrentModelPath() == modelPath) return;
    if (_isInitializing) return;

    _isInitializing = true;
    try {
      // 1. Verify model storage parameters using the Loader module
      final verifiedFile = await _modelLoader.getLocalModelFile(modelPath);
      if (verifiedFile == null) {
        throw ArgumentError("Initialization aborted: File path invalid.");
      }

      _modelLoader.isModelValid(
        modelPath,
      ); // Logs warnings for non-litert extensions

      // 2. Load model into native execution memory
      await _llmEngine.initialize(verifiedFile.path);
    } finally {
      _isInitializing = false;
    }
  }

  /// Exposes the chat channel data stream to populate message bubble widgets
  Stream<String> generateResponseStreaming(
    String prompt, {
    Uint8List? imageBytes,
  }) {
    if (!isInitialized()) {
      return Stream.value(
        "System Error: Local assistant engine is not initialized.",
      );
    }
    return _llmEngine.generateResponseStreaming(prompt, imageBytes: imageBytes);
  }

  /// Instructs the engine to free RAM and close active sessions
  Future<void> close() async {
    await _llmEngine.close();
    print("Flutter Log [AIManager]: Resources released successfully.");
  }

  Future<void> reset() async {
    await close();
  }
}
