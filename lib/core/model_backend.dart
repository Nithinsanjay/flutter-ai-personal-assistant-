import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';
import 'package:background_downloader/background_downloader.dart';

class DownloadCancelledException implements Exception {
  final String message;
  DownloadCancelledException(this.message);
  @override
  String toString() => message;
}

class ModelBackend {
  // Simple tracker to hold active tasks so they can be explicitly cancelled
  final Map<String, DownloadTask> _runningTasks = {};

  Future<bool> isDownloaded(String fileName) async {
    if (kIsWeb) return false;
    final dir = await getApplicationDocumentsDirectory();
    final file = io.File("${dir.path}/$fileName");
    return file.exists();
  }

  Future<io.File> getModelFile(String fileName) async {
    if (kIsWeb) {
      throw UnsupportedError("File system access is not supported on Web");
    }
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

    // Check if notification permission is granted. If not, request it so that
    // the foreground service notification can display (preventing the 10-minute timeout).
    final status = await FileDownloader().permissions.status(PermissionType.notifications);
    if (status != PermissionStatus.granted) {
      await FileDownloader().permissions.request(PermissionType.notifications);
    }

    // Configure a foreground-service notification so Android promotes the
    // WorkManager worker to a foreground service — bypassing the 10-minute
    // execution timeout that was causing cancellations at ~50-65%.
    FileDownloader().configureNotification(
      running: TaskNotification(
        'Downloading $name',
        'Progress: {progress}',
      ),
      complete: TaskNotification(
        'Download complete',
        '$name is ready to use',
      ),
      error: TaskNotification(
        'Download failed',
        'Could not download $name',
      ),
      progressBar: true,
    );

    final task = DownloadTask(
      url: url,
      filename: fileName,
      baseDirectory: BaseDirectory.applicationDocuments,
      updates: Updates.statusAndProgress,
      retries: 3, // auto-retry on transient network drops
      allowPause: false,
    );

    _runningTasks[fileName] = task;
    debugPrint("Enqueuing direct background download for: $fileName");

    final result = await FileDownloader().download(
      task,
      onProgress: (progress) {
        if (progress >= 0.0) {
          onProgress(progress);
        }
      },
    );

    if (_runningTasks[fileName]?.taskId == task.taskId) {
      _runningTasks.remove(fileName);
    }

    switch (result.status) {
      case TaskStatus.complete:
        debugPrint("Download completed successfully for $fileName");
        break;
      case TaskStatus.canceled:
        throw DownloadCancelledException("Download cancelled by user");
      case TaskStatus.failed:
        throw Exception(
          "Download failed: ${result.exception?.description ?? 'Unknown Error'}",
        );
      default:
        throw Exception("Download terminated with status: ${result.status}");
    }
  }

  Future<void> cancelDownload(String fileName) async {
    final task = _runningTasks[fileName];
    if (task != null) {
      await FileDownloader().cancelTasksWithIds([task.taskId]);
      _runningTasks.remove(fileName);
    } else {
      // Fallback fallback scan matching underlying pool filenames
      final tasks = await FileDownloader().allTasks();
      final activeTask = tasks.firstWhere(
        (t) => t.filename == fileName,
        orElse: () =>
            throw Exception("No active download found for file: $fileName"),
      );
      await FileDownloader().cancelTasksWithIds([activeTask.taskId]);
    }
  }

  Future<String> initializeModel(String name, String fileName) async {
    final file = await getModelFile(fileName);
    if (!await file.exists()) {
      throw Exception('Model file not found');
    }

    final ModelType modelType;
    final String lowerName = name.toLowerCase();
    if (lowerName.contains('gemma-4') || lowerName.contains('gemma4')) {
      modelType = ModelType.gemma4;
    } else if (lowerName.contains('qwen3')) {
      modelType = ModelType.qwen3;
    } else if (lowerName.contains('qwen')) {
      modelType = ModelType.qwen;
    } else if (lowerName.contains('gemma')) {
      modelType = ModelType.gemmaIt;
    } else {
      modelType = ModelType.general;
    }

    await FlutterGemma.installModel(
      modelType: modelType,
      fileType: ModelFileType.litertlm,
    ).fromFile(file.path).install();

    return file.path;
  }

  Future<void> disconnectModel() async =>
      await Future.delayed(const Duration(milliseconds: 150));

  Future<void> deleteModel(String fileName) async {
    if (kIsWeb) return;
    final file = await getModelFile(fileName);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
