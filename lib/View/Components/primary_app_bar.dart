import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/res/colors.dart';

import '../../app_config.dart';
import '../../res/base_getters.dart';

class PrimaryAppBar extends StatelessWidget {
  final bool leading;
  final Widget? action;
  const PrimaryAppBar({super.key, this.leading = false, this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      width: AppServices.getScreenWidth,
      decoration: const BoxDecoration(color: GetColors.primary),
      child: SafeArea(
        child: Row(
          children: [
            leading
                ? IconButton(
                    onPressed: () {
                      Navigator.of(context).maybePop();
                    },
                    icon: Icon(Icons.arrow_back),
                    color: GetColors.white)
                : SizedBox(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    AppConfig.app_logo,
                    height: 40.h,
                  ),
                ],
              ),
            ),
            if (action != null) action!
          ],
        ),
      ),
    );
  }
}
