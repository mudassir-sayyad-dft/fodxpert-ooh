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

  static Future<bool> downloadAndSaveImage(String url, String id) async {
    var response = await http.get(Uri.parse(url));
    Uint8List bytes = response.bodyBytes;

    // Generate a timestamp for the filename
    // String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    String fileName = '$id.${basename(url).split(".").last}';
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
      print('Image saved to: $filePath');
      return true; // Move the return statement inside the try block
    } catch (e) {
      print('Error saving image: $e');
      rethrow; // Rethrow the exception to handle it elsewhere if needed
    }
  }
}
