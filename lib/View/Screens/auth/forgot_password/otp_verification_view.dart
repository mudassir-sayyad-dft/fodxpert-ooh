// ignore_for_file: must_be_immutable

import 'dart:async';

// import 'package:another_telephony/telephony.dart';
// import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/View/Components/Loaders/full_screen_loader.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/res/colors.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/auth_controller.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:otp_text_field/otp_field_style.dart';
// import 'package:otp_text_field/style.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';

import '../../../../res/base_getters.dart';
import '../../../../res/icons_and_images.dart';
import '../../../../res/routes/route_constants.dart';
import '../../../../res/utils/utils.dart';
import '../../../Components/buttons/expanded_btn.dart';
import '../../../Components/textFields/password_field.dart';
import '../../../Components/textFields/primary_text_field.dart';

class OtpVerificationView extends StatefulWidget {
  final bool forgotPassword;
  // final bool? withEmail;
  // final Map<String, dynamic> data;
  const OtpVerificationView({
    super.key,
    required this.forgotPassword,
    // this.withEmail,
    // required this.data
  });

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final otpController = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  late final SmsRetriever smsRetriever;

  String otp = "";

  Rx<int> duration = 120.obs;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    // getOtpFromMsg();
    startTimer();
    smsRetriever = SmsRetrieverImpl(
      SmartAuth(),
    );

