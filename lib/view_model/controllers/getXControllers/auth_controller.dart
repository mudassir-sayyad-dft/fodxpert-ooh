import 'package:fodex_new/data/response/response.dart';
import 'package:fodex_new/repository/auth_repository.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/routes/route_constants.dart';
import 'package:fodex_new/res/utils/utils.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/user_controller.dart';
import 'package:fodex_new/view_model/models/user/most_recent_toc_model.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final _repo = AuthRepository();

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    update();
  }

  final Rx<ApiResponse<MostRecentTocModel>> _toc =
      Rx<ApiResponse<MostRecentTocModel>>(ApiResponse.loading());
  ApiResponse<MostRecentTocModel> get toc => _toc.value;

  bool _sendSMSViaEmail = true;
  bool get sendSMSViaEmail => _sendSMSViaEmail;

  _setSendOtpMethodToEmail(bool status) {
    _sendSMSViaEmail = status;
    update();
  }

  String _resendCredsForgotPassword = "";
  // String get resendCreds => _resendCredsForgotPassword;

  _setResendCreds(String value) {
    _resendCredsForgotPassword = value;
    update();
  }

  bool _updateProfile = false;
  bool get updateProfile => _updateProfile;

  toggleUpdateProfile(bool status) {
    _updateProfile = status;
    update();
  }

  String _username = "";
  _setUsername(String name) {
    _username = name;
  }

  String _otp = "";
  moveToCreatePassword(String otp) {
    _otp = otp.trim();
    update();
    // AppServices.pushAndRemove(RouteConstants.create_new_password);
  }

  Future<bool> login(dynamic data, {bool isResendOtp = false}) async {
    setLoading(true);
    final snapshot = (data as Map<String, dynamic>)
        .entries
        .where((element) => element.key != "phone");

    bool returnResponse = false;
    await _repo
        .login(Map.fromIterables(
            snapshot.map((e) => e.key), snapshot.map((e) => e.value)))
        .then((value) async {
      (data).addAll(value);
      Get.find<UserController>().saveUser(data, saveStorage: false);
      setLoading(false);
      isResendOtp
          ? Utils.showSuccessSnackbar(
              message: "Otp Successfully send to the provided data.")
          : AppServices.pushTo(RouteConstants.otp_verification,
              argument: {'forgotPassword': false});
      returnResponse = true;
      return true;
    }).onError((error, stackTrace) {
      print(error);
      setLoading(false);
      Utils.showErrorSnackbar(message: error.toString());
      return false;
    });

    return returnResponse;
  }

  // Get Most Recent TOC
  Future<void> getMostRecentTOC() async {
    // setLoading(true);
    try {
      final tocData = await _repo.getMostRecentTOC();
      _toc.value = ApiResponse.complete(data: tocData);
    } catch (e) {
      print("Error in getting TOC");
      print(e);
      _toc.value = ApiResponse.error(message: e.toString());
    }
    // finally {
    //   setLoading(false);
    // }
  }

  Future<void> updateTOCDetails() async {
    setLoading(true);
    try {
      final res =
          await _repo.updateTOCDetails(_toc.value.data?.versionNumber ?? "");

      if (res) {
        final userController = Get.find<UserController>();
        final user = userController.currentUser;
        user.tocVersion = _toc.value.data?.versionNumber ?? "";
        userController.saveUser(user.toJson());
        AppServices.pushTo(RouteConstants.welcome_lounge_view);
      }
    } catch (e) {
      Utils.showErrorSnackbar(message: e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<bool> validateOtp({required String otp}) async {
    final userCtrl = Get.find<UserController>();
    final data = {"owner": userCtrl.currentUser.uid, "OTP": otp};
    setLoading(true);

    try {
      final value = await _repo.validateOtp(data);
      print(value);
      if (value['message'] != null) {
        Utils.showErrorSnackbar(message: value['message']);
      } else {
        userCtrl.saveUser(value);
        await getMostRecentTOC();
        setLoading(false);
        return true;
      }
    } catch (e) {
      print("Otp validate error");
      print(e);
      Utils.showErrorSnackbar(message: e.toString());
    }
    setLoading(false);
    return false;
  }

  Future<bool> sendEmailForResetPassword(String email) async {
    if (email.isEmpty) {
      Utils.showErrorSnackbar(message: "Please Enter email to continue");
      return false;
    }
    setLoading(true);
    try {
      final response = await _repo.resetPasswordViaEmail(email);
      if (response != null) {
        // AppServices.pushAndRemove(RouteConstants.login);
        _setResendCreds(email);
        _setUsername(response['data']['userName']);
        _setSendOtpMethodToEmail(true);
        setLoading(false);
        Utils.showSuccessSnackbar(
            message:
                "An Otp for reset password has been sent to the email provided. Please also check the spam folder.");
        return true;
      }
    } catch (e) {
      Utils.showErrorSnackbar(message: e.toString());
    }

    setLoading(false);
    return false;
  }

  Future<bool> sendMsgForResetPassword(String phone) async {
    if (phone.isEmpty) {
      Utils.showErrorSnackbar(message: "Please Enter email to continue");
      return false;
    }
    setLoading(true);
    try {
      final response = await _repo.resetPasswordViaPhoneNumber(phone);
      // print(response);
      if (response != null) {
        // AppServices.pushAndRemove(RouteConstants.login);
        _setResendCreds(phone);
        _setUsername(response.toString());
        _setSendOtpMethodToEmail(false);
        setLoading(false);
        Utils.showSuccessSnackbar(
            message:
                "An Otp for reset password has been sent to your phone number.");
        return true;
      }
    } catch (e) {
      Utils.showErrorSnackbar(message: e.toString());
    }

    setLoading(false);
    return false;
  }

  Future<bool> resendOtpForEmail({required bool isForgotPassword}) async {
    setLoading(true);
    try {
      final user = Get.find<UserController>().currentUser;
      final response = await _repo.resendOtpViaEmail(
          isForgotPassword: isForgotPassword,
          email: isForgotPassword ? _resendCredsForgotPassword : user.email,
          userId: isForgotPassword ? _username : user.uid);

      print(response);
      if (response case {"message": "OTP Sent!"}) {
        Utils.showSuccessSnackbar(message: response['message']);
        return true;
      } else {
        Utils.showErrorSnackbar(message: response['message']);
      }
    } catch (e) {
      Utils.showErrorSnackbar(message: e.toString());
    } finally {
      setLoading(false);
    }

    return false;
  }

  Future<bool> resendOtpForPhone({required bool isForgotPassword}) async {
    setLoading(true);
    try {
      final user = Get.find<UserController>().currentUser;
      final response = await _repo.resendOtpViaPhone(
          isForgotPassword: isForgotPassword,
          contactNumber:
              isForgotPassword ? _resendCredsForgotPassword : user.phone,
          userId: isForgotPassword ? _username : user.uid);

      print(response);
      if (response case {"message": "OTP Sent!"}) {
        Utils.showSuccessSnackbar(message: response['message']);
        return true;
      } else {
        Utils.showErrorSnackbar(message: response['message']);
      }
    } catch (e) {
      Utils.showErrorSnackbar(message: e.toString());
    } finally {
      setLoading(false);
    }

    return false;
  }

  Future<bool> resetPassword(String newpassword) async {
    setLoading(true);
    try {
      final response = await _repo.resetPasswordViaCurrentPassword(
          _username, _otp, newpassword);
      if (response != null) {
        Utils.showSuccessSnackbar(message: "Password updated Successfully");
        setLoading(false);
        _otp = "";
        _username = "";
        update();
        return true;
      }
    } catch (e) {
      Utils.showErrorSnackbar(message: e.toString());
    }
    setLoading(false);
    return false;
  }

  Future<bool> updateUserProfile(String name) async {
    setLoading(true);
    try {
      final response = await _repo.updateUserDetails(name);
      if (response != null) {
        Get.find<UserController>().updateUserDetails(name);
        toggleUpdateProfile(false);
        Utils.showSuccessSnackbar(message: "User Details updated successfully");
        setLoading(false);
        return true;
      }
    } catch (e) {
      Utils.showErrorSnackbar(message: e.toString(), showLogout: true);
    }

    setLoading(false);
    return false;
  }
}
