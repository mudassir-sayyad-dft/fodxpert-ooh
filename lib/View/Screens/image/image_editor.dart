// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fodex_new/View/Components/Loaders/full_screen_loader.dart';
import 'package:fodex_new/View/Components/dialogs/edit_ad_confirmation_dialog.dart';
import 'package:fodex_new/View/Components/dialogs/select_grp_dialog.dart';
import 'package:fodex_new/View/Screens/image/image_configs.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/colors.dart';
import 'package:fodex_new/res/utils/utils.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/ads_controller.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class ImageEditorView extends StatefulWidget {
  final String imagePath, imageType;
  final String imageNetworkUrl;
  final bool isFromNetwork;

  const ImageEditorView(
      {required this.imagePath,
      required this.imageType,
      this.imageNetworkUrl = "",
      this.isFromNetwork = false,
      super.key});

  @override
  State<ImageEditorView> createState() => _ImageEditorViewState();
}

class _ImageEditorViewState extends State<ImageEditorView> {
  bool _loading = false;

  Future<Uint8List?> resizeImage(Uint8List imageBytes, String ext) async {
    final originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) return null;

    int width = originalImage.width;
    int height = originalImage.height;
    double ratio = width / height;

    int newWidth = width;
    int newHeight = height;

    if (width > 1080) {
      newWidth = 1080;
      newHeight = (1080 / ratio).round();
    } else {
      if (height > 1920) {
        newHeight = 1920;
        newWidth = (1920 * ratio).round();
      }
    }

    final resizedImage =
        img.copyResize(originalImage, width: newWidth, height: newHeight);

    return Uint8List.fromList(ext == 'png'
        ? img.encodePng(resizedImage)
        : img.encodeJpg(resizedImage));
  }

  onEditingComplete(Uint8List editedImageBytes) async {
    final downloadDir = await getDownloadsDirectory();
    final tempDir = await getTemporaryDirectory();

    final ext = widget.imagePath.endsWith('.png') ? 'png' : 'jpg';

    final resizedImage = await resizeImage(editedImageBytes, ext);
    if (resizedImage == null) {
      Utils.showErrorSnackbar(message: "Failed to process the edited image.");
      return;
    }

    final filePath =
        '${Platform.isIOS ? tempDir.path : downloadDir!.path}/image.$ext';
    File imgFile = await File(filePath).create();
    await imgFile.writeAsBytes(resizedImage);

    if (widget.imageNetworkUrl.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => EditAdConfirmationDialog(
          isVideo: false,
          onSave: () async {
            AppServices.popView(context);
            setState(() => _loading = true);

            try {
              await Get.find<AdsController>().updateAd(
                imgFile,
                previousFileNetworkUrl: widget.imageNetworkUrl,
                previousFileUrl: widget.imagePath,
              );
              Utils.showSuccessSnackbar(
                  message: "Your image has been uploaded successfully");
              AppServices.popView(context);
            } catch (e) {
              Utils.showErrorSnackbar(message: e.toString());
            }

            setState(() => _loading = false);
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => SelectGroupDialog(
          loading: _loading,
          onSave: (imageName) async {
            if (Get.find<AdsController>().ads.any((element) =>
                element.fileName
                    .split("/")
                    .last
                    .split("-")
                    .last
                    .split(".")
                    .first ==
                imageName.trim())) {
              Utils.showErrorSnackbar(
                  message: "This name has already been used.");
              return;
            }

            AppServices.popView(context);
            setState(() => _loading = true);

            try {
              // Fire-and-forget upload - returns upload ID, doesn't wait for completion
              final uploadId = await Get.find<AdsController>().addNewAd(
                imgFile,
                sampleTemplateName: imageName,
                fileName: "$imageName.$ext",
                previousFile:
                    widget.isFromNetwork ? File(widget.imagePath) : null,
              );

              // Pop immediately, let background upload handle the success message
              AppServices.popView(context);
            } catch (e) {
              Utils.showErrorSnackbar(message: e.toString());
            }

            setState(() => _loading = false);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: GetColors.black,
          body: LayoutBuilder(builder: (context, constraints) {
            if (widget.imageType == "network") {
              return ProImageEditor.network(widget.imagePath,
                  callbacks: ProImageEditorCallbacks(
                    onImageEditingComplete: (image) async =>
                        await onEditingComplete(image),
                  ),
                  configs: ImageConfig.proImageEditorConfigs);
            } else if (widget.imageType == "assets") {
              return ProImageEditor.asset(widget.imagePath,
                  callbacks: ProImageEditorCallbacks(
                    onImageEditingComplete: (image) async =>
                        await onEditingComplete(image),
                  ),
                  configs: ImageConfig.proImageEditorConfigs);
            } else {
              return ProImageEditor.file(File(widget.imagePath),
                  callbacks: ProImageEditorCallbacks(
                    onImageEditingComplete: (image) async =>
                        await onEditingComplete(image),
                  ),
                  configs: ImageConfig.proImageEditorConfigs);
            }
          }),
          // bottomNavigationBar: Padding(
          //   padding: const EdgeInsets.fromLTRB(15, 40, 15, 20),
          //   child: Row(
          //     children: [
          //       ExpandedBorderButton(
          //         onPressed: () {
          //           AppServices.popView(context);
          //         },
          //         title: 'Back',
          //         color: GetColors.white,
          //       ),
          //       AppServices.addWidth(20),
          //       ExpandedButton(
          //           onPressed: () {
          //             showDialog(
          //                 context: context,
          //                 builder: (context) {
          //                   return SelectGroupDialog(
          //                     onSave: () {},
          //                   );
          //                 });
          //           },
          //           title: 'Next',
          //           color: GetColors.primary),
          //     ],
          //   ),
          // ),
        ),
        _loading ? const FullScreenLoader() : const SizedBox()
      ],
    );
  }
}

/**
 * Do these change in the image editor
 * 
 * void doneEditing() async {
    if (_stateManager.editPosition <= 0 && activeLayers.isEmpty) {
      final allowCompleteWithEmptyEditing =
          widget.allowCompleteWithEmptyEditing;
      // if (!allowCompleteWithEmptyEditing) {
      //   return closeEditor();
      // }
    }
    setState(() => _layerInteraction.selectedLayerId = '');

    _doneEditing = true;
    LoadingDialog loading = LoadingDialog()
      ..show(
        context,
        i18n: i18n,
        theme: _theme,
        designMode: designMode,
        message: i18n.doneLoadingMsg,
        imageEditorTheme: imageEditorTheme,
      );

    Uint8List bytes = Uint8List.fromList([]);
    try {
      bytes = await _controllers.screenshot.capture(
            pixelRatio: configs.removeTransparentAreas ? null : _pixelRatio,
          ) ??
          bytes;
    } catch (_) {}

    if (configs.removeTransparentAreas) {
      bytes = removeTransparentImgAreas(bytes) ?? bytes;
    }

    if (mounted) loading.hide(context);

    await widget.onImageEditingComplete(bytes);

    widget.onCloseEditor?.call();
  }
 */
