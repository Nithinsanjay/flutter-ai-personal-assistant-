// lib/data/model_backend.dart
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

class ModelBackend {
  /// Check if a model file is already downloaded
  Future<bool> isDownloaded(String fileName) async {
    if (kIsWeb) return false;
    final dir = await getApplicationDocumentsDirectory();
    final file = io.File("${dir.path}/$fileName");
    return file.exists();
  }

  /// Return a File reference for a model
  Future<io.File> getModelFile(String fileName) async {
    if (kIsWeb) throw UnsupportedError("File system access is not supported on Web");
    final dir = await getApplicationDocumentsDirectory();
    return io.File("${dir.path}/$fileName");
  }

  /// Simulate downloading a model (replace with Dio logic later)
  Future<void> downloadModel(
    String name,
    String fileName,
    String? url, {
    required void Function(double progress) onProgress,
  }) async {
    // Simulated download progress (replace with Dio later)
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      onProgress(i / 10.0);
    }

    if (kIsWeb) return;

    final dir = await getApplicationDocumentsDirectory();
    final file = io.File("${dir.path}/$fileName");
    await file.writeAsString("dummy model data for $name");
  }

  /// Initialize model (stubbed)
  Future<String> initializeModel(String name, String fileName) async {
    if (kIsWeb) {
      return "web_model_path";
    }
    final file = await getModelFile(fileName);
    if (!await file.exists()) {
      throw Exception("Model file not found: ${file.path}");
    }

    // TODO: add actual initialization logic (e.g., load runtime/interpreter)
    return file.path;
  }

  /// Disconnect model (stubbed)
  Future<void> disconnectModel() async {
    // TODO: add cleanup logic when runtime is added
    await Future.delayed(const Duration(milliseconds: 150));
  }

  /// Delete a model file
  Future<void> deleteModel(String fileName) async {
    if (kIsWeb) return;
    final file = await getModelFile(fileName);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
