// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fodex_new/view_model/controllers/getXControllers/user_controller.dart';
import 'package:get/get.dart';

import '../../controllers/function_controller.dart';

class AdsModel implements Comparable<AdsModel> {
  // `fileName` kept for backward compatibility and used as the network URL
  // when available. `displayName` holds the user-facing filename (may contain
  // spaces) useful for extension checks.
  String fileName;
  String displayName;
  String fileUrl;
  String thumbnail = "";
  int index;
  RxString videoTemplateThumbnail = "".obs;

  // ✅ Add this flag to prevent duplicate generation
  bool _isGeneratingThumbnail = false;

  AdsModel(
      {this.fileName = "",
      this.thumbnail = "",
      this.index = 0,
      this.displayName = "",
      this.fileUrl = ""});

  static final baseUrl =
      "https://fodxpertandroid.s3.ap-south-1.amazonaws.com/${Get.find<UserController>().currentUser.managerID}/ads/";

  AdsModel.fromJson({required Map<String, dynamic> json})
      :
        // New API returns full signed URL in `fileUrl`. Fall back to old
        // behaviour (construct URL) when `fileUrl` is not present.
        fileUrl = (json['fileUrl'] ?? json['file']) as String? ?? "",
        fileName = (json['fileUrl'] ?? json['file']) as String? ?? "",
        displayName = (json['fileName'] ?? json['file']) as String? ?? "",
        thumbnail = (json['thumbnail'] ?? json['previewUrl']) as String? ?? "",
        index = json['index'] ?? 0 {
    // If we only received a bare filename (old API), construct the full URL.
    if (fileName.isEmpty && json['fileName'] != null) {
      fileName =
          "https://fodxpertandroid.s3.ap-south-1.amazonaws.com/${Get.find<UserController>().currentUser.managerID}/ads/${(json['fileName'] ?? '')}";
      fileUrl = fileName;
    }

    // If displayName is still empty, try to derive from the `fileUrl` or `fileName`.
    if (displayName.isEmpty) {
      try {
        final uri = Uri.parse(fileUrl.isNotEmpty ? fileUrl : fileName);
        if (uri.pathSegments.isNotEmpty) {
          displayName = Uri.decodeComponent(uri.pathSegments.last);
        }
      } catch (_) {
        displayName = fileName.split('/').last;
      }
    }

    // If thumbnail is provided as a relative name, build full URL using baseUrl
    if (thumbnail.isNotEmpty && !thumbnail.startsWith('http')) {
      thumbnail = '$baseUrl$thumbnail';
    }
    // ensure fileName holds network URL when fileUrl exists
    if (fileUrl.isNotEmpty) {
      fileName = fileUrl;
    }
  }

  static Map<String, dynamic> toJson(String file) => <String, dynamic>{
        'file': file,
        'userID': Get.find<UserController>().currentUser.uid
      };

  generateThumbnail() async {
    if (FunctionsController.checkFileIsVideo(fileName)) {
      var data = (await FunctionsController.getVideoThumbnail(fileName));
      if (data != null) {
        thumbnail = data;
      }
    }
  }

  String originalFileName() {
    return displayName.isNotEmpty ? displayName : fileName.split('/').last;
  }

  bool isZipFile() {
    // Prefer the displayName for extension checks (it won't contain presigned
    // query params). If not available, examine the URL path segment.
    final name = originalFileName();
    return name.toLowerCase().endsWith('.zip');
  }

  /// Returns a short, user-friendly file name for display in lists.
  ///
  /// - If the server provides a `displayName` this is used.
  /// - If the name has a leading numeric timestamp like `1764686545429-Name.zip`,
  ///   the timestamp prefix will be removed returning `Name.zip`.
  /// - URL-encoded components will be decoded.
  String displayShortName() {
    final name = originalFileName();
    // Decode URL-encoded names if any (e.g. `%20` => space)
    String decoded = name;
    try {
      decoded = Uri.decodeComponent(name);
    } catch (_) {
      decoded = name;
    }

    // Remove leading timestamp-like prefix `digits-` if present
    final parts = decoded.split('-');
    if (parts.length > 1) {
      final first = parts.first;
      // if first part is numeric (timestamp), return rest joined
      if (RegExp(r'^\d{6,}$').hasMatch(first)) {
        return parts.sublist(1).join('-');
      }
    }

    return decoded;
  }

  generateVideoTemplateThumbnail() async {
    if (videoTemplateThumbnail.value.isNotEmpty || _isGeneratingThumbnail) {
      // print("Skipping: already generated or in progress.");
      return;
    }

    _isGeneratingThumbnail = true; // ✅ Start flag

    const maxAttempts = 24;
    const interval = Duration(seconds: 10);
    int attempts = 0;

    if (thumbnail.isNotEmpty &&
        FunctionsController.checkFileIsVideo(thumbnail)) {
      while (attempts < maxAttempts) {
        try {
          print("Attempt $attempts - Checking for video thumbnail");

          var data = await FunctionsController.getVideoThumbnail(thumbnail);

          if (data != null && data.isNotEmpty) {
            print("Thumbnail generation successful");
            videoTemplateThumbnail(data);
            break;
          } else {
            print("Thumbnail not ready yet. Retrying...");
          }
        } catch (e, stack) {
          print("Error while generating thumbnail: $e\n$stack");
        }

        await Future.delayed(interval);
        attempts++;
      }

      if (videoTemplateThumbnail.value.isEmpty) {
        print("Thumbnail generation timed out after $maxAttempts attempts.");
      }
    }

    _isGeneratingThumbnail = false; // ✅ End flag
  }

  bool checkIsVideo() {
    return FunctionsController.checkFileIsVideo(fileName);
  }

  bool checkIsImage() {
    return FunctionsController.checkFileIsImage(fileName);
  }

  @override
  int compareTo(AdsModel other) {
    return index.compareTo(other.index);
  }

  @override
  String toString() =>
      'AdsModel(fileName: $fileName, thumbnail: $thumbnail, index: $index)';
}
