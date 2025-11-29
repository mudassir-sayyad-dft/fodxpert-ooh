import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/colors.dart';
import 'package:fodex_new/res/routes/route_constants.dart';
import 'package:get/get.dart';

class Utils {
  static showErrorSnackbar(
      {String message = "", int duration = 3, bool showLogout = false}) {
    return Get.snackbar("An Error occured!", message,
        backgroundColor: GetColors.black.withValues(alpha: 0.4),
        barBlur: 0.7,
        colorText: GetColors.white,
        duration: Duration(seconds: duration),
        shouldIconPulse: true,
        mainButton: showLogout
            ? TextButton(
                onPressed: () {
                  prefs.delete('user');
                  AppServices.pushAndRemove(RouteConstants.login);
                },
                style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.r)),
                    backgroundColor: GetColors.primary,
                    foregroundColor: GetColors.white,
                    padding: EdgeInsets.symmetric(vertical: 10.h)),
                child: Text("Logout", style: textTheme.fs_16_medium))
            : null,
        icon: const Icon(Icons.error_outline_outlined, color: GetColors.white));
  }

  static showSuccessSnackbar({String message = ""}) {
    return Get.snackbar("Success!", message,
        backgroundColor: GetColors.black.withValues(alpha: 0.4),
        barBlur: 0.7,
        colorText: GetColors.white,
        duration: const Duration(seconds: 3),
        shouldIconPulse: true,
        icon: const Icon(Icons.check_circle_outline, color: GetColors.white));
  }

  static showInfoSnackbar({String message = ""}) {
    return Get.snackbar("Info!", message,
        backgroundColor: GetColors.black.withValues(alpha: 0.4),
        barBlur: 0.7,
        colorText: GetColors.white,
        duration: const Duration(seconds: 3),
        shouldIconPulse: true,
        icon: const Icon(Icons.check_circle_outline, color: GetColors.white));
  }
}
