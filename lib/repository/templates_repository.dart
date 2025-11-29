import 'dart:convert';

import 'package:fodex_new/res/api/api_url.dart';
import 'package:fodex_new/view_model/models/templates/templates_model.dart';

import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';

class TemplatesRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<List<String>> getCategories() async {
    try {
      dynamic response = await _apiServices
          .getGetApiResponse(ApiUrl.templateCategoriesEndPoint);

      print("Categories Data ***********************I");
      print(response);

      if (response != null && response['categories'] != null) {
        return (response['categories'] as List)
            .map((e) => e.toString())
            .toList();
      } else {
        throw Exception("Something Went Wrong! Try Again later");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TemplatesModel>> getTemplates(String category) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(
          ApiUrl.getTemplatesEndPoint, {"category": category});

      print(response);

      if (response != null) {
        return (jsonDecode(response) as List)
            .map((e) => TemplatesModel.fromMap(e))
            .toList();
      } else {
        throw Exception("Something Went Wrong! Try Again later");
      }
    } catch (e) {
      rethrow;
    }
  }
}
