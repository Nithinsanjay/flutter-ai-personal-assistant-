// lib/data/model_backend.dart
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class DownloadCancelledException implements Exception {
  final String message;
  DownloadCancelledException(this.message);
  @override
  String toString() => message;
}

class ModelBackend {
  final Map<String, CancelToken> _downloadTokens = {};

  /// Check if a model file is already downloaded
  Future<bool> isDownloaded(String fileName) async {
    if (kIsWeb) return false;
    final dir = await getApplicationDocumentsDirectory();
    final file = io.File("${dir.path}/$fileName");
    return file.exists();
  }

  /// Return a File reference for a model
  Future<io.File> getModelFile(String fileName) async {
    if (kIsWeb)
      throw UnsupportedError("File system access is not supported on Web");
    final dir = await getApplicationDocumentsDirectory();
    return io.File("${dir.path}/$fileName");
  }

  Future<void> downloadModel(
    String name,
    String fileName,
    String? url, {
    required void Function(double progress) onProgress,
  }) async {
    if (url == null || url.isEmpty) {
      throw Exception("Download URL is empty");
    }

    print("Starting download");
    print("URL = $url");

    final dir = await getApplicationDocumentsDirectory();
    final savePath = "${dir.path}/$fileName";

    print("Saving to:");
    print(savePath);

    final dio = Dio();
    final cancelToken = CancelToken();
    _downloadTokens[fileName] = cancelToken;

    try {
      await dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;

            print(
              "Downloaded $received / $total (${(progress * 100).toStringAsFixed(1)}%)",
            );

            onProgress(progress);
          }
        },
      );
      print("Download completed");
    } on DioException catch (e) {
      // Clean up partial file
      final file = io.File(savePath);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }

      if (e.type == DioExceptionType.cancel) {
        throw DownloadCancelledException("Download cancelled by user");
      }
      rethrow;
    } catch (e) {
      // Clean up partial file
      final file = io.File(savePath);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
      rethrow;
    } finally {
      _downloadTokens.remove(fileName);
    }
  }

  void cancelDownload(String fileName) {
    final token = _downloadTokens[fileName];
    if (token != null) {
      token.cancel("User cancelled download");
    }
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
