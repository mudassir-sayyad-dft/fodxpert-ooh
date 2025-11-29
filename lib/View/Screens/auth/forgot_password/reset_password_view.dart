import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/View/Components/Loaders/full_screen_loader.dart';
import 'package:fodex_new/View/Components/buttons/expanded_btn.dart';
import 'package:fodex_new/View/Components/textFields/phone_text_field.dart';
import 'package:fodex_new/View/Components/textFields/primary_text_field.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/colors.dart';
import 'package:fodex_new/res/icons_and_images.dart';
import 'package:fodex_new/res/routes/route_constants.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/auth_controller.dart';
import 'package:get/get.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  bool isSmsViaEmail = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
              children: [
                AppServices.addHeight(AppServices.getScreenHeight * 0.04.h),
                Image.asset(GetImages.reset_password_vector, height: 200.h),
                AppServices.addHeight(50),
                Text("Reset Password",
                    textAlign: TextAlign.center, style: textTheme.fs_24_bold),
                Text(
                    "Please enter your ${isSmsViaEmail ? "Email" : "Phone Number"} to\nrequest a password reset.",
                    textAlign: TextAlign.center,
                    style: textTheme.fs_12_regular),
                AppServices.addHeight(40),
                isSmsViaEmail
                    ? TextFieldPrimary(
                        controller: _email,
                        hint: "Enter your email",
                        deniedLetters: RegExp('[ ]'),
                        prefixIcon: Icons.email)
                    : PhoneTextField(
                        controller: _phone,
                        hint: "Enter your phone number.",
                        pickerEnabled: false),
                AppServices.addHeight(AppServices.getScreenHeight * 0.09.h),
                Row(
                  children: [
                    ExpandedButton(
                        onPressed: () async {
                          final authController = Get.find<AuthController>();
                          final response = isSmsViaEmail
                              ? await authController
                                  .sendEmailForResetPassword(_email.text.trim())
                              : await authController
                                  .sendMsgForResetPassword(_phone.text);
                          if (response) {
                            AppServices.pushTo(RouteConstants.otp_verification,
                                argument: {
                                  "forgotPassword": true,
                                  // "with_email": isSmsViaEmail,
                                  // "data": {
                                  //   "value": isSmsViaEmail
                                  //       ? _email.text
                                  //       : _phone.text
                                  // }
                                });
                            _email.clear();
                          }
                        },
                        title: 'Send Reset Password OTP')
                  ],
                ),
                AppServices.addHeight(5),
                Row(
                  children: [
                    ExpandedButton(
                      onPressed: () {
                        setState(() {
                          isSmsViaEmail = !isSmsViaEmail;
                        });
                        _email.clear();
                        _phone.clear();
                      },
                      title:
                          "Send OTP Via ${isSmsViaEmail ? "Phone Number" : "Email"}.",
                      color: Colors.transparent,
                      foregroundColor: GetColors.primary,
                    )
                  ],
                ),
                AppServices.addHeight(20),
                TextButton(
                    onPressed: () {
                      AppServices.pushAndRemove(RouteConstants.login);
                    },
                    child: Text.rich(TextSpan(
                        text: "You remember your password? ",
                        style: textTheme.fs_12_regular,
                        children: const [
                          TextSpan(
                              text: "Login",
                              style: TextStyle(color: GetColors.primary))
                        ])))
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
}
