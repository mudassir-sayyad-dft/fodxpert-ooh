import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/main.dart';

import '../../../res/base_getters.dart';
import '../../../res/validators/validators.dart';

class TextFieldPrimary extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextValidator validator;
  final bool obsecure;
  final Color? fillColor;
  final bool readOnly;
  final Function(String?)? onchange;
  final RegExp? deniedLetters;
  final bool ontapOutside;
  const TextFieldPrimary(
      {super.key,
      required this.controller,
      this.prefixIcon,
      this.obsecure = false,
      this.hint = "",
      this.fillColor,
      this.readOnly = false,
      this.suffixIcon,
      this.onchange,
      this.deniedLetters,
      this.ontapOutside = true,
      this.validator = const PrimaryTextValidator()});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
        readOnly: readOnly,
        obscureText: obsecure,
        style: textTheme.fs_12_regular,
        onTapOutside:
            ontapOutside ? (e) => FocusScope.of(context).unfocus() : null,
        validator: (value) => validator.validate(value: value!),
        onChanged: onchange,
        inputFormatters: deniedLetters == null
            ? null
            : [FilteringTextInputFormatter.deny(deniedLetters!)],
        decoration: InputDecoration(
          isDense: true,
          fillColor: fillColor,
          filled: fillColor != null,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
          border: AppServices.textFieldPrimaryBorderStyle,
          focusedBorder: AppServices.textFieldPrimaryBorderStyle,
          enabledBorder: AppServices.textFieldPrimaryBorderStyle,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20.sp) : null,
          suffixIcon: suffixIcon,
          hintText: hint,
          hintStyle: textTheme.fs_12_regular,
        ));
  }
}
