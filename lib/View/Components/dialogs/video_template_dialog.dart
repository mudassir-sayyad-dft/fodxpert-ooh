// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/View/Components/buttons/border_btn.dart';
import 'package:fodex_new/View/Components/buttons/expanded_btn.dart';
import 'package:fodex_new/View/Components/dropdown/fonts_dropdown.dart';
import 'package:fodex_new/View/Components/textFields/primary_text_field.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/colors.dart';
import 'package:fodex_new/res/utils/utils.dart';
import 'package:fodex_new/view_model/controllers/function_controller.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/templates_controller.dart';
import 'package:fodex_new/view_model/models/Ads/ads_model.dart';
import 'package:fodex_new/view_model/models/templates/templates_model.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../Screens/video/video_editor.dart';

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  final int width;
  final int height;
  CropAspectRatioPresetCustom(this.width, this.height);
  @override
  (int, int)? get data => (width, height);

  @override
  String get name => '$width x $height  (customized)';
}

class VideoTemplateDialog extends StatefulWidget {
  final List<TemplateDataModel> data;
  final String title;
  final TemplatesModel? temp;
  final Function(List<TemplateDataModel>) onSave;
  // final String keyData;
  final AdsModel? ad;
  const VideoTemplateDialog(
      {super.key,
      required this.title,
      // this.keyData = "",
      required this.data,
      this.temp,
      required this.onSave,
      this.ad});

  @override
  State<VideoTemplateDialog> createState() => _VideoTemplateDialogState();
}

class _VideoTemplateDialogState extends State<VideoTemplateDialog> {
  List<dynamic> controllers = [];
  // RxList<TemplateDataModel> jsonData = RxList<TemplateDataModel>([]);
  List<TemplateDataModel> jsonData = [];

  String getFileName() {
    return widget.ad!.fileName.split("/").last.split(".").first;
  }

  loadTemplateData() async {
    final jData = widget.data;
    Directory downloadDirectory = await getTemporaryDirectory();
    for (var i = 0; i < jData.length; i++) {
      if (jData[i].type == TemplateDataType.IMAGE) {
        if (jData[i].value.startsWith("https") ||
            jData[i].value.startsWith("http") ||
            jData[i].value.startsWith("data")) {
          null;
        } else {
          final bytes = File(
              "${downloadDirectory.path}/fodx/templates/${widget.ad != null ? "${getFileName()}/${getFileName().split("-").last}" : "${widget.temp!.id}/${widget.temp!.id}"}/${jData[i].value}");

          // final base64String = base64.encode(bytes);
          jData[i].value = bytes.path;
        }
      } else if (jData[i].type == TemplateDataType.VIDEO) {
        final bytes = File(
            "${downloadDirectory.path}/fodx/templates/${widget.ad != null ? "${getFileName()}/${getFileName().split("-").last}" : "${widget.temp!.id}/${widget.temp!.id}"}/${jData[i].value}");
        jData[i].value = bytes.path;
      }
    }

    jsonData = jData;
    setState(() {});
    print(jsonData);
  }

  RxBool loading = RxBool(false);
  RxBool isLoading = RxBool(false);

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    loading(true);
    await loadTemplateData();
    controllers = widget.data
        .map((e) =>
            e.type == TemplateDataType.IMAGE || e.type == TemplateDataType.VIDEO
                ? ""
                : e.type == TemplateDataType.FONT
                    ? (Get.find<TemplatesController>().fonts.contains(e.value)
                        ? e.value
                        : "")
                    : TextEditingController(text: e.value))
        .toList();

