// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:fodex_new/View/Components/Loaders/full_screen_loader.dart';
import 'package:fodex_new/View/Components/dialogs/save_template_confirmation_dialog.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/routes/route_constants.dart';
import 'package:fodex_new/res/utils/utils.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/ads_controller.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/templates_controller.dart';
import 'package:fodex_new/view_model/models/Ads/ads_model.dart';
import 'package:fodex_new/view_model/models/templates/templates_model.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EditTemplatePreviewScreen extends StatefulWidget {
  final AdsModel template;
  const EditTemplatePreviewScreen({super.key, required this.template});

  @override
  State<EditTemplatePreviewScreen> createState() =>
      _EditTemplatePreviewScreenState();
}

class _EditTemplatePreviewScreenState extends State<EditTemplatePreviewScreen> {
  late RxString html = template.obs;

  RxBool loading = RxBool(false);

  String getFileName() {
    return widget.template.fileName.split("/").last.split(".").first;
  }

  Future zipTemplate(BuildContext context, Function() onZipping) async {
    late Directory destinationDir;
    late File zipFile;

    if (Platform.isAndroid) {
      // Android: Use the Download folder
      zipFile = File(
          "/storage/emulated/0/Download/fodx/templates/${getFileName()}.zip");
      destinationDir = Directory(
          "/storage/emulated/0/Download/fodx/templates/${getFileName()}");
    } else if (Platform.isIOS) {
      // iOS: Use the app's documents directory
      Directory appDocDir = await getApplicationDocumentsDirectory();
      zipFile = File('${appDocDir.path}/fodx/templates/${getFileName()}.zip');
      destinationDir = Directory(
          '${appDocDir.path}/fodx/templates/${getFileName()}/${getFileName().split("-").last}');
      //check file exists
      if (!zipFile.existsSync()) {
        print("File does not exist");
        return;
      } else {
        zipFile.deleteSync();
      }
    }

    try {
      print("zipFile.path: ${zipFile.path}");
      print("destinationDir.path: ${destinationDir.path}");
      ZipFile.createFromDirectory(
        zipFile: zipFile,
        sourceDir: destinationDir,
        onZipping: (path, isDirectory, progress) {
          print(progress);
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
        '/storage/emulated/0/Download/fodx/templates/${getFileName()}/${getFileName().split("-").last}/index.html');
    final data = file.readAsStringSync();
    setState(() {
      template = data;
    });
  }

  List jsonData = [];

  loadTemplateData() async {
    final file = File(
        '/storage/emulated/0/Download/fodx/templates/${getFileName()}/${getFileName().split("-").last}/data.json');
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
        '/storage/emulated/0/Download/fodx/templates/${getFileName()}/${getFileName().split("-").last}/$imageName';
    final imageFile = File(imagePath);
    imageFile.writeAsBytes(bytes);
  }

  saveImageJson() async {
    final adsController = Get.find<AdsController>();
    AppServices.popView(context);
    loading(true);
    try {
      final file = File(
          '/storage/emulated/0/Download/fodx/templates/${getFileName()}/${getFileName().split("-").last}/data.json');

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

      await zipTemplate(context, () async {
        final zipFile = Platform.isAndroid
            ? File(
                "/storage/emulated/0/Download/fodx/templates/${getFileName()}.zip")
            : File(
                '${getApplicationDocumentsDirectory()}/fodx/templates/${getFileName()}.zip');

        await Future.delayed(const Duration(milliseconds: 1200));
        print("Ads Controller Add new add function");
        await adsController.updateAd(zipFile,
            previousFileNetworkUrl: widget.template.fileName,
            previousFileUrl: "",
            isZip: true);
        loading(false);
        if (zipFile.existsSync()) {
          zipFile.deleteSync();
        }
        if (mounted) {
          Utils.showSuccessSnackbar(message: "Template saved successfully");
          AppServices.pushAndRemoveUntil(RouteConstants.welcome_lounge_view);
          AppServices.pushTo(RouteConstants.bottom_nav_bar, argument: true);
        }
      });
    } catch (e) {
      print("Error in saveImageJson");
      debugPrint(e.toString());
      Utils.showErrorSnackbar(message: "Something went wrong", duration: 3);
      loading(false);
    }
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              title: Text(getFileName().split("-").last,
                  style: const TextStyle(fontSize: 16)),
              actions: [
                TextButton.icon(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) =>
                              SaveTemplateConfirmationDialog(onSave: () async {
                                await saveImageJson();
                              }));
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Save"))
              ],
            ),
            body: SafeArea(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Obx(
                  () => Container(
                    child: WebViewWidget(
                      controller: WebViewController()
                        ..loadHtmlString(html.value),
                    ),
                  ),
                ),
              ),
            )),
        Obx(() => loading.value ? const FullScreenLoader() : const SizedBox())
      ],
    );
  }
}
