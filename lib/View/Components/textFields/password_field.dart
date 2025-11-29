import 'package:flutter/material.dart';
import 'package:fodex_new/View/Components/textFields/primary_text_field.dart';
import 'package:fodex_new/res/colors.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  const PasswordTextField(
      {super.key, required this.controller, required this.hint});

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool obsecure = true;

  @override
  Widget build(BuildContext context) {
    return TextFieldPrimary(
        controller: widget.controller,
        prefixIcon: Icons.lock,
        hint: widget.hint,
        obsecure: obsecure,
        fillColor: GetColors.grey6,
        suffixIcon: IconButton(
            onPressed: () {
              setState(() => obsecure = !obsecure);
            },
            icon: Icon(obsecure ? Icons.visibility_off : Icons.visibility)));
  }
}
