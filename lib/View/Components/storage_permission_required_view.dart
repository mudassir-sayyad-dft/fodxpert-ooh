// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/View/Components/buttons/expanded_btn.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/icons_and_images.dart';
import 'package:permission_handler/permission_handler.dart';

class StoragePermissionRequiredView extends StatefulWidget {
  final String route;
  const StoragePermissionRequiredView({super.key, required this.route});

  @override
  State<StoragePermissionRequiredView> createState() =>
      _StoragePermissionRequiredViewState();
}

class _StoragePermissionRequiredViewState
    extends State<StoragePermissionRequiredView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  getData() async {
    final permission = await getStoragePermission(context);
    if (permission) {
      AppServices.pushAndRemoveUntil(widget.route);
    }
  }

  Future<bool> getStoragePermission(BuildContext context) async {
    final permission = await Permission.manageExternalStorage.request();
    if (permission.isGranted) {
      return true;
    }
    await openAppSettings();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              GetImages.security,
              width: 250,
            ),
            Text("Permission Required!", style: textTheme.fs_24_bold),
            AppServices.addHeight(10),
            Text(
                "Storage permission is required to enable the features of the application.",
                textAlign: TextAlign.center,
                style: textTheme.fs_14_regular),
            AppServices.addHeight(40),
            Row(
              children: [
                ExpandedButton(
                    onPressed: () async {
                      await openAppSettings();

                      final permission = await getStoragePermission(context);
                      if (permission) {
                        AppServices.pushAndRemoveUntil(widget.route);
                      }
                    },
                    title: "Open App Settings"),
              ],
            )
          ],
        ),
      ),
    );
  }
}
