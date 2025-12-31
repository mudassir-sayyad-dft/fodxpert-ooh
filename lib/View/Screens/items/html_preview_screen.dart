// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:fodex_new/View/Components/Loaders/full_screen_loader.dart';
import 'package:fodex_new/View/Components/dialogs/save_template_confirmation_dialog.dart';
import 'package:fodex_new/View/Components/dialogs/select_grp_dialog.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/routes/route_constants.dart';
import 'package:fodex_new/res/utils/utils.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/ads_controller.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/templates_controller.dart';
import 'package:fodex_new/view_model/models/templates/templates_model.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HtmlPreviewScreen extends StatefulWidget {
  TemplatesModel template;
  HtmlPreviewScreen({super.key, required this.template});

  @override
  State<HtmlPreviewScreen> createState() => _HtmlPreviewScreenState();
}

class _HtmlPreviewScreenState extends State<HtmlPreviewScreen> {
  late RxString html = template.obs;

  RxBool loading = RxBool(false);

  Future zipTemplate(
      BuildContext context, String name, Function() onZipping) async {
    late Directory destinationDir;
    late File zipFile;

    if (Platform.isAndroid) {
      // Android: Use the Download folder
      zipFile = File("/storage/emulated/0/Download/fodx/templates/$name.zip");
      destinationDir = Directory(
          "/storage/emulated/0/Download/fodx/templates/${widget.template.id}");
    } else if (Platform.isIOS) {
      // iOS: Use the app's documents directory
      Directory appDocDir = await getApplicationDocumentsDirectory();
      zipFile =
          File('${appDocDir.path}/fodx/templates/${widget.template.id}.zip');
      destinationDir = Directory(
          '${appDocDir.path}/fodx/templates/${widget.template.id}/${widget.template.id}');
      //check file exists
      if (!zipFile.existsSync()) {
        print("File does not exist");
        return;
      } else {
        zipFile.deleteSync();
      }
    }

    try {
      ZipFile.createFromDirectory(
        zipFile: zipFile,
        sourceDir: destinationDir,
        onZipping: (path, isDirectory, progress) {
          if (progress == 100.toDouble()) {
            Future.delayed(
                const Duration(seconds: 3), () async => await onZipping());
          } else {}
          return ZipFileOperation.includeItem;
        },
      );
      return true;
    } catch (e) {
      print("Error during Zipping: $e");
    }
  }

  readTeampleFromLocalStorage() async {
    final file = File(
        '/storage/emulated/0/Download/fodx/templates/${widget.template.id}/${widget.template.id}/index.html');
    final data = file.readAsStringSync();
    setState(() {
      template = data;
    });
  }

  List jsonData = [];

  loadTemplateData() async {
    final file = File(
        '/storage/emulated/0/Download/fodx/templates/${widget.template.id}/${widget.template.id}/data.json');
    var data = file.readAsStringSync();
    data = data.contains("=") ? data.split("=")[1] : data;
    setState(() {
      jsonData = json.decode(data);
    });
  }

  String template = '';

  saveImageToTemplateFolder(String imageName, String image) async {
    final base64Image = image.replaceAll("data:image/png;base64,", "");
    final bytes = base64Decode(base64Image);
    final imagePath =
        '/storage/emulated/0/Download/fodx/templates/${widget.template.id}/${widget.template.id}/$imageName';
    final imageFile = File(imagePath);
    imageFile.writeAsBytes(bytes);
  }

  saveImageJson(String templateName) async {
    AppServices.popView(context);
    AppServices.popView(context);
    final adsController = Get.find<AdsController>();
    loading(true);
    try {
      final file = File(
          '/storage/emulated/0/Download/fodx/templates/${widget.template.id}/${widget.template.id}/data.json');

      final controller = Get.find<TemplatesController>();
      final data = jsonData.map((e) => TemplateDataModel.fromMap(e)).toList();
      for (var i = 0; i < data.length; i++) {
        if (data[i].type != TemplateDataType.IMAGE) {
          data[i].value = controller.previewData[i].value;
        } else {
          saveImageToTemplateFolder(
              data[i].value, controller.previewData[i].value);
        }
      }
      var newData = json.encode(data.map((e) => e.toMap()).toList());
      newData = "data=$newData";
      file.writeAsStringSync(newData);

      await zipTemplate(context, templateName, () async {
        final zipFile = Platform.isAndroid
            ? File(
                "/storage/emulated/0/Download/fodx/templates/$templateName.zip")
            : File(
                '${getApplicationDocumentsDirectory()}/fodx/templates/$templateName.zip');

        // Fire-and-forget upload
        final uploadId = await adsController.addNewAd(zipFile,
            fileName: zipFile.path.split("/").last,
            isZip: true,
            sampleTemplateName: widget.template.name);
        if (zipFile.existsSync()) {
          zipFile.deleteSync();
        }
        if (mounted) {
          // Don't wait for upload, navigate immediately
          await Future.delayed(const Duration(seconds: 2));
          AppServices.pushAndRemoveUntil(RouteConstants.welcome_lounge_view);
          AppServices.pushTo(RouteConstants.bottom_nav_bar, argument: true);
        }
        loading(false);
      });
    } catch (e) {
      print("Error in saveImageJson");
      debugPrint(e.toString());
      Utils.showErrorSnackbar(message: "Something went wrong", duration: 3);
      loading(false);
    }
  }

  showTemplateNameDialog() {
    showDialog(
        context: context,
        builder: (context) => SelectGroupDialog(
            onSave: (v) {
              if (v.isEmpty) {
                Utils.showErrorSnackbar(
                    message: "Template name cannot be empty");
                return;
              }
              if (v.length < 3) {
                Utils.showErrorSnackbar(
                    message: "Template name cannot be less than 3 characters");
                return;
              }

              showDialog(
                  context: context,
                  builder: (context) =>
                      SaveTemplateConfirmationDialog(onSave: () async {
                        await saveImageJson(v);
                      }));
            },
            loading: false));
  }

  @override
  void initState() {
    super.initState();
    readTeampleFromLocalStorage();
    loadTemplateData();
    for (var i = 0; i < jsonData.length; i++) {
      final controller = Get.find<TemplatesController>();
      html(html.value.replaceAll(
          controller.previewData[i].key, controller.previewData[i].value));
      // if (jsonData[i]['type'] == "IMAGE") {
      //   // conver to image and write to file
      //   final base64Image = controller.previewData[i].value
      //       .replaceAll("data:image/png;base64,", "");
      //   final bytes = base64Decode(base64Image);
      //   final imagePath =
      //       '/storage/emulated/0/Download/fodx/templates/${widget.template.id}/image_$i.png';
      //   final imageFile = File(imagePath);
      //   imageFile.writeAsBytes(bytes);
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              title: Text(widget.template.name,
                  style: const TextStyle(fontSize: 16)),
              actions: [
                TextButton.icon(
                    onPressed: () {
                      showTemplateNameDialog();
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Save"))
              ],
            ),
            body: SafeArea(
              child: Obx(
                () => Container(
                  child: WebViewWidget(
                    controller: WebViewController()..loadHtmlString(html.value),
                  ),
                ),
              ),
            )),
        Obx(() => loading.value ? const FullScreenLoader() : const SizedBox())
      ],
    );
  }
}
