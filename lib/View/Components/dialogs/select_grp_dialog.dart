import 'package:flutter/material.dart';
import 'package:fodex_new/View/Components/buttons/border_btn.dart';
import 'package:fodex_new/View/Components/buttons/expanded_btn.dart';
import 'package:fodex_new/View/Components/textFields/primary_text_field.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/colors.dart';
import 'package:fodex_new/res/validators/validators.dart';

class SelectGroupDialog extends StatefulWidget {
  final Function(String) onSave;
  final bool loading;
  const SelectGroupDialog(
      {super.key, required this.onSave, required this.loading});

  @override
  State<SelectGroupDialog> createState() => _SelectGroupDialogState();
}

class _SelectGroupDialogState extends State<SelectGroupDialog> {
  final grpNameController = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      content: Form(
        key: _key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // CustomDropDown(items: categories.map((e) => e.title).toList()),
            // AppServices.addHeight(20),

            TextFieldPrimary(
              fillColor: GetColors.grey6,
              hint: "Enter Name",
              controller: grpNameController,
              validator: const PrimaryTextValidator(),
            ),
            AppServices.addHeight(20),
            widget.loading
                ? const CircularProgressIndicator.adaptive()
                : Row(
                    children: [
                      ExpandedBorderButton(
                        onPressed: () => AppServices.popView(context),
                        title: "Cancel",
                        bgcolor: GetColors.white,
                        color: GetColors.grey3,
                      ),
                      AppServices.addWidth(15),
                      ExpandedButton(
                          onPressed: () {
                            if (_key.currentState!.validate()) {
                              widget.onSave(grpNameController.text);
                            }
                          },
                          title: "Save",
                          color: GetColors.primary),
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
