import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/colors.dart';

class FullScreenLoader extends StatelessWidget {
  final Color? color;
  final String text;
  const FullScreenLoader({super.key, this.color, this.text = ""});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: AppServices.getScreenHeight,
        width: AppServices.getScreenWidth,
        color: color ?? Colors.black.withValues(alpha: .45),
        alignment: Alignment.center,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20.sp),
            constraints: const BoxConstraints(minWidth: 100),
            decoration: BoxDecoration(
                color: GetColors.white,
                borderRadius: BorderRadius.circular(10.r)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator.adaptive(
                  backgroundColor:
                      Platform.isAndroid ? GetColors.grey6 : Colors.black,
                ),
                AppServices.addHeight(10),
                Text(text.isEmpty ? "Loading..." : text,
                    style: textTheme.fs_12_medium)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