    smsRetriever.getSmsCode().then((value) {
      if (value != null) {
        otpController.text = value;
      }
    });
  }

  startTimer() {
    duration(120);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (duration > 0) {
        duration.value--;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              children: [
                // AppServices.addHeight(AppServices.getScreenHeight * (widget.forgotPassword ? 0.02 : 0.08).h),
                Image.asset(GetImages.enter_otp_vector, height: 200.h),
                AppServices.addHeight(50),
                Text("Enter OTP",
                    textAlign: TextAlign.center, style: textTheme.fs_24_bold),
                Text(
                    widget.forgotPassword
                        ? "An 6 digit code has been sent to\nyour ${Get.find<AuthController>().sendSMSViaEmail ? "Email" : "Phone Number"}"
                        : "An 4 digit code has been sent to\nyour ${Get.find<UserController>().currentUser.email.isEmpty ? "Phone Number" : "Email"}",
                    textAlign: TextAlign.center,
                    style: textTheme.fs_12_regular),
                AppServices.addHeight(25),
                Pinput(
                  controller: otpController,
                  length: widget.forgotPassword ? 6 : 4,
                  defaultPinTheme: PinTheme(
                    width: 56,
                    height: 56,
                    textStyle: const TextStyle(
                        fontSize: 20,
                        color: Color.fromRGBO(30, 60, 87, 1),
                        fontWeight: FontWeight.w600),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  showCursor: true,
                  onCompleted: (pin) {
                    setState(() => otp = pin);
                    if (otp.length == (widget.forgotPassword ? 6 : 4)) {
                      verifyOtp();
                    }
                  },
                ),
                // OTPTextField(
                //   length: widget.forgotPassword ? 6 : 4,
                //   width: AppServices.getScreenWidth,
                //   capitalText: !widget.forgotPassword,
                //   keyboardType: TextInputType.number,
                //   otpFieldStyle: OtpFieldStyle(
                //       backgroundColor: GetColors.grey6,
                //       borderColor: GetColors.black.withValues(alpha:0.25)),
                //   fieldWidth: AppServices.getScreenWidth /
                //       (widget.forgotPassword ? 8 : 6.5).w,
                //   style: textTheme.fs_16_medium,
                //   textFieldAlignment: MainAxisAlignment.spaceAround,
                //   fieldStyle: FieldStyle.box,
                //   controller: otpController,
                //   onCompleted: (pin) {
                //     setState(() => otp = pin);
                //     // verifyOtp();
                //   },
                // ),
                widget.forgotPassword
                    ? Column(
                        children: [
                          AppServices.addHeight(20),
                          TextFieldPrimary(
                              prefixIcon: Icons.lock,
                              obsecure: true,
                              controller: _password,
                              hint: "Enter new password"),
                          AppServices.addHeight(20),
                          PasswordTextField(
                              controller: _confirmPassword,
                              hint: "Confirm password"),
                        ],
                      )
                    : const SizedBox(),
                widget.forgotPassword
                    ? const SizedBox()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Obx(() => duration > 0
                              ? TextButton(
                                  onPressed: null,
                                  child: Text(
                                      "Resend OTP in 0${(duration.value / 60).truncate().toString()} : ${NumberFormat("00").format(duration.value >= 60 ? duration.value == 120 ? 0 : duration.value - 60 : duration.value)}",
                                      style: textTheme.fs_12_regular
                                          .copyWith(color: GetColors.primary)),
                                )
                              : TextButton(
                                  onPressed: () async {
                                    final user =
                                        Get.find<UserController>().currentUser;
                                    final authController =
                                        Get.find<AuthController>();
                                    if (user.phone.isNotEmpty) {
                                      await authController.resendOtpForPhone(
                                          isForgotPassword:
                                              widget.forgotPassword);
                                    } else {
                                      await authController.resendOtpForEmail(
                                          isForgotPassword:
                                              widget.forgotPassword);
                                    }
                                    startTimer();
                                    otpController.clear();
                                    // final authController = Get.find<AuthController>();
                                  },
                                  child: Text("Resend OTP",
                                      style: textTheme.fs_12_regular.copyWith(
                                          color: GetColors.primary)))),
                        ],
                      ),
                AppServices.addHeight(AppServices.getScreenHeight * (0.12).h),
                Row(
                  children: [
                    ExpandedButton(
                        onPressed: () async {
                          await verifyOtp();
                        },
                        title: 'Verify')
                  ],
                ),
              ],
            ),
          ),
        ),
        GetBuilder<AuthController>(
            builder: (controller) => controller.loading
                ? const FullScreenLoader()
                : const SizedBox())
      ],
    );
  }

  verifyOtp() async {
    final authController = Get.find<AuthController>();
    if (otp.isEmpty) {
      Utils.showErrorSnackbar(message: "Please Enter Otp to Continue.");
      return;
    }
    /* if (duration <= 0) {
      Utils.showErrorSnackbar(message: "Invalid Otp");
      return;
    } */
    if (widget.forgotPassword) {
      // final res =
      //     await authController.validateOtp(otp: otp);
      // if (res) {
      authController.moveToCreatePassword(otp);
      // }
      if (_password.text.isNotEmpty &&
          (_password.text.trim() == _confirmPassword.text.trim())) {
        final response = await authController.resetPassword(_password.text);
        if (response) {
          AppServices.pushAndRemove(RouteConstants.login);
        }
      } else {
        Utils.showErrorSnackbar(
            message: "Password and confirm password doesn't match.");
      }
      otpController.clear();
      return;
    }

    final value = await authController.validateOtp(otp: otp);
    otpController.clear();
    if (value) {
      print(value);
      if (authController.toc.data?.versionNumber !=
          Get.find<UserController>().currentUser.tocVersion) {
        value ? AppServices.pushTo(RouteConstants.welcome_lounge_view) : null;
      } else {
        AppServices.pushTo(RouteConstants.terms_view);
      }
      // TODO: Revert to above after testing
      /* if (authController.toc.data?.versionNumber ==
          Get.find<UserController>().currentUser.tocVersion) {
        value ? AppServices.pushTo(RouteConstants.welcome_lounge_view) : null;
      } else {
        AppServices.pushTo(RouteConstants.terms_view);
      } */
    }
  }
}

class SmsRetrieverImpl implements SmsRetriever {
  const SmsRetrieverImpl(this.smartAuth);

  final SmartAuth smartAuth;

  @override
  Future<void> dispose() {
    return smartAuth.removeSmsListener();
  }

  @override
  Future<String?> getSmsCode() async {
    final signature = await smartAuth.getAppSignature();
    debugPrint('App Signature: $signature');
    final res = await smartAuth.getSmsCode(
      useUserConsentApi: true,
    );
    if (res.succeed && res.codeFound) {
      return res.code!;
    }
    return null;
  }

  @override
  bool get listenForMultipleSms => false;
}
