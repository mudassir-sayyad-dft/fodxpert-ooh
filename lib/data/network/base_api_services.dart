import 'dart:io';

abstract class BaseApiServices {
  Future<dynamic> getGetApiResponse(String url);
  Future<dynamic> getPostApiResponse(String url, dynamic data, {Map<String, String>? headers});
  Future<dynamic> getMultiPartPostApiResponse(String url, dynamic data,
      {File? file, required String fileName});
}
