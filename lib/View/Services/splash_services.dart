// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fodex_new/View/Components/buttons/expanded_btn.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/routes/route_constants.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/auth_controller.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/user_controller.dart';
import 'package:fodex_new/view_model/models/user/user_model.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashServices {
  UserModel getUserData = Get.find<UserController>().getUser();
  bool _permissionGranted = false;

  Future<bool> _getStoragePermission(BuildContext context) async {
    final permission = await Permission.storage.request();
    print("permission: $permission");
    if (permission.isGranted) {
      return true;
    }
    // await openAppSettings();
    return true;
  }

  _showPermissionDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog.adaptive(
            title: const Text("Permission Required!"),
            content: const Text(
                "Storage permission is required to enable the features of the application."),
            actions: [
              ExpandedButton(
                  onPressed: () async {
                    _permissionGranted = await openAppSettings();
                    if (!_permissionGranted) {
                      _showPermissionDialog(context);
                    }
                  },
                  title: "Open App Settings")
            ],
          );
        });
  }

  void checkAuthentication(BuildContext context) async {
    final userController = Get.find<UserController>();
    userController.setUser(getUserData);
    final isGranted = await _getStoragePermission(context);
    if (isGranted == false) {
      AppServices.pushAndRemoveUntil(RouteConstants.storage_permission,
          argument: getUserData.userName.isEmpty
              ? RouteConstants.login
              : RouteConstants.welcome_lounge_view);
      return;
    } else if (getUserData.userName.isEmpty) {
      AppServices.pushAndRemoveUntil(RouteConstants.login);
      return;
    }
    final authController = Get.find<AuthController>();
    await authController.getMostRecentTOC();

    print(authController.toc.data?.versionNumber ?? "No version");
    print(userController.currentUser.tocVersion);

    if (authController.toc.data?.versionNumber !=
        userController.currentUser.tocVersion) {
      AppServices.pushAndRemoveUntil(RouteConstants.welcome_lounge_view);
    } else {
      AppServices.pushAndRemoveUntil(RouteConstants.terms_view);
    }
    // TODO: Revert to above after testing
    /* if (authController.toc.data?.versionNumber ==
        userController.currentUser.tocVersion) {
      AppServices.pushAndRemoveUntil(RouteConstants.welcome_lounge_view);
    } else {
      AppServices.pushAndRemoveUntil(RouteConstants.terms_view);
    } */
  }
}
