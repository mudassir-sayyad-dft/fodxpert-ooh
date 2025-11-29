// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:downloadsfolder/downloadsfolder.dart' as dw;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fodex_new/View/Components/buttons/border_btn.dart';
import 'package:fodex_new/View/Components/buttons/expanded_btn.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/repository/ads_repository.dart';
import 'package:fodex_new/res/colors.dart';
import 'package:fodex_new/res/utils/utils.dart';
import 'package:fodex_new/view_model/controllers/function_controller.dart';
import 'package:fodex_new/view_model/models/Ads/ads_model.dart';
import 'package:fodex_new/view_model/models/screens_model/screens_model.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class AdsController extends GetxController {
  String _selectedScreen = "";

  String get selectedScreen => _selectedScreen;

  setSelectedScreen(String screenId) {
    _selectedScreen = screenId;
    update();
  }

  String _selectedScreenName = "";

  String get selectedScreenName => _selectedScreenName;

  setSelectedScreenName(String screenName) {
    _selectedScreenName = screenName;
    update();
  }

  ScreensModel _selectedScreenData = ScreensModel();
  ScreensModel get selectedScreenData => _selectedScreenData;

  setSelectedScreenData(ScreensModel screen) {
    _selectedScreenData = screen;
    update();
  }

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool status) {
    _loading = status;
    update();
  }

  final _repo = AdsRepository();

  List<AdsModel> _ads = [];

  List<AdsModel> get ads => _ads;

  setAds(List<AdsModel> data) {
    _ads = data;
    update();
  }

  pushAd(AdsModel ad) {
    _ads.add(ad);
    update();
  }

  _updateAdIndex(int index) {}

  _updateAdData(AdsModel ad, String previousFileName) {
    int i = _ads.indexWhere((element) => element.fileName == previousFileName);

    if (i >= 0) {
      _ads[i] = ad;
      update();
    }
  }

  updatePlaylistForScreen(List<AdsModel> adsData) async {
    setLoading(true);
    try {
      final response = await _repo.updatePlaylistForScreen(
          ads: adsData, screenId: _selectedScreen);
    } catch (e) {
      Utils.showErrorSnackbar(message: e.toString(), showLogout: true);
    } finally {
      setLoading(false);
    }
  }

  static Future<void> preloadThumbnails(List<AdsModel> ads) async {
    await Future.wait(ads.map((ad) => ad.generateVideoTemplateThumbnail()));
  }

  static Future<void> preloadVideoThumbnails(List<AdsModel> ads) async {
    await Future.wait(ads.map((ad) => ad.generateThumbnail()));
  }

  Future<void> getAds() async {
    setLoading(true);
    try {
      final response = await _repo.getAds(_selectedScreen);

      final data = response;

      // preloadThumbnails(data);
      // preloadVideoThumbnails(data);
      for (var e in data) {
        e.generateThumbnail();
        e.generateVideoTemplateThumbnail();
      }

      setAds(data);
      ads.sort((a, b) => a.compareTo(b));
    } catch (e) {
      print(e);
      Utils.showErrorSnackbar(
          message: "Something Went Wrong. Try Again Later!", showLogout: true);
    }
    setLoading(false);
  }

  Future<void> deleteAd({required String fileName}) async {
    setLoading(true);
    try {
      final response = await _repo.deleteCreative(
          videoData: (fileName: fileName, screenId: _selectedScreen));
      if (response != null) {
        _ads.removeWhere(
            (element) => element.fileName.trim() == fileName.trim());
      }
    } catch (e) {
      Utils.showErrorSnackbar(message: e.toString(), showLogout: true);
    }

    setLoading(false);
  }

  Future<void> addNewAd(File file,
      {required String fileName,
      File? previousFile,
      required String sampleTemplateName,
      bool isZip = false,
      String templateType = ""}) async {
    // setLoading(true);
    try {
      print("Add new add try working here --->>");
      final response = await _repo.addNewAd(
          file: file,
          _selectedScreen,
          fileName: fileName,
          screenName: _selectedScreenName,
          sampleTemplateName: sampleTemplateName,
          isZip: isZip,
          templateType: templateType);

      if (previousFile != null) {
        if (await previousFile.exists()) {
          await previousFile.delete();
        }
      }

      // if (!isZip) {
      if (await file.exists()) {
        await file.delete();
        // Utils.showSuccessSnackbar(
        //     message: "Condition working step 4 done........");
        // }
      }

      // await downloadFile(url: response.fileName);
      // await response.generateThumbnail();
      // Utils.showSuccessSnackbar(message: "Got Thumbail step 5 done........");
      pushAd(response);
    } catch (e) {
      print("Error in addNewAd");
      print(e.toString());
      rethrow;
      // Utils.showErrorSnackbar(message: e.toString());
    }
  }

  Future<void> updateAd(File file,
      {required String previousFileNetworkUrl,
      required String previousFileUrl,
      bool isZip = false,
      String templateType = ""}) async {
    // setLoading(true);
    try {
      final response = await _repo.updateCreative(
          screenName: _selectedScreenName,
          file: file,
          screenId: selectedScreen,
          isZip: isZip,
          fileName: previousFileNetworkUrl.split("/").last,
          templateType: templateType);
      print(response);
      print(response.fileName);
      print('*****************');
      if (!isZip) {
        if (await file.exists()) {
          await file.delete();
        }
        await response.generateThumbnail();
      } else {
        await response.generateVideoTemplateThumbnail();
      }
      if (previousFileUrl.isNotEmpty && await File(previousFileUrl).exists()) {
        await File(previousFileUrl).delete();
      }
      _updateAdData(response, previousFileNetworkUrl);
    } catch (e) {
      rethrow;
      // Utils.showErrorSnackbar(message: e.toString());
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  final _platform = const MethodChannel('com.fodx.fodxpertooh/open_folder');

  final Rx<bool> _isFileDownload = false.obs;
  bool get isFileDownload => _isFileDownload.value;

  setIsFileDownload(bool v) {
    _isFileDownload(v);
  }

  final Rx<String> _downloadProgress = "".obs;
  String get downloadProgress => _downloadProgress.value;

  setDownloadProgress(String v) {
    _downloadProgress(v);
  }

  Future<void> downloadFile({
    required BuildContext context,
    required String file,
    String? fileName,
  }) async {
    final Dio dio = Dio();
    _isFileDownload(true);

    try {
      // Get base download directory
      Directory? baseDirectory = await dw.getDownloadDirectory();

      // Construct safe path: Downloads/fodxpert
      String newPath = "";
      List<String> folders = baseDirectory.path.split("/");
      for (String folder in folders) {
        if (folder == "Android") break;
        if (folder.isNotEmpty) newPath += "/$folder";
      }
      newPath = "$newPath/fodxpert";
      Directory targetDir = Directory(newPath);

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      // Determine filename
      String baseName = fileName != null
          ? fileName.split("/").last.split("-").last
          : file.split("/").last.split("-").last;
      String nameWithoutExtension = baseName.split(".").first;
      String extension = file.split(".").last;

      File saveFile =
          File("${targetDir.path}/$nameWithoutExtension.$extension");

      // Check if file exists
      if (await saveFile.exists()) {
        final decision = await showDialog<String>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text("File Already Exists", style: textTheme.fs_18_bold),
              content: Text(
                "A file named \"$baseName\" already exists. What do you want to do?",
                style: textTheme.fs_12_regular.copyWith(color: GetColors.grey2),
              ),
              actions: <Widget>[
                Row(
                  children: [
                    ExpandedButton(
                        color: GetColors.primary,
                        onPressed: () => Navigator.of(dialogContext).pop('new'),
                        title: "Create new"),
                  ],
                ),
                Row(
                  children: [
                    ExpandedButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop('overwrite'),
                        title: "Overwrite"),
                  ],
                ),
                Row(
                  children: [
                    ExpandedBorderButton(
                        bgcolor: GetColors.white,
                        onPressed: () =>
                            Navigator.of(dialogContext).pop('cancel'),
                        title: "Cancel"),
                  ],
                ),
              ],
            );
          },
        );

        if (decision == 'cancel') {
          _isFileDownload(false);
          Utils.showInfoSnackbar(message: "Download canceled by user.");
          return;
        } else if (decision == 'new') {
          int counter = 1;
          while (await saveFile.exists()) {
            saveFile = File(
                "${targetDir.path}/$nameWithoutExtension($counter).$extension");
            counter++;
          }
        } else {
          // Overwrite: do nothing, use same file
          try {
            print("Attempting to delete: ${saveFile.path}");
            if (await saveFile.exists()) {
              await saveFile.delete();
              await Future.delayed(
                  Duration(milliseconds: 200)); // Allow OS to settle
            }

            if (await saveFile.exists()) {
              print("File still exists, truncating instead.");
              await saveFile
                  .writeAsBytes([], flush: true); // Truncate if deletion failed
            }
          } catch (e) {
            print("Failed to delete or truncate existing file: $e");
            Utils.showErrorSnackbar(
                message: "Failed to overwrite. Creating new one....");
            int counter = 1;
            while (await saveFile.exists()) {
              saveFile = File(
                  "${targetDir.path}/$nameWithoutExtension($counter).$extension");
              counter++;
            }
          }
        }
      }

      // Download logic
      if (FunctionsController.checkFileIsImage(file)) {
        final response = await dio.get(
          file,
          options: Options(responseType: ResponseType.bytes),
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress =
                  "${(received / total * 100).toStringAsFixed(0)}%";
              _downloadProgress(progress);
              print(progress);
            }
          },
        );

        await saveFile.writeAsBytes(response.data);
        Utils.showSuccessSnackbar(
            message: "Your image has been downloaded successfully");
      } else {
        await dio.download(
          file,
          saveFile.path,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress =
                  "${(received / total * 100).toStringAsFixed(0)}%";
              _downloadProgress(progress);
              print(progress);
            }
          },
        );

        Utils.showSuccessSnackbar(
            message: "Your video has been downloaded successfully");
      }

      print("Downloaded to: ${saveFile.path}");
    } catch (e) {
      print("Download failed: $e");
      Utils.showErrorSnackbar(
        message: "Something went wrong. Try again later.",
        showLogout: true,
      );
    } finally {
      _isFileDownload(false);
      _downloadProgress("");
    }
  }
}
