import 'dart:io';

abstract class ModelLoader {
  /// Verifies if the target model path exists locally on storage.
  Future<File?> getLocalModelFile(String modelPath);

  /// Checks if the file suffix configuration matches structural parameters.
  bool isModelValid(String modelPath);
}
