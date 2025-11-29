import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/res/colors.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/templates_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FontsDropdown extends StatefulWidget {
  final String selectedFont;
  final Function(String) onSelect;
  const FontsDropdown(
      {super.key, required this.selectedFont, required this.onSelect});

  @override
  State<FontsDropdown> createState() => _FontsDropdownState();
}

class _FontsDropdownState extends State<FontsDropdown> {
  TextEditingController dropDownController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TemplatesController>();
    final fonts = controller.fonts;
    fonts.sort((a, b) => a.compareTo(b));
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: GetColors.grey6,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(color: GetColors.grey6)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
            value: widget.selectedFont.isEmpty ? null : widget.selectedFont,
            hint: const Text("SELECT FONT"),
            style: textTheme.fs_12_regular.copyWith(color: GetColors.black),
            items: fonts
                .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: GoogleFonts.getFont(e, fontSize: 12.sp))))
                .toList(),
            onChanged: (String? value) {
              widget.onSelect(value!);
            }),
      ),
    );
  }
}
