import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/res/colors.dart';
import 'package:get/get.dart';

class AppServices {
  /// Screen height and width
  static late Size screenSize;
  static double getScreenWidth = screenSize.width;
  static double getScreenHeight = screenSize.height;

  /// Navigators
  static pushAndRemove(String screen, {dynamic argument}) =>
      Get.offNamed(screen, arguments: argument);
  static pushAndRemoveUntil(String screen, {dynamic argument}) =>
      Get.offAllNamed(screen, arguments: argument);
  static popView(BuildContext context) => Navigator.pop(context);
  static pushTo(String screen, {dynamic argument}) =>
      Get.toNamed(screen, arguments: argument);

  /// Sized Box
  static addHeight(double height) => SizedBox(height: height.h);
  static addWidth(double width) => SizedBox(width: width.w);

  /// Text Field border style
  static OutlineInputBorder textFieldPrimaryBorderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.r),
      borderSide: const BorderSide(color: GetColors.grey6));
}
