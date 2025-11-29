import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/main.dart';

import '../colors.dart';

class GetTheme {
  static ThemeData lightTheme = ThemeData(
      scaffoldBackgroundColor: GetColors.white,
      colorScheme: ColorScheme.fromSeed(seedColor: GetColors.primary),
      useMaterial3: true,
      fontFamily: "OpenSans",
      dialogTheme: DialogThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          backgroundColor: GetColors.white,
          surfaceTintColor: GetColors.white),
      cardColor: GetColors.white,
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: GetColors.black,
              textStyle: textTheme.fs_12_regular)),
      cardTheme: const CardThemeData(
          color: GetColors.white, surfaceTintColor: GetColors.white));
}