    loading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Obx(
        () => ListView(
            padding: EdgeInsets.all(20.sp),
            shrinkWrap: true,
            children: [
              Text(widget.title, style: textTheme.fs_18_bold),
              AppServices.addHeight(10),
              loading.value
                  ? const SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(jsonData.length, (index) {
                          final snapshot = jsonData[index];
                          if (snapshot.type == TemplateDataType.IMAGE) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final aspectRatio =
                                        snapshot.aspectRatio.split(":");
                                    final width = int.parse(aspectRatio[0]);
                                    final height = int.parse(aspectRatio[1]);
                                    final imageHeight =
                                        int.parse(snapshot.height);
                                    final imageWidth =
                                        int.parse(snapshot.width);

                                    final imgFile = await ImagePicker()
                                        .pickImage(
                                            source: ImageSource.gallery,
                                            requestFullMetadata: true);
                                    bool isPng =
                                        imgFile?.path.endsWith(".png") ?? false;

                                    if (imgFile != null) {
                                      final image =
                                          await ImageCropper().cropImage(
                                        compressFormat: isPng
                                            ? ImageCompressFormat.png
                                            : ImageCompressFormat.jpg,
                                        sourcePath: imgFile.path,
                                        uiSettings: [
                                          AndroidUiSettings(
                                              toolbarTitle: 'Fodex Cropper',
                                              toolbarColor: GetColors.primary,
                                              toolbarWidgetColor: Colors.white,
                                              cropStyle: CropStyle.rectangle,
                                              lockAspectRatio: true,
                                              hideBottomControls: true,
                                              initAspectRatio:
                                                  CropAspectRatioPresetCustom(
                                                      width, height),
                                              aspectRatioPresets: [
                                                CropAspectRatioPresetCustom(
                                                    width, height)
                                              ]),
                                          IOSUiSettings(
                                            title: 'Fodex Cropper',
                                            cancelButtonTitle: "Cancel",
                                            doneButtonTitle: "Done",
                                            embedInNavigationController: false,
                                            aspectRatioPickerButtonHidden: true,
                                            aspectRatioLockEnabled: false,
                                            minimumAspectRatio: width / height,
                                            rotateClockwiseButtonHidden: true,
                                            resetAspectRatioEnabled: false,
                                            rotateButtonsHidden: true,
                                            aspectRatioPresets: [
                                              CropAspectRatioPresetCustom(
                                                  width, height)
                                            ],
                                          ),
                                          WebUiSettings(
                                            context: context,
                                          ),
                                        ],
                                      );

                                      if (image != null) {
                                        var imgPath = image.path;
                                        print(
                                            "imgPath -------->>>>>>: $imgPath");

                                        print("isPng -------->>>>>>: $isPng");
                                        img.Image? decodeImage;
                                        if (isPng) {
                                          decodeImage = img.decodePng(
                                              File(imgPath).readAsBytesSync());
                                        } else {
                                          decodeImage = img.decodeImage(
                                              File(imgPath).readAsBytesSync());
                                        }
                                        if (decodeImage != null) {
                                          final resizedImage = img.copyResize(
                                              decodeImage,
                                              width: imageWidth,
                                              height: imageHeight);
                                          final resizedFileName =
                                              "${imgPath}_resized.${isPng ? "png" : "jpg"}";
                                          print(
                                              "resizedFileName: $resizedFileName");
                                          final resizedFile = File(
                                              resizedFileName)
                                            ..writeAsBytesSync(isPng
                                                ? img.encodePng(resizedImage)
                                                : img.encodeJpg(resizedImage));

                                          // final bytes = await resizedFile.readAsBytes();
                                          // String base64Image = base64Encode(bytes);
                                          controllers[index] = resizedFile.path;
                                          setState(() {});
                                        } else {
                                          print("decodeImage is null");
                                        }
                                      }
                                    }
                                  },
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                          height: 50,
                                          width: 100,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          decoration: BoxDecoration(
                                              color: GetColors.white,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                              border: Border.all(
                                                  color: Colors.black26),
                                              boxShadow: [
                                                BoxShadow(
                                                    blurRadius: 1,
                                                    spreadRadius: 0,
                                                    offset: const Offset(0, 0),
                                                    color: GetColors.black
                                                        .withValues(
                                                            alpha: 0.25))
                                              ]),
                                          child: Image.file(
                                              File(snapshot.value),
                                              fit: BoxFit.cover)),
                                      Positioned(
                                          top: -10,
                                          right: -10,
                                          child: Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  color: GetColors.black
                                                      .withValues(alpha: 0.35),
                                                  shape: BoxShape.circle),
                                              child: const Icon(Icons.edit,
                                                  color: GetColors.white)))
                                    ],
                                  ),
                                ),
                                controllers[index].toString().isEmpty
                                    ? const SizedBox()
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Image.file(
                                            File(controllers[index]),
                                            height: 50,
                                            width: 80,
                                            fit: BoxFit.cover),
                                      ),
                              ],
                            );
                          } else if (snapshot.type == TemplateDataType.FONT) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: FontsDropdown(
                                  selectedFont: controllers[index],
                                  onSelect: (v) => setState(() {
                                        controllers[index] = v;
                                      })),
                            );
                          } else if (snapshot.type == TemplateDataType.VIDEO) {
                            return Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: index == widget.data.length - 1
                                        ? 0
                                        : 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          final XFile? file =
                                              await ImagePicker()
                                                  .pickVideo(
                                                      maxDuration:
                                                          const Duration(
                                                              seconds: 15),
                                                      source:
                                                          ImageSource.gallery)
                                                  .catchError((e) {
                                            print("error -------->>>>>>: $e");
                                          });

                                          print(snapshot.aspectRatio);

                                          // int fileSizeInBytes =
                                          //     await file!.length();

                                          // // Convert bytes to MB (divide by 1024 twice: once to get KB, and once more to get MB)
                                          // double fileSizeInMB =
                                          //     fileSizeInBytes / (1024 * 1024);

                                          // if (fileSizeInMB > 30) {
                                          //   Utils.showErrorSnackbar(
                                          //       message:
                                          //           "Please choose a file less than 30Mb in size.");
                                          //   return;
                                          // }

                                          bool isPortraitVideo(
                                              double aspectRatio) {
                                            // Typically, portrait is closer to 9:16 = 1.77 and landscape is 16:9 = 0.5625
                                            if (aspectRatio >= 1.2) {
                                              return true; // Portrait
                                            } else if (aspectRatio <= 0.8) {
                                              return false; // Landscape
                                            } else {
                                              return false; // Consider near-square or undefined as landscape for safety
                                            }
                                          }

                                          double asr =
                                              snapshot.aspectRatio.isEmpty
                                                  ? 9 / 16
                                                  : double.parse(snapshot
                                                          .aspectRatio
                                                          .split(":")
                                                          .first) /
                                                      double.parse(snapshot
                                                          .aspectRatio
                                                          .split(":")
                                                          .last);

                                          if (isPortraitVideo(asr) ==
                                              isPortraitVideo(
                                                  await getVideoAspectRatio(
                                                          file!) ??
                                                      0)) {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute<void>(
                                                builder:
                                                    (BuildContext context) =>
                                                        VideoEditor(
                                                  file: File(file.path),
                                                  fileUrl:
                                                      file.path.split("/").last,
                                                  isFromTemplate: true,
                                                  isFromNetwork: false,
                                                  aspectRatio:
                                                      snapshot.aspectRatio,
                                                  // duration: info!.duration!.truncate(),
                                                ),
                                              ),
                                            ).then((value) async {
                                              final trimmedFile = value as File;
                                              controllers[index] =
                                                  trimmedFile.path;

                                              setState(() {});
                                            });
                                          } else {
                                            Utils.showErrorSnackbar(
                                                message:
                                                    "The selected video's aspect ratio is different from the given aspect ratio in the template.");
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(10.sp),
                                          margin: EdgeInsets.symmetric(
                                              vertical: index ==
                                                      widget.data.length - 1
                                                  ? 0
                                                  : 10),
                                          decoration: BoxDecoration(
                                              color: GetColors.primary,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: GetColors.primary)),
                                          child: Center(
                                            child: Text(
                                                "Select ${snapshot.key} Video",
                                                style: textTheme.fs_14_bold
                                                    .copyWith(
                                                        color:
                                                            GetColors.white)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    AppServices.addWidth(10),
                                    FutureBuilder<String?>(
                                        future: FunctionsController
                                            .getVideoThumbnail(
                                                controllers[index]),
                                        builder: (context, v) =>
                                            v.connectionState ==
                                                        ConnectionState.done &&
                                                    v.data != null
                                                ? Image.file(
                                                    File(v.data!),
                                                    height: 40,
                                                    width: 60,
                                                    fit: BoxFit.cover,
                                                  )
                                                : SizedBox())
                                  ],
                                ));
                          } else {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical:
                                      index == widget.data.length - 1 ? 0 : 10),
                              child: TextFieldPrimary(
                                  fillColor: GetColors.grey6,
                                  hint: "ENTER ${snapshot.key}",
                                  controller: controllers[index]),
                            );
                          }
                        }),
                      ],
                    ),
              const SizedBox(height: 10),
              isLoading.value
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ExpandedBorderButton(
                          onPressed: () => AppServices.popView(context),
                          title: "Cancel",
                          bgcolor: GetColors.white,
                          color: GetColors.grey3,
                        ),
                        const SizedBox(width: 10),
                        ExpandedButton(
                            onPressed: () async {
                              final controller =
                                  Get.find<TemplatesController>();
                              List<TemplateDataModel> templateData = [];
                              print("Json Data Values ********************");
                              print(jsonData);
                              print(jsonData.length);
                              for (var i = 0; i < controllers.length; i++) {
                                String d = jsonData[i].type ==
                                        TemplateDataType.IMAGE
                                    ? (controllers[i].toString().isEmpty
                                        ? jsonData[i].value
                                        : "${controllers[i]}")
                                    : jsonData[i].type == TemplateDataType.VIDEO
                                        ? (controllers[i].toString().isEmpty
                                            ? jsonData[i].value
                                            : "${controllers[i]}")
                                        : jsonData[i].type ==
                                                TemplateDataType.TEXT
                                            ? (controllers[i]
                                                    .text
                                                    .toString()
                                                    .trim()
                                                    .isEmpty
                                                ? jsonData[i].value
                                                : controllers[i].text)
                                            : (controllers[i].toString().isEmpty
                                                ? jsonData[i].value
                                                : controllers[i]);
                                templateData.add(TemplateDataModel(
                                    key: jsonData[i].key,
                                    value: d,
                                    aspectRatio: jsonData[i].aspectRatio,
                                    height: jsonData[i].height,
                                    width: jsonData[i].width,
                                    type: jsonData[i].type));
                              }
                              await widget.onSave(templateData);
                              controller.setPreviewData(templateData);
                              // Get.back();
                              Navigator.pop(context, true);
                              // widget.ad != null
                              //     ? Get.to(EditTemplatePreviewScreen(template: widget.ad!))
                              //     : AppServices.pushTo(RouteConstants.html_preview,
                              //         argument: widget.temp);
                            },
                            title: 'Preview',
                            color: GetColors.primary),
                      ],
                    )
            ]),
      ),
    );
  }

  Future<double?> getVideoAspectRatio(XFile file) async {
    final VideoPlayerController tempController =
        VideoPlayerController.file(File(file.path));
    await tempController.initialize();

    final Size size = tempController.value.size; // width & height
    final double aspectRatio = size.width / size.height;

    tempController.dispose(); // clean up
    return aspectRatio;
  }
}
