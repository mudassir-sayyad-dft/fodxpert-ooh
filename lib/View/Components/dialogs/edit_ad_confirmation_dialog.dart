import 'package:flutter/material.dart';
import 'package:fodex_new/View/Components/buttons/expanded_btn.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/colors.dart';

class EditAdConfirmationDialog extends StatelessWidget {
  final Function onSave;
  final bool isVideo;
  const EditAdConfirmationDialog(
      {super.key, required this.onSave, this.isVideo = true});

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: const Text("Confirm Action!"),
      content: Text(
          "Are you sure you want to Save this edited ${isVideo ? "video" : "image"}."),
      actions: [
        Row(
          children: [
            ExpandedButton(
                onPressed: () {
                  onSave();
                },
                title: "Save"),
          ],
        ),
        Row(
          children: [
            ExpandedButton(
              onPressed: () {
                AppServices.popView(context);
              },
              title: "Continue Editing",
              color: Colors.transparent,
              foregroundColor: GetColors.primary,
            ),
          ],
        ),
      ],
    );
  }
}
