import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fodex_new/res/api/api_url.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/user_controller.dart';
import 'package:fodex_new/view_model/models/Ads/ads_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';

class AdsRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  /* -------------------------------------------------------------------------- */
  /*                                   GET ADS                                  */
  /* -------------------------------------------------------------------------- */

  Future<List<AdsModel>> getAds(String screenId) async {
    try {
      final response = await _apiServices.getPostApiResponse(
        ApiUrl.adsListForScreenEndPoint,
        {"screenID": screenId},
      );

      final ads = (jsonDecode(response) as List)
          .map((e) => AdsModel.fromJson(json: e))
          .toList();

      for (final ad in ads) {
        await ad.generateThumbnail();
      }

      return ads;
    } catch (e) {
      rethrow;
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                              UPLOAD CREATIVE                               */
  /*        (USED FOR BOTH ADD & UPDATE – IMAGE / VIDEO / ZIP / VIDEO ZIP)       */
  /* -------------------------------------------------------------------------- */

  Future<String> uploadCreative({
    required File file,
    required String fileName,
    required String screenName,
    required String templateType,
    String sampleTemplateName = "",
  }) async {
    try {
      final user = Get.find<UserController>().currentUser;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiUrl.uploadCreativeEndPoint),
      );

      // ---------------- FORM FIELDS ----------------
      request.fields.addAll({
        'userID': user.uid,
        'userName': user.userName,
        'screenName': screenName,
        'adGroup': 'Template',
        'templateType': templateType,
      });

      if (sampleTemplateName.isNotEmpty) {
        request.fields['sampleTemplateName'] = sampleTemplateName;
      }

      // ---------------- FILE ----------------
      // Read bytes first to avoid reusing a single-subscription stream when FFmpeg already touched the file
      final fileBytes = await file.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'files', // 🔥 MUST match req.files
          fileBytes,
          filename: fileName,
          contentType: _getContentType(fileName),
        ),
      );

      // ---------------- SEND ----------------
      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return body;
      } else {
        throw Exception(
          'Upload failed ${response.statusCode}: $body',
        );
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      rethrow;
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                                  ADD NEW AD                                 */
  /* -------------------------------------------------------------------------- */

  Future<AdsModel> addNewAd(
    String screenId, {
    required File file,
    required String fileName,
    required String screenName,
    required String sampleTemplateName,
    required String templateType,
  }) async {
    try {
      final response = await uploadCreative(
        file: file,
        fileName: fileName,
        screenName: screenName,
        templateType: templateType,
        sampleTemplateName: sampleTemplateName,
      );

      final uploadedUrl = jsonDecode(response)['data'][0]['url'];

      // Poll status
      while (true) {
        final snapshot = await getUploadCreativeStatus(
          screenId: screenId,
          fileName: uploadedUrl,
          screenName: screenName,
        );

        if (jsonDecode(snapshot) case [{'progress': 100}]) {
          break;
        }
      }

      return AdsModel.fromJson(json: {'fileName': uploadedUrl});
    } catch (e) {
      throw Exception(e);
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                          UPLOAD STATUS (ADD)                                */
  /* -------------------------------------------------------------------------- */

  Future<String> getUploadCreativeStatus({
    required String screenId,
    required String fileName,
    required String screenName,
  }) async {
    try {
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
          HttpHeaders.contentTypeHeader: "application/json; charset=utf-8",
        },
      );

      return snapshot;
    } catch (e) {
      throw Exception(e);
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                               DELETE CREATIVE                               */
  /* -------------------------------------------------------------------------- */

  deleteCreative({required DeleteCreativeData videoData}) async {
    try {
      return await _apiServices.getPostApiResponse(
        ApiUrl.deleteCreativeEndPoint,
        {
          "fileName": videoData.fileName.split("/").last,
          "screenID": videoData.screenId,
          "userID": Get.find<UserController>().currentUser.uid,
        },
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                               UPDATE CREATIVE                               */
  /* -------------------------------------------------------------------------- */

  Future<AdsModel> updateCreative({
    required String screenId,
    required String screenName,
    required String fileName,
    required File file,
    required String templateType,
  }) async {
    try {
      String response = await uploadCreative(
        file: file,
        fileName: fileName.split("/").last,
        screenName: screenName,
        templateType: templateType,
      );

      final uploadedUrl = jsonDecode(response)['data'][0]['url'];

      while (true) {
        await Future.delayed(const Duration(seconds: 1));

        final snapshot = await getUpdateCreativeStatus(
          videoData: (
            previousFileName: fileName,
            newFileName: uploadedUrl,
            screenId: screenId,
            screenName: screenName,
          ),
        );

        if (jsonDecode(snapshot) case [{'progress': 100}]) {
          response = jsonDecode(snapshot)[0]['name'];
          break;
        }
      }

      return AdsModel.fromJson(json: {'fileName': response});
    } catch (e) {
      rethrow;
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                         UPDATE STATUS (REPLACE)                              */
  /* -------------------------------------------------------------------------- */

  getUpdateCreativeStatus({required UpdateCreativeData videoData}) async {
    try {
      return await _apiServices.getPostApiResponse(
        ApiUrl.updateCreativeEndPoint,
        jsonEncode({
          "userID": Get.find<UserController>().currentUser.uid,
          "screenID": videoData.screenId,
          "screenName": videoData.screenName,
          "userName": Get.find<UserController>().currentUser.userName,
          "filesArr": [
            {
              "previousFileName": videoData.previousFileName,
              "name": videoData.newFileName,
            }
          ],
        }),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json; charset=utf-8",
        },
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                              UPDATE PLAYLIST                                */
  /* -------------------------------------------------------------------------- */

  updatePlaylistForScreen({
    required List<AdsModel> ads,
    required String screenId,
  }) async {
    try {
      return await _apiServices.getPostApiResponse(
        ApiUrl.updatePlaylistForScreenEndPoint,
        jsonEncode({
          "playlist": ads.map((e) => e.displayName.split("/").last).toList(),
          "screenID": screenId,
        }),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json; charset=utf-8",
        },
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                              CONTENT TYPE                                   */
  /* -------------------------------------------------------------------------- */

  MediaType _getContentType(String fileName) {
    final ext = fileName.toLowerCase();

    if (ext.endsWith('.zip')) return MediaType('application', 'zip');
    if (ext.endsWith('.mp4')) return MediaType('video', 'mp4');
    if (ext.endsWith('.webm')) return MediaType('video', 'webm');
    if (ext.endsWith('.png')) return MediaType('image', 'png');
    if (ext.endsWith('.jpg') || ext.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }

    return MediaType('application', 'octet-stream');
  }
}

/* -------------------------------------------------------------------------- */
/*                                   TYPES                                    */
/* -------------------------------------------------------------------------- */

typedef DeleteCreativeData = ({String fileName, String screenId});

typedef UpdateCreativeData = ({
  String previousFileName,
  String newFileName,
  String screenId,
  String screenName,
});

class AdsUploadStatusModel {
  String name;
  int progress;

  AdsUploadStatusModel({this.name = '', this.progress = 0});

  AdsUploadStatusModel.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        progress = json['progress'] ?? 0;
}
