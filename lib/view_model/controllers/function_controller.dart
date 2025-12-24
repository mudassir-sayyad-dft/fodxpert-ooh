import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:fc_native_image_resize/fc_native_image_resize.dart';
import 'package:fodex_new/res/utils/utils.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FunctionsController {
  /// function to generate a random id (flutter)

  static generateId() {
    String characters =
        "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

    String id = "";

    String randomChoice() {
      Random random = Random();
      int index = random.nextInt(characters.length);
      return characters[index];
    }

    for (var i = 0; i < 7; i++) {
      String character = randomChoice();
      id += character;
    }

    return id;
  }

// Video To Thumnail Generator

  static Future<String?> getVideoThumbnail(String videoUrl) async {
    try {
      final fileName = await VideoThumbnail.thumbnailFile(
          video: videoUrl,
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: ImageFormat.PNG,
          maxHeight: 164,
          quality: 100,
          timeMs: 1200);
      print("Filename checker ;::::: $fileName");
      return fileName.path;
    } catch (e) {
      print("Error $e");
    }
    return null;
  }

  // Function used to check if the current file is video
  static bool checkFileIsVideo(String filePath) {
    List<String> videoFormats = [
      "mp4",
      "mov",
      "wmv",
      "avi",
      "avchd",
      "flv",
      "f4v",
      "swf",
      "mkv",
      "webm",
      "mpeg-2"
    ];
    try {
      final uri = Uri.parse(filePath);
      final path = uri.path; // safe: excludes query params
      final idx = path.lastIndexOf('.');
      if (idx >= 0 && idx < path.length - 1) {
        final ext = path.substring(idx + 1).toLowerCase();
        return videoFormats.contains(ext);
      }
    } catch (e) {
      // fall through to legacy check below
    }
    return (videoFormats
        .any((element) => filePath.toLowerCase().contains(".$element")));
  }

  static List<String> allowedFormats = [
    "mp4",
    "mov",
    "wmv",
    "avi",
    "avchd",
    "flv",
    "f4v",
    "swf",
    "mkv",
    "webm",
    "mpeg-2",
    "jpeg",
    "jpg",
    "png",
  ];

  static bool checkFileIsImage(String filePath) {
    List<String> imageFormats = [
      "jpeg",
      "jpg",
      "png",
    ];

    try {
      final uri = Uri.parse(filePath);
      final path = uri.path;
      final idx = path.lastIndexOf('.');
      if (idx >= 0 && idx < path.length - 1) {
        final ext = path.substring(idx + 1).toLowerCase();
        return imageFormats.contains(ext);
      }
    } catch (e) {
      // fall back
    }

    return (imageFormats
        .any((element) => filePath.toLowerCase().contains(".$element")));
  }

  static Future<String> resizeImage(File srcFile) async {
    final plugin = FcNativeImageResize();

    try {
      /// Resizes the [srcFile] image with the given options and saves the results
      /// to [destFile].
      ///
      /// [srcFile] source image path.
      /// [srcFileUri] true if source image is a Uri (Android/iOS/macOS).
      /// [destFile] destination image path.
      /// [width] destination image width.
      /// Pass -1 to adjust width based on height (keepAspectRatio must be true).
      /// [height] destination image height.
      /// Pass -1 to adjust height based on width (keepAspectRatio must be true).
      /// [keepAspectRatio] if true, keeps aspect ratio.
      /// [format] destination file format. 'png' or 'jpeg'.
      /// [quality] only applies to 'jpeg' type, 1-100 (100 best quality).

      // Extract the extension
      String extensionData = p.extension(srcFile.path); // -> ".jpg"

      // Extract the path without the extension
      String pathWithoutExtension =
          srcFile.path.substring(0, srcFile.path.length - extensionData.length);
      final String destinationPath =
          "${pathWithoutExtension}_${DateTime.now().millisecondsSinceEpoch}$extensionData";
      await plugin.resizeFile(
          srcFile: srcFile.path,
          destFile: destinationPath,
          width: 1080,
          height: 1920,
          keepAspectRatio: false,
          format: extensionData.split(".").last,
          quality: 90);

      return destinationPath;
    } catch (err) {
      // print("Error in resizing file");
      // print(err);
      // Handle platform errors.

      Utils.showInfoSnackbar(
          message:
              "Unable to change the resolution of image. Using the actual image...");
      return srcFile.path;
    }
  }

  // static Future<File> fileFromImageUrl({required String image}) async {
  //   final response = await http.get(Uri.parse(image));

  //   print("convert file response");
  //   print(response.body);
  //   print(response.bodyBytes);
  //   final documentDirectory = (await getDownloadsDirectory()) ??
  //       await getApplicationDocumentsDirectory();

  //   print(documentDirectory.path);
  //   final file = File([documentDirectory.path, 'imagetest.png']
  //       .join(documentDirectory.path.endsWith("/") ? "" : "/"));

  //   file.writeAsBytesSync(response.bodyBytes);

  //   return file;
  // }

  static Future<File> fileFromImageUrl({required String image}) async {
    try {
      final dio = Dio();
      final response = await dio.get(image,
          options: Options(responseType: ResponseType.bytes));

      final documentDirectory = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      String fileName;
      try {
        final uri = Uri.parse(image);
        fileName = uri.pathSegments.isNotEmpty
            ? Uri.decodeComponent(uri.pathSegments.last)
            : image.split('/').last;
      } catch (_) {
        fileName = image.split('/').last;
      }

      final file = File('${documentDirectory.path}/$fileName');

      await file.writeAsBytes(response.data);

      return file;
    } catch (e) {
      // Handle error
      print("Error: $e");
      rethrow; // Re-throwing the exception for the caller to handle
    }
  }

  static double durationToSeconds(String timeString) {
    List<String> parts = timeString.split(':'); // Split the string by colon
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    List<String> secondsParts = parts[2].split('.'); // Split seconds by dot
    int seconds = int.parse(secondsParts[0]);
    int milliseconds = int.parse(secondsParts[1]);

    Duration duration = Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );

    return duration.inMilliseconds / 1000; // Convert milliseconds to seconds
  }
}
