import 'dart:io';

class FileSizeHelper {
  static const int maxRecommendedLines = 500;
  static const int maxRecommendedBytes = 20000;

  static Map<String, int> getFileSize(String filePath) {
    final file = File(filePath);
    final sizeInBytes = file.lengthSync();
    final lines = file.readAsLinesSync().length;
    return {
      'bytes': sizeInBytes,
      'lines': lines,
    };
  }

  static bool isFileTooLarge(String filePath) {
    final size = getFileSize(filePath);
    return size['bytes']! > maxRecommendedBytes || size['lines']! > maxRecommendedLines;
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
