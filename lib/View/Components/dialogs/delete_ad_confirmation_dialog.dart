import 'package:flutter/material.dart';
import 'package:fodex_new/View/Components/buttons/expanded_btn.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/colors.dart';

class DeleteAdConfirmationDialog extends StatelessWidget {
  final Function onDelete;
  final bool isVideo;
  const DeleteAdConfirmationDialog(
      {super.key, required this.onDelete, this.isVideo = true});

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: const Text("Confirm Delete!"),
      content: Text(
          "Are you sure you want to delete this ${isVideo ? "video" : "image"}."),
      actions: [
        Row(
          children: [
            ExpandedButton(
                onPressed: () {
                  AppServices.popView(context);
                  onDelete();
                },
                title: "Delete"),
          ],
        ),
        Row(
          children: [
            ExpandedButton(
              onPressed: () {
                AppServices.popView(context);
              },
              title: "Cancel",
              color: Colors.transparent,
              foregroundColor: GetColors.primary,
            ),
          ],
        ),
      ],
    );
  }
}
