import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../core/model_backend.dart';
import '../models/model_info.dart';
import '../ai/gemma_service.dart';

class ModelViewModel extends ChangeNotifier {
  final ModelBackend _modelBackend = ModelBackend();
  List<ModelInfo> models = [];

  ModelInfo? get connectedModel {
    for (final model in models) {
      if (model.status == 'connected') return model;
    }
    return null;
  }

  Future<void> loadModels() async {
    final data = await rootBundle.loadString('assets/modelsInfo/models.json');
    final jsonResult = json.decode(data);
    models = (jsonResult['models'] as List)
        .map((e) => ModelInfo.fromJson(e))
        .toList();

    for (final model in models) {
      final isDownloaded = await _modelBackend.isDownloaded(model.modelFile);
      if (isDownloaded) {
        final file = await _modelBackend.getModelFile(model.modelFile);
        model.status = 'downloaded';
        model.localPath = file.path;
      }
    }
    notifyListeners();
  }

  void updateModelStatus(ModelInfo model, String newStatus) {
    model.status = newStatus;
    notifyListeners();
  }

  Future<void> startDownload(ModelInfo model) async {
    model.status = 'downloading';
    model.progress = 0.0;
    model.errorMessage = null;
    notifyListeners();

    try {
      await _modelBackend.downloadModel(
        model.name,
        model.modelFile,
        model.buildDownloadUrl(),
        onProgress: (progress) {
          final clamped = progress.clamp(0.0, 1.0).toDouble();
          // Always let the first non-zero progress through (breaks 0% stuck),
          // then throttle to every 1% change to keep UI rebuilds low.
          final isFirstUpdate = model.progress == 0.0 && clamped > 0.0;
          final crossedThreshold = (clamped - model.progress).abs() >= 0.01;
          if (isFirstUpdate || crossedThreshold || clamped == 1.0) {
            model.progress = clamped;
            notifyListeners();
          }
        },
      );

      final file = await _modelBackend.getModelFile(model.modelFile);
      model.status = 'downloaded';
      model.progress = 0.0;
      model.localPath = file.path;
      notifyListeners();
    } catch (error) {
      model.status = 'download';
      model.progress = 0.0;
      model.errorMessage = error is DownloadCancelledException
          ? null
          : error.toString();
      notifyListeners();
    }
  }

  void cancelDownload(ModelInfo model) {
    _modelBackend.cancelDownload(model.modelFile);
    model.status = 'download';
    model.progress = 0.0;
    model.errorMessage = null;
    notifyListeners();
  }

  Future<void> connectModel(ModelInfo model) async {
    model.status = 'connecting';
    model.errorMessage = null;
    notifyListeners();

    final exists = await _modelBackend.isDownloaded(model.modelFile);
    if (!exists) {
      model.status = 'download';
      model.localPath = null;
      model.errorMessage =
          "Model file not found at local path. Please download it again.";
      notifyListeners();
      return;
    }

    try {
      await GemmaService.instance.dispose();
      model.localPath = await _modelBackend.initializeModel(
        model.name,
        model.modelFile,
      );
      await GemmaService.instance.initialize();

      bool hadConnected = false;
      for (final m in models) {
        if (m != model && m.status == 'connected') {
          m.status = 'downloaded';
          hadConnected = true;
        }
      }
      if (hadConnected) await _modelBackend.disconnectModel();

      model.status = 'connected';
      notifyListeners();
    } catch (error) {
      model.status = 'downloaded';
      model.errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> disconnectModel(ModelInfo model) async {
    await _modelBackend.disconnectModel();
    await GemmaService.instance.dispose();
    model.status = 'downloaded';
    model.errorMessage = null;
    notifyListeners();
  }

  Future<void> deleteModel(ModelInfo model) async {
    try {
      await _modelBackend.deleteModel(model.modelFile);
      model.status = 'download';
      model.progress = 0.0;
      model.localPath = null;
      model.errorMessage = null;
      notifyListeners();
    } catch (error) {
      model.errorMessage = error.toString();
      notifyListeners();
    }
  }
}
