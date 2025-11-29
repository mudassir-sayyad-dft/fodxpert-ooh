// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fodex_new/view_model/controllers/getXControllers/user_controller.dart';
import 'package:get/get.dart';

import '../../controllers/function_controller.dart';

class AdsModel implements Comparable<AdsModel> {
  String fileName;
  String thumbnail = "";
  int index;
  RxString videoTemplateThumbnail = "".obs;

  // ✅ Add this flag to prevent duplicate generation
  bool _isGeneratingThumbnail = false;

  AdsModel({this.fileName = "", this.thumbnail = "", this.index = 0});

  static final baseUrl =
      "https://fodxpertandroid.s3.ap-south-1.amazonaws.com/${Get.find<UserController>().currentUser.managerID}/ads/";

  AdsModel.fromJson({required Map<String, dynamic> json})
      : fileName =
            "https://fodxpertandroid.s3.ap-south-1.amazonaws.com/${Get.find<UserController>().currentUser.managerID}/ads/${(json['fileName'] ?? '')}",
        thumbnail =
            json['thumbnail'] == null ? "" : '$baseUrl${json['thumbnail']}',
        index = json['index'] ?? 0;

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
