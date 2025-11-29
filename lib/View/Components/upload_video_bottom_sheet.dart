// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/icons_and_images.dart';
import 'package:fodex_new/res/routes/route_constants.dart';
import 'package:fodex_new/res/utils/utils.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/ads_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../res/colors.dart';
import '../../view_model/controllers/function_controller.dart';
import '../Screens/video/video_editor.dart';

class UploadVideoBottomSheet extends StatefulWidget {
  const UploadVideoBottomSheet({super.key});

  @override
  State<UploadVideoBottomSheet> createState() => _UploadVideoBottomSheetState();
}

class _UploadVideoBottomSheetState extends State<UploadVideoBottomSheet> {
  final _picker = ImagePicker();

  void _pickVideo() async {
    final fileData = await _picker.pickMedia();

    if (fileData != null) {
      final File file = File(fileData.path);

      if (mounted) {
        if (FunctionsController.checkFileIsVideo(file.path)) {
          // AppServices.pushTo(RouteConstants.video_editor, context,
          //     argument: file.path);

          int fileSizeInBytes = await file.length();

          // Convert bytes to MB (divide by 1024 twice: once to get KB, and once more to get MB)
          double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

          if (fileSizeInMB > 30) {
            Utils.showErrorSnackbar(
                message: "Please choose a file less than 30Mb in size.");
            return;
          }

          final videoInfo = FlutterVideoInfo();
          var info = await videoInfo.getVideoInfo(file.path);

          int seconds = info == null
              ? 0
              : info.duration == null
                  ? 0
                  : (info.duration! / 1000).round();
          if (seconds >= 15) {
            AppServices.popView(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => VideoEditor(
                  file: file,
                  // duration: info!.duration!.truncate(),
                ),
              ),
            );
          } else {
            Utils.showErrorSnackbar(
                message: "Selected video should be minimum 15 sec long.");
          }
        } else {
          AppServices.popView(context);
          final adscontroller = Get.find<AdsController>();
          adscontroller.setIsFileDownload(true);

          // final img = await FunctionsController.resizeImage(file);
          // final img = await ImageCropper().cropImage(
          //   sourcePath: file.path,
          //   uiSettings: [
          //     AndroidUiSettings(
          //       toolbarTitle: 'Fodex Cropper',
          //       toolbarColor: GetColors.primary,
          //       toolbarWidgetColor: Colors.white,
          //       cropStyle: CropStyle.rectangle,
          //       lockAspectRatio: true,
          //       hideBottomControls: true,
          //       initAspectRatio: CropAspectRatioPresetCustom(9, 16),
          //       aspectRatioPresets: [
          //         CropAspectRatioPresetCustom(9, 16),
          //       ],
          //     ),
          //     IOSUiSettings(
          //       title: 'Fodex Cropper',
          //       cancelButtonTitle: "Cancel",
          //       doneButtonTitle: "Done",
          //       embedInNavigationController: false,
          //       aspectRatioPickerButtonHidden: true,
          //       aspectRatioLockEnabled: false,
          //       minimumAspectRatio: 9 / 16,
          //       rotateClockwiseButtonHidden: true,
          //       resetAspectRatioEnabled: false,
          //       rotateButtonsHidden: true,
          //       aspectRatioPresets: [
          //         CropAspectRatioPresetCustom(9, 16),
          //       ],
          //     ),
          //     WebUiSettings(
          //       context: context,
          //     ),
          //   ],
          // );
          // if (img != null) {
          AppServices.pushTo(RouteConstants.image_editor_view,
              argument: jsonEncode([file.path, "file"]));
          adscontroller.setIsFileDownload(false);
          // }
        }
      }
    }
  }

  String token = "";
  String userid = "";
  String username = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 40.h),
      decoration: BoxDecoration(
          color: GetColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PickVideoTile(
              image: GetIcons.camera,
              title: "Upload from gallery",
              ontap: () {
                // AppServices.popView(context);
                _pickVideo();
              }),
          AppServices.addHeight(20),
          PickVideoTile(
              image: GetIcons.social_media,
              title: "Select from social media",
              ontap: () {
                AppServices.popView(context);
                AppServices.pushTo(RouteConstants.social_media_view);
              }),
          AppServices.addHeight(20),
          PickVideoTile(
              image: GetIcons.add,
              title: "Create new one",
              ontap: () {
                AppServices.popView(context);
                AppServices.pushTo(RouteConstants.items_view);
              }),
        ],
      ),
    );
  }
}

class PickVideoTile extends StatelessWidget {
  final String title;
  final String image;
  final Function ontap;
  const PickVideoTile(
      {super.key,
      required this.image,
      required this.title,
      required this.ontap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ontap();
      },
      child: Container(
          alignment: Alignment.center,
          width: AppServices.getScreenWidth,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          decoration: BoxDecoration(
              color: GetColors.white,
              borderRadius: BorderRadius.circular(2.r),
              boxShadow: [
                BoxShadow(
                    blurRadius: 8.r,
                    spreadRadius: 1.r,
                    offset: const Offset(0, 0),
                    color: GetColors.black.withValues(alpha: 0.25))
              ]),
          child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: SizedBox(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SvgPicture.asset(image,
                          height: 30.sp, width: 30.sp, color: GetColors.black),
                    ),
                  )),
              AppServices.addWidth(15),
              Expanded(
                  flex: 5,
                  child: SizedBox(
                    child: Text(title, style: textTheme.fs_14_bold),
                  )),
            ],
          )),
    );
  }
}
