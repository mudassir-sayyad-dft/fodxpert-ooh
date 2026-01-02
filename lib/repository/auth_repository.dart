import 'dart:io';

import 'package:fodex_new/data/exception/app_exceptions.dart';
import 'package:fodex_new/data/network/base_api_services.dart';
import 'package:fodex_new/data/network/network_api_services.dart';
import 'package:fodex_new/res/api/api_url.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/user_controller.dart';
import 'package:fodex_new/view_model/models/user/most_recent_toc_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AuthRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> login(dynamic data) async {
    try {
      dynamic response =
          await _apiServices.getPostApiResponse(ApiUrl.loginEndPoint, data);

      print("Login Response :: $response");
      return response;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<String> downloadFile(String fileUrl, String fileName) async {
    try {
      // Ask for storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        print("Storage permission denied");
        return "";
      }

      // Get the app's directory (or external storage if needed)
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory(); // Use for Android
      } else {
        directory = await getApplicationDocumentsDirectory(); // iOS/macOS
      }

      String filePath = "${directory!.path}/$fileName";

      // Fetch the file from the network
      var response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode == 200) {
        File file = File(filePath);

        if (await file.exists()) {
          await file.delete();
        }
        await file.writeAsBytes(response.bodyBytes);
        print("File downloaded to: $filePath");
        return file.path;
      } else {
        print("Failed to download file. Status code: ${response.statusCode}");
        print("Failed to download file. Status code: ${response.body}");
        return "";
      }
    } catch (e) {
      print("Error downloading file: $e");
      return "";
    }
  }

  Future<MostRecentTocModel> getMostRecentTOC() async {
    dynamic response = await _apiServices.getPostApiResponse(
      ApiUrl.getMostRecentTOCEndPoint,
      {"owner": Get.find<UserController>().currentUser.managerID},
    );

    print({"owner": Get.find<UserController>().currentUser.managerID});

    if (response is Map<String, dynamic> && response['_id'] != null) {
      print("TOC API Response");
      print(response);
      final res = MostRecentTocModel.fromMap(response);
      return res.copyWith(
        docPath:
            "https://fodxpertandroid.s3.ap-south-1.amazonaws.com/${Get.find<UserController>().currentUser.managerID}/ads/${res.fileName}",
      );
    }

    // All other cases (String, null, Map without _id)
    throw EmptyTOCException();
  }

  // Update TOC details for user
  Future<bool> updateTOCDetails(String tocVersion) async {
    print(tocVersion);
    dynamic response = await _apiServices.getPostApiResponse(
        ApiUrl.updateTOCDetailsEndPoint, {
      "userID": Get.find<UserController>().currentUser.uid,
      "tocVersion": tocVersion
    });

    if (response != null && response['_id'] != null) {
      return true;
    }

    throw Exception('Failed to update TOC details');
  }

  Future<dynamic> validateOtp(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(
          ApiUrl.validateOtpEndPoint, data);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> resetPasswordViaEmail(String username) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(
          ApiUrl.sendEmailForResetPasswordEndPoint, {"emailId": username});

      return response;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<dynamic> resetPasswordViaPhoneNumber(String phoneNumber) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(
          ApiUrl.sendMessageForResetPasswordEndPoint,
          {"contactNumber": phoneNumber});

      return response;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<dynamic> resetPasswordViaCurrentPassword(
      String username, String currentPassword, String newPassword) async {
    try {
      dynamic response =
          await _apiServices.getPostApiResponse(ApiUrl.changePasswordEndPoint, {
        "userName": username,
        "password": currentPassword,
        "confirmPassword": newPassword
      });

      return response;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<dynamic> resendOtpViaEmail(
      {required bool isForgotPassword,
      required String email,
      required String userId}) async {
    try {
      dynamic response = await _apiServices
          .getPostApiResponse(ApiUrl.resendOtpViaMailEndPoint, {
        "emailId": email,
        "userID": userId,
        "loginOrReset": isForgotPassword ? "reset" : "login"
      });

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> resendOtpViaPhone(
      {required bool isForgotPassword,
      required String contactNumber,
      required String userId}) async {
    try {
      dynamic response = await _apiServices
          .getPostApiResponse(ApiUrl.resendOtpViaSMSEndPoint, {
        "contactNumber": contactNumber,
        "userID": userId,
        "loginOrReset": isForgotPassword ? "reset" : "login"
      });

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateUserDetails(String name) async {
    try {
      dynamic response = await _apiServices
          .getPostApiResponse(ApiUrl.updateUserDetailsEndPoint, {
        "userName": Get.find<UserController>().currentUser.userName,
        "name": name,
      });

      return response;
    } catch (e) {
      throw Exception(e);
    }
  }
}
