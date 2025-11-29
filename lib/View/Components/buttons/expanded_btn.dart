import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/res/colors.dart';

class ExpandedButton extends StatelessWidget {
  final void Function()? onPressed;
  final String title;
  final Color color;
  final Color foregroundColor;
  final bool isExpanded;
  const ExpandedButton(
      {super.key,
      required this.onPressed,
      required this.title,
      this.color = GetColors.black,
      this.isExpanded = true,
      this.foregroundColor = GetColors.white});

  @override
  Widget build(BuildContext context) {
    final btn = TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.r)),
            backgroundColor: color,
            foregroundColor: foregroundColor,
            padding: EdgeInsets.symmetric(vertical: 10.h)),
        child: Text(title, style: textTheme.fs_16_medium));
    return isExpanded ? Expanded(child: btn) : btn;
  }
}
