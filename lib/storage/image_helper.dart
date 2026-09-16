import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Copies a picked image into the app documents dir and returns the stored path.
class ImageHelper {
  static Future<String?> pickAndStore() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 1600);
    if (picked == null) return null;
    return _copyToAppDir(picked.path);
  }

  static Future<String> _copyToAppDir(String srcPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${dir.path}/media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    final ext = srcPath.split('.').last.toLowerCase();
    final target = '${mediaDir.path}/${const Uuid().v4()}.$ext';
    await File(srcPath).copy(target);
    return target;
  }

  /// Copies an arbitrary picked file (PDF, doc…) into the app dir so it
  /// survives OS cache purges. Returns the stored path.
  static Future<String> storeFile(String srcPath, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${dir.path}/media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    final safe = fileName.replaceAll(RegExp(r'[^\w\-. ]+'), '_');
    final target = '${mediaDir.path}/${const Uuid().v4()}_$safe';
    await File(srcPath).copy(target);
    return target;
  }

  static String baseName(String path) =>
      path.split(RegExp(r'[/\\]')).lastWhere((s) => s.isNotEmpty,
          orElse: () => path);
}
