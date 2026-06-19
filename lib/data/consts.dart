// Copyright 2025 Google LLC
// Flutter adaptation of Consts.kt

// Keys for model download state
const String keyModelUrl = "KEY_MODEL_URL";
const String keyModelName = "KEY_MODEL_NAME";
const String keyModelCommitHash = "KEY_MODEL_COMMIT_HASH";
const String keyModelDownloadModelDir = "KEY_MODEL_DOWNLOAD_MODEL_DIR";
const String keyModelDownloadFileName = "KEY_MODEL_DOWNLOAD_FILE_NAME";
const String keyModelTotalBytes = "KEY_MODEL_TOTAL_BYTES";
const String keyModelDownloadReceivedBytes =
    "KEY_MODEL_DOWNLOAD_RECEIVED_BYTES";
const String keyModelDownloadRate = "KEY_MODEL_DOWNLOAD_RATE";
const String keyModelDownloadRemainingMs =
    "KEY_MODEL_DOWNLOAD_REMAINING_SECONDS";
const String keyModelDownloadErrorMessage =
    "KEY_MODEL_DOWNLOAD_ERROR_MESSAGE";
const String keyModelDownloadAccessToken =
    "KEY_MODEL_DOWNLOAD_ACCESS_TOKEN";
const String keyModelExtraDataUrls = "KEY_MODEL_EXTRA_DATA_URLS";
const String keyModelExtraDataDownloadFileNames =
    "KEY_MODEL_EXTRA_DATA_DOWNLOAD_FILE_NAMES";
const String keyModelIsZip = "KEY_MODEL_IS_ZIP";
const String keyModelUnzippedDir = "KEY_MODEL_UNZIPPED_DIR";
const String keyModelStartUnzipping = "KEY_MODEL_START_UNZIPPING";

// Default values for LLM models
const int defaultMaxToken = 1024;
const int defaultTopK = 64;
const double defaultTopP = 0.95;
const double defaultTemperature = 1.0;

// Default accelerators
const List<String> defaultAccelerators = ["gpu"];
const String defaultVisionAccelerator = "gpu";

// Limits
const int maxImageCount = 10;
const int maxImageCountAiCore = 1;
const int maxRecommendedSkillCount = 15;
const int maxAudioClipCount = 1;
const int maxAudioClipDurationSec = 30;

// Audio recording
const int sampleRate = 16000;

// Misc
const double modelInfoIconSize = 18.0;
const String tmpFileExt = "gallerytmp";
