import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/View/Components/primary_app_bar.dart';
import 'package:fodex_new/View/Components/textFields/email_text_field.dart';
import 'package:fodex_new/View/Components/textFields/primary_text_field.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/colors.dart';
import 'package:fodex_new/res/utils/utils.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/auth_controller.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../../main.dart';
import '../../Components/buttons/expanded_btn.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  // final TextEditingController _oldPassword = TextEditingController();
  // final TextEditingController _newPassword = TextEditingController();

  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  bool loading = false;
  bool storageLoading = false;

  deleteCache() async {
    setState(() {
      loading = true;
    });
    var tempDir = await getTemporaryDirectory();

    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        loading = false;
      });
      Utils.showSuccessSnackbar(message: "App's Cache Cleared");
    });
  }

  deleteStorage() async {
    setState(() {
      storageLoading = true;
    });

    final appDir = await getApplicationDocumentsDirectory();
    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }

    final path = Directory('/storage/emulated/0/Download/fodx');
    if (path.existsSync()) {
      path.deleteSync(recursive: true);
    }

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        storageLoading = false;
      });
      Utils.showSuccessSnackbar(message: "App's Storage Cleared");
    });
  }

  initialize() {
    final user = Get.find<UserController>().currentUser;

    _username.text = user.userName;
    _email.text = user.email;
    _phone.text =
        user.phone.startsWith("+") ? user.phone.substring(3) : user.phone;
    _firstName.text = user.firstName;
    _lastName.text = user.lastName;
    setState(() {});
  }

  bool updatePassword = false;
  setUpdatePassword(bool status) {
    updatePassword = status;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (controller) {
      return Scaffold(
        body: Column(
          children: [
            const PrimaryAppBar(),
            Flexible(
                child: ListView(
              padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 15.w),
              children: [
                // AppServices.addHeight(20),
                TextFieldPrimary(
                  controller: _username,
                  readOnly: true,
                  prefixIcon: Icons.person,
                  hint: "Enter your username",
                ),
                AppServices.addHeight(20),
                EmailTextField(
                    controller: _email, hint: "Email", readOnly: true),
                AppServices.addHeight(20),
                TextFieldPrimary(
                    controller: _phone,
                    hint: "",
                    prefixIcon: Icons.phone,
                    readOnly: true),
                AppServices.addHeight(20),

                Text("Update Profile", style: textTheme.fs_16_bold),
                AppServices.addHeight(15),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("First Name", style: textTheme.fs_12_regular),
                          AppServices.addHeight(5),
                          TextFieldPrimary(
                              controller: _firstName,
                              deniedLetters: RegExp(r'[ _]'),
                              onchange: (v) {
                                final user =
                                    Get.find<UserController>().currentUser;
                                if (v != null &&
                                    v.trim() == user.firstName.trim() &&
                                    _lastName.text.trim() ==
                                        user.lastName.trim()) {
                                  controller.toggleUpdateProfile(false);
                                } else {
                                  controller.toggleUpdateProfile(true);
                                }
                              },
                              prefixIcon: Icons.person,
                              hint: "Enter First Name"),
                        ],
                      ),
                    ),
                    AppServices.addWidth(10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Last Name", style: textTheme.fs_12_regular),
                          AppServices.addHeight(5),
                          TextFieldPrimary(
                            controller: _lastName,
                            deniedLetters: RegExp(r'[ _]'),
                            onchange: (v) {
                              final user =
                                  Get.find<UserController>().currentUser;
                              if (v != null &&
                                  v.trim() == user.lastName.trim() &&
                                  _firstName.text.trim() ==
                                      user.firstName.trim()) {
                                controller.toggleUpdateProfile(false);
                              } else {
                                controller.toggleUpdateProfile(true);
                              }
                            },
                            prefixIcon: Icons.person,
                            hint: "Enter Last Name",
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                AppServices.addHeight(20),
                controller.loading
                    ? const CircularProgressIndicator.adaptive()
                    : Row(
                        children: [
                          ExpandedButton(
                              onPressed: controller.updateProfile
                                  ? () async {
                                      if (_firstName.text.isEmpty &&
                                          _lastName.text.isEmpty) {
                                        controller.toggleUpdateProfile(false);
                                      } else {
                                        await controller.updateUserProfile(
                                            _firstName.text, _lastName.text);
                                      }
                                    }
                                  : null,
                              title: "Update Profile",
                              color: controller.updateProfile
                                  ? GetColors.primary
                                  : GetColors.grey4)
                        ],
                      ),
              ],
            ))
          ],
        ),
      );
    });
  }
}
