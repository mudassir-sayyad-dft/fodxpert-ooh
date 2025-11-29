import 'package:flutter/material.dart';
import 'package:fodex_new/View/Components/textFields/primary_text_field.dart';
import 'package:fodex_new/res/validators/validators.dart';

class EmailTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool readOnly;
  final String hint;
  const EmailTextField(
      {super.key,
      required this.controller,
      this.readOnly = false,
      this.hint = "Enter your email"});

  @override
  Widget build(BuildContext context) {
    return TextFieldPrimary(
        readOnly: readOnly,
        controller: controller,
        prefixIcon: Icons.email,
        hint: hint,
        deniedLetters: RegExp('[ ]'),
        validator: const EmailValidator());
  }
}
