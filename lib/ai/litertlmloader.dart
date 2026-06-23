import 'dart:io';
import 'model.dart';

class LiteRTModelLoader implements ModelLoader {
  static const String extensionLitertLm = "litertlm";

  @override
  Future<File?> getLocalModelFile(String modelPath) async {
    final file = File(modelPath);
    if (await file.exists()) {
      return file;
    }
    print(
      "Flutter Error [LiteRTModelLoader]: Target file path missing at $modelPath",
    );
    return null;
  }

  @override
  bool isModelValid(String modelPath) {
    final extension = modelPath.split('.').last.toLowerCase();
    if (extension != extensionLitertLm) {
      print(
        "Flutter Warning [LiteRTModelLoader]: Suffix '.$extension' does not match '.litertlm'",
      );
      return false;
    }
    return true;
  }
}
