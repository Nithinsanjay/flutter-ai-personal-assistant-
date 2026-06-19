// lib/models/model_info.dart

class ModelInfo {
  final String name;
  final double sizeGB;
  final int? sizeInBytes;
  final String description;
  final String modelFile;
  final String? modelId;
  final String? downloadUrl;
  final String commitHash;
  final List<String> accelerators;
  final bool updateAvailable;
  final bool bestOverall;
  final int? topK;
  final double? topP;
  final double? temperature;
  final int? maxTokens;
  final int? maxContextLength;
  final List<String>? taskTypes;
  final List<String>? capabilities;
  final Map<String, dynamic>? socToModelFiles;

  String status;
  double progress;
  String? localPath;
  String? errorMessage;

  ModelInfo({
    required this.name,
    required this.sizeGB,
    this.sizeInBytes,
    required this.description,
    required this.modelFile,
    this.modelId,
    this.downloadUrl,
    required this.commitHash,
    required this.accelerators,
    required this.updateAvailable,
    required this.bestOverall,
    this.topK,
    this.topP,
    this.temperature,
    this.maxTokens,
    this.maxContextLength,
    this.taskTypes,
    this.capabilities,
    this.socToModelFiles,
    this.status = 'download',
    this.progress = 0.0,
    this.localPath,
    this.errorMessage,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) => ModelInfo(
    name: json['name'],
    sizeGB: (json['sizeGB'] as num).toDouble(),
    sizeInBytes: json['sizeInBytes'],
    description: json['description'],
    modelFile: json['modelFile'],
    modelId: json['modelId'],
    downloadUrl: json['downloadUrl'] ?? json['url'],
    commitHash: json['commitHash'],
    accelerators: List<String>.from(json['accelerators']),
    updateAvailable: json['updateAvailable'],
    bestOverall: json['bestOverall'],
    topK: json['topK'],
    topP: (json['topP'] as num?)?.toDouble(),
    temperature: (json['temperature'] as num?)?.toDouble(),
    maxTokens: json['maxTokens'],
    maxContextLength: json['maxContextLength'],
    taskTypes: (json['taskTypes'] as List?)?.map((e) => e.toString()).toList(),
    capabilities: (json['capabilities'] as List?)
        ?.map((e) => e.toString())
        .toList(),
    socToModelFiles: json['socToModelFiles'],
  );

  /// Build Hugging Face download URL dynamically if not provided
  String buildDownloadUrl() {
    if (downloadUrl != null) return downloadUrl!;
    if (modelId != null && commitHash.isNotEmpty && modelFile.isNotEmpty) {
      return "https://huggingface.co/$modelId/resolve/$commitHash/$modelFile";
    }
    return "";
  }

  /// Hugging Face model page link
  String get learnMoreUrl =>
      modelId != null ? "https://huggingface.co/$modelId" : "";

  /// Normalize accelerator names
  List<String> getParsedAccelerators() =>
      accelerators.map((a) => a.toLowerCase()).toList();
}
