import 'package:flutter/material.dart';
import 'package:fodex_new/View/Components/buttons/expanded_btn.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/colors.dart';

class SaveTemplateConfirmationDialog extends StatelessWidget {
  final Function onSave;
  const SaveTemplateConfirmationDialog({
    super.key,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: const Text("Save Template!"),
      content: const Text("Do you want to save this template?"),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ExpandedButton(
                onPressed: () {
                  AppServices.popView(context);
                },
                title: "Cancel",
                color: Colors.transparent,
                foregroundColor: GetColors.primary,
              ),
              ExpandedButton(
                  onPressed: () {
                    onSave();
                  },
                  title: "Save"),
            ],
          ),
        ),
      ],
    );
  }
}
