// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:fodex_new/data/network/network_api_services.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/res/routes/route_constants.dart';
import 'package:fodex_new/res/utils/utils.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../app_config.dart';
import 'insta_media_model.dart';

class InstagramModel {
  List<String> userFields = ['id', 'username'];

  String? authorizationCode;
  String? accessToken;
  String? userID;
  String? username;

  void getAuthorizationCode(String url) {
    authorizationCode = url
        .replaceAll('${InstagramConstant.redirectUri}?code=', '')
        .replaceAll('#_', '')
        .replaceAll("#/login", "");
  }

  Future<bool> getTokenAndUserID() async {
    var url = Uri.parse('https://api.instagram.com/oauth/access_token');
    final response = await http.post(url, body: {
      'client_id': InstagramConstant.clientID,
      'redirect_uri': InstagramConstant.redirectUri,
      'client_secret': InstagramConstant.appSecret,
      'code': authorizationCode,
      'grant_type': 'authorization_code'
    });
    accessToken = json.decode(response.body)['access_token'] ?? '';

    final longLiveTokenSnapshot = await http.post(Uri.parse(
        "https://graph.instagram.com/access_token?grant_type=ig_exchange_token&client_secret=${InstagramConstant.appSecret}&access_token=$accessToken"));

    if (longLiveTokenSnapshot.statusCode == 200) {
      accessToken =
          json.decode(longLiveTokenSnapshot.body)['access_token'] ?? '';
    }
    print("accessToken");
    print(accessToken);

    userID = json.decode(response.body)['user_id'].toString();

    prefs.put(
        "accessToken",
        jsonEncode({
          "accessToken": accessToken ?? '',
          "userID": userID ?? '',
          "expiryDate":
              DateTime.now().add(const Duration(days: 10)).toIso8601String()
        }));
    return (accessToken != null && userID != null) ? true : false;
  }

  Future<bool> getUserProfile(BuildContext context) async {
    print(
        "***************************************** User DAta *****************************************");
    print(userID);
    try {
      final fields = userFields.join(',');
      final responseNode = await NetworkApiService().getGetApiResponse(
          'https://graph.instagram.com/$userID?fields=$fields&access_token=$accessToken');

      var instaProfile = {
        'id': responseNode['id'].toString(),
        'username': responseNode['username'],
      };
      username = responseNode['username'];
      print('username: $username');
      return instaProfile['username'] != null ? true : false;
    } catch (e) {
      Utils.showErrorSnackbar(message: e.toString());
    }
    return false;
  }

  Future<List<InstaMediaModel>> fetchVideos(BuildContext context) async {
    try {
      final videoUrl =
          "https://graph.instagram.com/me/media?fields=id,caption,media_type,thumbnail_url,media_url,children{media_url,media_type},permalink,username&access_token=$accessToken";
      final response = await NetworkApiService().getGetApiResponse(videoUrl);

      print(response);

      if (response['data'] != null) {
        return (response['data'] as List)
            .map((e) => InstaMediaModel.fromJson(json: e))
            .toList();
      }
    } catch (e) {
      Utils.showErrorSnackbar(message: e.toString());
    }

    return <InstaMediaModel>[];
  }

  void logoutUser() {
    prefs.delete("accessToken");
    Get.offNamed(RouteConstants.social_media_view);

    // const url = 'https://graph.instagram.com/logout';
    // final response = await http.post(
    //   Uri.parse(url),
    //   body: {
    //     'access_token': accessToken,
    //   },
    // );

    // if (response.statusCode == 200) {
    // } else {
    //   print('Failed to logout');
    // }
  }
}
