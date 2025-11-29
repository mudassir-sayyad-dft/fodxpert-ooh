import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fodex_new/res/api/api_url.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/user_controller.dart';
import 'package:fodex_new/view_model/models/Ads/ads_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';

class AdsRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<List<AdsModel>> getAds(String screenId) async {
    try {
      final response = await _apiServices.getPostApiResponse(
          ApiUrl.adsListForScreenEndPoint, {"screenID": screenId});

      print("*************************** Ads Data ***************************");
      List<AdsModel> ads = (jsonDecode(response) as List)
          .map((e) => AdsModel.fromJson(json: e))
          .toList();
      for (var ad in ads) {
        await ad.generateThumbnail();
      }
      print("*************************** Ads Data ***************************");
      print(ads);
      return ads;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadCreative(
      {File? file,
      required String fileName,
      required String screenName,
      required bool isZip,
      required String templateType}) async {
    try {
      var data = isZip
          ? {
              'userID': Get.find<UserController>().currentUser.uid,
              'screenName': screenName,
              'userName': Get.find<UserController>().currentUser.userName,
              'adGroup': "Template",
              'templateType': templateType
            }
          : {
              'userID': Get.find<UserController>().currentUser.uid,
              'screenName': screenName,
              'userName': Get.find<UserController>().currentUser.userName,
            };
      print("data ---->>");
      print(data);
      print(file);
      print(fileName);
      final response = await _apiServices.getMultiPartPostApiResponse(
          ApiUrl.uploadCreativeEndPoint, data,
          fileName: fileName, file: file);

      print(response);
      print("*****************");

      // Utils.showSuccessSnackbar(
      //     message: "Upload Creative Function Response Step 2 done....");

      return response;
    } catch (e) {
      print("Main error");
      print(e.toString());
      rethrow;
    }
  }

  Future<String> uploadFile(
      {required File file,
      required String fileName,
      required String screenName,
      String sampleTemplateName = "",
      required bool isZip,
      required String templateType}) async {
    try {
      // Read file as bytes
      var fileBytes = await file.readAsBytes();

      // Prepare the data map
      var data = isZip
          ? {
              'userID': Get.find<UserController>().currentUser.uid,
              'screenName': screenName,
              'userName': Get.find<UserController>().currentUser.userName,
              'adGroup': "Template",
              'templateType': templateType
            }
          : {
              'userID': Get.find<UserController>().currentUser.uid,
              'screenName': screenName,
              'userName': Get.find<UserController>().currentUser.userName,
            };
      if (sampleTemplateName.isNotEmpty && isZip) {
        data['sampleTemplateName'] = sampleTemplateName;
      }

      // Create the multipart request
      var request = http.MultipartRequest(
          'POST', Uri.parse(ApiUrl.uploadCreativeEndPoint));

      // Add the file as bytes to the request
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ));

      print(fileName);

      // Add the other fields to the request
      data.forEach((key, value) {
        request.fields[key] = value;
      });

      // Debugging outputs
      debugPrint('Request Fields: ${request.fields}');
      debugPrint('File Name: ${request.files.first.filename}');
      debugPrint('File Byte Length: ${fileBytes.length}');

      // Send the request and get the response
      var response = await request.send();

      if (response.statusCode == 200) {
        var r = await response.stream.bytesToString();
        print(r);
        return r;
      } else {
        throw Exception(
            'Failed to upload file. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error during file upload: $e");
      rethrow;
    }
  }

  Future<AdsModel> addNewAd(String screenId,
      {File? file,
      required String fileName,
      required String screenName,
      required String sampleTemplateName,
      required bool isZip,
      required String templateType}) async {
    try {
      final response = await uploadFile(
          fileName: fileName,
          file: file!,
          screenName: screenName,
          sampleTemplateName: sampleTemplateName,
          isZip: isZip,
          templateType: templateType);

      while (true) {
        final snapshot = await getUploadCreativeStatus(
            screenId: screenId, fileName: response, screenName: screenName);
        print("Progress 100");
        print(snapshot);
        if (jsonDecode(snapshot) case [{'progress': 100}]) {
          break;
        }
      }

      // Utils.showSuccessSnackbar(
      //     message: "Got the status of uploaded File.. Step 3 done....");
      return AdsModel.fromJson(json: {'fileName': response});
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  getUploadCreativeStatus(
      {required String screenId,
      required String fileName,
      required String screenName}) async {
    try {
      print({
        "screenID": screenId,
        "screenName": screenName,
        "userName": Get.find<UserController>().currentUser.userName,
        "filesArr": [
          {"name": fileName}
        ]
      });
      final snapshot = await _apiServices.getPostApiResponse(
          ApiUrl.statusOfUploadFileEndPoint,
          jsonEncode({
            "screenID": screenId,
            "screenName": screenName,
            "userName": Get.find<UserController>().currentUser.userName,
            "filesArr": [
              {"name": fileName}
            ]
          }),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json; charset=utf-8"
          });

      print("Upload Creative Snapshot Data REsponse get ********* $snapshot");

      return snapshot;
    } catch (e) {
      throw Exception(e);
    }
  }

  deleteCreative({required DeleteCreativeData videoData}) async {
    try {
      final snapshot =
          await _apiServices.getPostApiResponse(ApiUrl.deleteCreativeEndPoint, {
        "fileName": videoData.fileName.split("/").last,
        "screenID": videoData.screenId,
        "userID": Get.find<UserController>().currentUser.uid,
      });

      return snapshot;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<AdsModel> updateCreative(
      {required String screenId,
      required String screenName,
      required String fileName,
      File? file,
      required bool isZip,
      required String templateType}) async {
    try {
      String response = await uploadCreative(
          fileName: fileName.split(".").first.split("-").last,
          file: file,
          screenName: screenName,
          isZip: isZip,
          templateType: templateType);

      while (true) {
        await Future.delayed(const Duration(milliseconds: 1000));
        final snapshot = await getUpdateCreativeStatus(videoData: (
          previousFileName: fileName,
          newFileName: response,
          screenId: screenId,
          screenName: screenName
        ));
        print('Progress === ');

        if (jsonDecode(snapshot) case [{'progress': 100}]) {
          response = jsonDecode(snapshot)[0]['name'];
          print("progress ===== 1000");
          break;
        }
      }
      return AdsModel.fromJson(json: {'fileName': response});
    } catch (e) {
      rethrow;
    }
  }

  updatePlaylistForScreen(
      {required List<AdsModel> ads, required String screenId}) async {
    try {
      final snapshot = await _apiServices.getPostApiResponse(
          ApiUrl.updatePlaylistForScreenEndPoint,
          jsonEncode({
            "playlist": ads.map((e) => e.fileName.split("/").last).toList(),
            "screenID": screenId,
          }),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json; charset=utf-8"
          });

      return snapshot;
    } catch (e) {
      throw Exception(e);
    }
  }

  getUpdateCreativeStatus({required UpdateCreativeData videoData}) async {
    try {
      final snapshot = await _apiServices.getPostApiResponse(
          ApiUrl.updateCreativeEndPoint,
          jsonEncode({
            "userID": Get.find<UserController>().currentUser.uid,
            "screenID": videoData.screenId,
            "screenName": videoData.screenName,
            "userName": Get.find<UserController>().currentUser.userName,
            "filesArr": [
              {
                "previousFileName": videoData.previousFileName,
                "name": videoData.newFileName
              }
            ]
          }),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json; charset=utf-8"
          });

      return snapshot;
    } catch (e) {
      throw Exception(e);
    }
  }
}

typedef DeleteCreativeData = ({String fileName, String screenId});
typedef UpdateCreativeData = ({
  String previousFileName,
  String newFileName,
  String screenId,
  String screenName
});

class AdsUploadStatusModel {
  String name;
  int progress;

  AdsUploadStatusModel({this.name = '', this.progress = 0});

  AdsUploadStatusModel.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        progress = json['progress'] ?? 0;
}
