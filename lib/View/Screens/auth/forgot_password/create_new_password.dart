import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/View/Components/Loaders/full_screen_loader.dart';
import 'package:fodex_new/View/Components/textFields/password_field.dart';
import 'package:fodex_new/View/Components/textFields/primary_text_field.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/auth_controller.dart';
import 'package:get/get.dart';

import '../../../../res/base_getters.dart';
import '../../../../res/icons_and_images.dart';
import '../../../../res/routes/route_constants.dart';
import '../../../../res/utils/utils.dart';
import '../../../Components/buttons/expanded_btn.dart';

class CreateNewPassword extends StatefulWidget {
  const CreateNewPassword({super.key});

  @override
  State<CreateNewPassword> createState() => _CreateNewPasswordState();
}

class _CreateNewPasswordState extends State<CreateNewPassword> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
              children: [
                AppServices.addHeight(AppServices.getScreenHeight * 0.08.h),
                Image.asset(GetImages.new_password_vector, height: 200.h),
                AppServices.addHeight(50),
                Text("Create New Password",
                    textAlign: TextAlign.center, style: textTheme.fs_24_bold),
                AppServices.addHeight(40),
                TextFieldPrimary(
                    prefixIcon: Icons.lock,
                    obsecure: true,
                    controller: _password,
                    hint: "Enter new password"),
                AppServices.addHeight(20),
                PasswordTextField(
                    controller: _confirmPassword, hint: "Confirm password"),
                AppServices.addHeight(AppServices.getScreenHeight * 0.12.h),
                Row(
                  children: [
                    ExpandedButton(
                        onPressed: () async {
                          if (_password.text.isNotEmpty &&
                              (_password.text.trim() ==
                                  _confirmPassword.text.trim())) {
                            final response = await Get.find<AuthController>()
                                .resetPassword(_password.text);
                            if (response) {
                              AppServices.pushAndRemove(RouteConstants.login);
                            }
                          } else {
                            Utils.showErrorSnackbar(
                                message:
                                    "Password and confirm password doesn't match.");
                          }
                        },
                        title: 'Submit')
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
}
