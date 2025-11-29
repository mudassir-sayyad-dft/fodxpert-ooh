import 'dart:convert';

import 'package:fodex_new/data/network/base_api_services.dart';
import 'package:fodex_new/data/network/network_api_services.dart';
import 'package:fodex_new/res/api/api_url.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/user_controller.dart';
import 'package:fodex_new/view_model/models/screens_model/screens_model.dart';
import 'package:get/get.dart';

class ScreensRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<List<ScreensModel>> getScreensForUser() async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(
          ApiUrl.screenDetailsEndPoint,
          {"userID": Get.find<UserController>().currentUser.uid});

      return (jsonDecode(response) as List)
          .map((e) => ScreensModel.fromJson(json: e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
