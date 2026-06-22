// lib/data/download_repository.dart

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/model_info.dart';

enum DownloadStatusType {
  notDownloaded,
  inProgress,
  unzipping,
  succeeded,
  failed,
}

class DownloadStatus {
  final DownloadStatusType status;
  final int totalBytes;
  final int receivedBytes;
  final String? errorMessage;
  final int bytesPerSecond;
  final int remainingMs;

  DownloadStatus({
    required this.status,
    this.totalBytes = 0,
    this.receivedBytes = 0,
    this.errorMessage,
    this.bytesPerSecond = 0,
    this.remainingMs = 0,
  });
}

class DownloadRepository {
  final Dio _dio = Dio();

  Future<void> downloadModel(
    ModelInfo model,
    void Function(ModelInfo, DownloadStatus) onStatusUpdated,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final startTime = DateTime.now().millisecondsSinceEpoch;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = "${dir.path}/${model.modelFile}";

      model.localPath = savePath;
      model.status = "in_progress";

      await _dio.download(
        model.buildDownloadUrl(),
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final elapsed = DateTime.now().millisecondsSinceEpoch - startTime;
            final bytesPerSecond = elapsed > 0
                ? (received ~/ (elapsed / 1000))
                : 0;
            final remainingMs = bytesPerSecond > 0
                ? ((total - received) ~/ bytesPerSecond) * 1000
                : 0;

            model.progress = received / total;

            onStatusUpdated(
              model,
              DownloadStatus(
                status: DownloadStatusType.inProgress,
                totalBytes: total,
                receivedBytes: received,
                bytesPerSecond: bytesPerSecond,
                remainingMs: remainingMs,
              ),
            );
          }
        },
      );

      model.status = "succeeded";
      onStatusUpdated(
        model,
        DownloadStatus(status: DownloadStatusType.succeeded),
      );

      // Persist success
      await prefs.setString("${model.name}_path", savePath);
    } catch (e) {
      model.status = "failed";
      model.errorMessage = e.toString();

      onStatusUpdated(
        model,
        DownloadStatus(
          status: DownloadStatusType.failed,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> cancelDownload() async {
    _dio.close(force: true);
  }

  Future<void> clearAllDownloads() async {
    final dir = await getApplicationDocumentsDirectory();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
