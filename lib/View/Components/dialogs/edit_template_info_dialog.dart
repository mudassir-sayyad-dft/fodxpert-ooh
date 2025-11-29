import 'package:flutter/material.dart';
import 'package:fodex_new/View/Components/buttons/expanded_btn.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/colors.dart';

class EditTemplateInfoDialog extends StatelessWidget {
  const EditTemplateInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // const Icon(Icons.info, size: 80, color: GetColors.primary),
              // AppServices.addHeight(10),
              Text("Info", style: textTheme.fs_24_bold),
              Divider(color: GetColors.grey3),
              Text("Please click on any section to edit",
                  style:
                      textTheme.fs_16_medium.copyWith(color: GetColors.grey3)),
              AppServices.addHeight(30),
              Row(
                children: [
                  ExpandedButton(
                      onPressed: () {
                        AppServices.popView(context);
                      },
                      title: "Confirm"),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
