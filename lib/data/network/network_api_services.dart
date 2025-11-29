import 'dart:convert';
import 'dart:io';

import 'package:fodex_new/data/exception/app_exceptions.dart';
import 'package:fodex_new/data/network/base_api_services.dart';
import 'package:http/http.dart' as http;

class NetworkApiService extends BaseApiServices {
  @override
  Future getGetApiResponse(String url) async {
    dynamic responseJson;
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException(message: 'No Internet Connection');
    } catch (e) {
      rethrow;
    }

    return responseJson;
  }

  @override
  Future getPostApiResponse(String url, dynamic data,
      {Map<String, String>? headers}) async {
    dynamic responseJson;
    try {
      final response =
          await http.post(Uri.parse(url), body: data, headers: headers);

      print("**************************");
      print("post api response $url");
      print(response.body);
      print("**************************");
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException(message: 'No Internet Connection');
    } catch (e) {
      rethrow;
    }

    return responseJson;
  }

  @override
  Future getMultiPartPostApiResponse(String url, dynamic data,
      {File? file, required String fileName}) async {
    dynamic responseJson;
    try {
      var request = http.MultipartRequest("POST", Uri.parse(url));
      if (file != null) {
        request.files.add(http.MultipartFile(
            'file', http.ByteStream(file.openRead()), await file.length(),
            filename: fileName.isEmpty
                ? file.path
                : "$fileName.${file.path.split(".").last}"));
      }
      // if (bytes != null) {
      //   request.files.add(http.MultipartFile.fromBytes('file', bytes,
      //       filename: '${FunctionsController.generateId()}.jpg'));
      // }
      request.fields.addAll(data);

      final streamRes = await request.send();
      final response = await http.Response.fromStream(streamRes);
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException(message: 'No Internet Connection');
    } catch (e) {
      // throw DefaultException(message: e.toString());
      rethrow;
    }

    return responseJson;
  }

  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = response.body.startsWith("{")
            ? jsonDecode(response.body)
            : response.body;
        return responseJson;
      case 400:
        throw BadRequestException(message: response.body.toString());
      case 500:
      case 404:
        throw UnAuthorizesException(
            message: jsonDecode(response.body)['message'].toString());
      default:
        throw DefaultException(
            message: jsonDecode(response.body)['message'] ??
                "An error occured while communicating with server with status code ${response.statusCode}");
    }
  }
}
