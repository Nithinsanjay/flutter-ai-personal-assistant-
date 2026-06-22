// // lib/data/model_allowlist.dart

// import '../models/model.info.dart';

// class DefaultConfig {
//   final int? topK;
//   final double? topP;
//   final double? temperature;
//   final String? accelerators;
//   final String? visionAccelerator;
//   final int? maxContextLength;
//   final int? maxTokens;

//   DefaultConfig({
//     this.topK,
//     this.topP,
//     this.temperature,
//     this.accelerators,
//     this.visionAccelerator,
//     this.maxContextLength,
//     this.maxTokens,
//   });

//   factory DefaultConfig.fromJson(Map<String, dynamic> json) => DefaultConfig(
//     topK: json['topK'],
//     topP: (json['topP'] as num?)?.toDouble(),
//     temperature: (json['temperature'] as num?)?.toDouble(),
//     accelerators: json['accelerators'],
//     visionAccelerator: json['visionAccelerator'],
//     maxContextLength: json['maxContextLength'],
//     maxTokens: json['maxTokens'],
//   );
// }

// class AllowedModel {
//   final String name;
//   final String modelId;
//   final String modelFile;
//   final String commitHash;
//   final String description;
//   final int sizeInBytes;
//   final DefaultConfig defaultConfig;
//   final List<String> taskTypes;
//   final bool? llmSupportImage;
//   final bool? llmSupportAudio;
//   final bool? llmSupportTinyGarden;
//   final bool? llmSupportMobileActions;
//   final bool? llmSupportThinking;
//   final int? minDeviceMemoryInGb;
//   final List<String>? bestForTaskTypes;
//   final String? localModelFilePathOverride;
//   final String? url;

//   AllowedModel({
//     required this.name,
//     required this.modelId,
//     required this.modelFile,
//     required this.commitHash,
//     required this.description,
//     required this.sizeInBytes,
//     required this.defaultConfig,
//     required this.taskTypes,
//     this.llmSupportImage,
//     this.llmSupportAudio,
//     this.llmSupportTinyGarden,
//     this.llmSupportMobileActions,
//     this.llmSupportThinking,
//     this.minDeviceMemoryInGb,
//     this.bestForTaskTypes,
//     this.localModelFilePathOverride,
//     this.url,
//   });

//   factory AllowedModel.fromJson(Map<String, dynamic> json) => AllowedModel(
//     name: json['name'],
//     modelId: json['modelId'],
//     modelFile: json['modelFile'],
//     commitHash: json['commitHash'],
//     description: json['description'],
//     sizeInBytes: json['sizeInBytes'],
//     defaultConfig: DefaultConfig.fromJson(json['defaultConfig']),
//     taskTypes: List<String>.from(json['taskTypes']),
//     llmSupportImage: json['llmSupportImage'],
//     llmSupportAudio: json['llmSupportAudio'],
//     llmSupportTinyGarden: json['llmSupportTinyGarden'],
//     llmSupportMobileActions: json['llmSupportMobileActions'],
//     llmSupportThinking: json['llmSupportThinking'],
//     minDeviceMemoryInGb: json['minDeviceMemoryInGb'],
//     bestForTaskTypes: (json['bestForTaskTypes'] as List?)
//         ?.map((e) => e.toString())
//         .toList(),
//     localModelFilePathOverride: json['localModelFilePathOverride'],
//     url: json['url'],
//   );

//   /// Build Hugging Face download URL dynamically
//   String buildDownloadUrl() {
//     return url ??
//         "https://huggingface.co/$modelId/resolve/$commitHash/$modelFile";
//   }

//   /// Convert to your ModelInfo class
//   ModelInfo toModelInfo() {
//     return ModelInfo(
//       name: name,
//       sizeGB: sizeInBytes / (1024 * 1024 * 1024),
//       sizeInBytes: sizeInBytes,
//       description: description,
//       modelFile: modelFile,
//       modelId: modelId,
//       downloadUrl: buildDownloadUrl(),
//       commitHash: commitHash,
//       accelerators: defaultConfig.accelerators?.split(",") ?? [],
//       updateAvailable: false,
//       bestOverall: bestForTaskTypes != null && bestForTaskTypes!.isNotEmpty,
//       topK: defaultConfig.topK,
//       topP: defaultConfig.topP,
//       temperature: defaultConfig.temperature,
//       maxTokens: defaultConfig.maxTokens,
//       maxContextLength: defaultConfig.maxContextLength,
//       taskTypes: taskTypes,
//       capabilities: [
//         if (llmSupportImage == true) "image",
//         if (llmSupportAudio == true) "audio",
//         if (llmSupportTinyGarden == true) "tinyGarden",
//         if (llmSupportMobileActions == true) "mobileActions",
//         if (llmSupportThinking == true) "thinking",
//       ],
//       socToModelFiles: null,
//     );
//   }
// }

// class ModelAllowlist {
//   final List<AllowedModel> models;

//   ModelAllowlist({required this.models});

//   factory ModelAllowlist.fromJson(Map<String, dynamic> json) => ModelAllowlist(
//     models: (json['models'] as List)
//         .map((e) => AllowedModel.fromJson(e as Map<String, dynamic>))
//         .toList(),
//   );
// }
