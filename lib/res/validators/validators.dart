import 'package:flutter/material.dart';

@immutable
abstract class TextValidator {
  const TextValidator();

  String? validate({required String? value}) {
    return value == null || value.isEmpty ? "Please enter the value" : null;
  }
}

@immutable
class PrimaryTextValidator extends TextValidator {
  const PrimaryTextValidator();
}

class EmailValidator extends TextValidator {
  const EmailValidator();

  @override
  String? validate({required String? value}) {
    if (super.validate(value: value) == null) {
      if (!value!.contains("@gmail.com")) {
        return "Please Enter a valid email Address";
      }
    }
    return null;
  }
}
