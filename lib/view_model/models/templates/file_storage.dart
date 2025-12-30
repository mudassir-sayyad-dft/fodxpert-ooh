import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileStorage {
  static Future<String> getExternalDocumentPath() async {
    final downloadDir = await getTemporaryDirectory();
    Directory directory = Directory("${downloadDir.path}/fodx/templates");
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    final exPath = directory.path;

    // Creating the directory if it doesn't exist
    await directory.create(recursive: true);
    return exPath;
  }

  static Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();

    return "${directory.path}/fodx/templates";
  }

  static Future<bool> downloadAndSaveImage(String url, String id,
      {String? templateName}) async {
    var response = await http.get(Uri.parse(url));
    Uint8List bytes = response.bodyBytes;

    // Extract filename from URL or use provided templateName
    String urlFilename = basename(url).split("?").first; // Remove query params
    String fileName;

    if (templateName != null && templateName.isNotEmpty) {
      // Use provided template name and extract extension from URL
      String extension =
          urlFilename.contains('.') ? urlFilename.split('.').last : 'zip';
      fileName = '$templateName.$extension';
    } else {
      // Strip UUID prefix if filename follows pattern: "uuid-filename"
      // Example: "27311fb0-712e-43a6-b881-b2ba9474d8fc-Menu-1.zip" -> "Menu-1.zip"
      if (urlFilename.contains('-') &&
          urlFilename.split('-').first.length == 36) {
        // UUID is 36 chars (32 hex + 4 hyphens)
        fileName = urlFilename.substring(37); // Skip UUID and hyphen
      } else {
        fileName = urlFilename;
      }
    }

    // If we're dealing with a zip, force a consistent local name: <id>.zip
    final ext = fileName.toLowerCase();
    if (ext.endsWith('.zip')) {
      fileName = '$id.zip';
    }

    String filePath = join(await _localPath, id, fileName);
    File file = File(filePath);
    Directory dir = Directory(join(await _localPath, id));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    try {
      if (await file.exists()) {
        print('File exists, deleting...');
        await file.delete();
      }

      await file.writeAsBytes(bytes, flush: true);
      print('Template saved to: $filePath');
      return true;
    } catch (e) {
      print('Error saving template: $e');
      rethrow;
    }
  }
}
