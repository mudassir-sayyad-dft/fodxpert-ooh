import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/res/colors.dart';

class ExpandedBorderButton extends StatelessWidget {
  final void Function()? onPressed;
  final String title;
  final Color color;
  final Color bgcolor;
  final bool isExpanded;
  const ExpandedBorderButton(
      {super.key,
      required this.onPressed,
      required this.title,
      this.color = GetColors.black,
      this.bgcolor = GetColors.black,
      this.isExpanded = true});

  @override
  Widget build(BuildContext context) {
    final btn = TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: color),
              borderRadius: BorderRadius.circular(5.r),
            ),
            backgroundColor: bgcolor,
            // foregroundColor: GetColors.white,
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w)),
        child:
            Text(title, style: textTheme.fs_16_medium.copyWith(color: color)));
    return isExpanded ? Expanded(child: btn) : btn;
  }
}
