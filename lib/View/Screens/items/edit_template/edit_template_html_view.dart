import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:fodex_new/View/Components/Loaders/full_screen_loader.dart';
import 'package:fodex_new/View/Components/dialogs/edit_preview_dialog.dart';
import 'package:fodex_new/View/Components/dialogs/save_template_confirmation_dialog.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/routes/route_constants.dart';
import 'package:fodex_new/res/utils/utils.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/ads_controller.dart';
import 'package:fodex_new/view_model/models/Ads/ads_model.dart';
import 'package:fodex_new/view_model/models/templates/templates_model.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EditTemplateHtmlViewScreen extends StatefulWidget {
  final AdsModel template;
  const EditTemplateHtmlViewScreen({super.key, required this.template});

  @override
  State<EditTemplateHtmlViewScreen> createState() =>
      _EditTemplateHtmlViewScreenState();
}

class _EditTemplateHtmlViewScreenState
    extends State<EditTemplateHtmlViewScreen> {
  String getFileName() {
    // Prefer the user-friendly name stripped of UUID/timestamp and `.zip`
    final short = widget.template.displayShortName();
    final base = short.replaceAll(RegExp(r'\.zip$', caseSensitive: false), '');
    return base;
  }

  readTeampleFromLocalStorage() async {
    Directory downloadDirectory = await getTemporaryDirectory();
    final file = File(
        '${downloadDirectory.path}/fodx/templates/${getFileName()}/${getFileName()}/index.html');
    final data = file.readAsStringSync();

    templateData(data);
  }

  Rx<Map<String, dynamic>> jsonFile = Rx<Map<String, dynamic>>({});
  Map<String, dynamic> tempJson = {};
  RxList<TemplateDataModel> jsonData = RxList<TemplateDataModel>([]);

  late WebViewController webViewController; // Persistent WebViewController

  loadTemplateData() async {
    Directory downloadDirectory = await getTemporaryDirectory();
    final file = File(
        '${downloadDirectory.path}/fodx/templates/${getFileName()}/${getFileName()}/data.json');
    var data = file.readAsStringSync();
    data = data.contains("=") ? data.split("=")[1] : data;
    tempJson = json.decode(data);
    jsonFile(json.decode(data));

    for (var i = 0; i < jsonFile.value.length; i++) {
      jsonData.addAll(
          (jsonFile.value.entries.toList()[i].value['data'] as List<dynamic>)
              .map((e) => TemplateDataModel.fromMap(e))
              .toList());
    }
  }

  RxString templateData = ''.obs;
  RxBool isLoading = true.obs;

  addInitState() {
    readTeampleFromLocalStorage();
    loadTemplateData();
    loadData();

    isLoading(false);
  }

  @override
  void initState() {
    super.initState();
    // Future.delayed(
    //     const Duration(milliseconds: 1000),
    //     () => showDialog(
    //         barrierDismissible: false,
    //         context: context,
    //         builder: (context) => const EditTemplateInfoDialog()));
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    addInitState();
  }

  late RxString html = templateData.value.obs;

  loadData() async {
    Directory downloadDirectory = await getTemporaryDirectory();
    for (int i = 0; i < jsonData.length; i++) {
      final data = jsonData[i];
      if (data.type == TemplateDataType.IMAGE) {
        if (data.value.startsWith("https") || data.value.startsWith("http")) {
          html(html.value.replaceAll(data.key, data.value));
        } else {
          final bytes = await File(
                  "${downloadDirectory.path}/fodx/templates/${getFileName()}/${getFileName()}/${data.value}")
              .readAsBytes();
          // final buffer = bytes.buffer;

          // Convert the bytes to a Base64 string
          final base64String = base64.encode(bytes);

          String mimeType = 'image/png';
          if (data.value.endsWith('.jpg') || data.value.endsWith('.jpeg')) {
            mimeType = 'image/jpeg';
          } else if (data.value.endsWith('.gif')) {
            mimeType = 'image/gif';
          }

          data.value = "data:$mimeType;base64,$base64String";
          html(html.value
              .replaceAll(data.key, "data:image/png;base64,$base64String"));
        }
      } else {
        html(html.value.replaceAll(data.key, data.value));
      }
    }

    webViewController.setOnConsoleMessage((var message) {
      var data = jsonFile.value[message.message];
      showDataDialog(data, message);
    });

    // Load the updated HTML into the WebView after modifications
    webViewController.loadHtmlString(html.value);
  }

  onSave(var d, var message) async {
    jsonFile.value[message.message]['data'] = d.map((e) => e.toMap()).toList();
    html(templateData.value);
    for (int i = 0; i < d.length; i++) {
      final data2 = d[i];
      if (data2.type == TemplateDataType.IMAGE) {
        if (data2.value.startsWith("https") ||
            data2.value.startsWith("http") ||
            data2.value.startsWith("data")) {
          html(html.value.replaceAll(data2.key, data2.value));
        } else {
          Directory downloadDirectory = await getTemporaryDirectory();
          final bytes = await File(
                  "${downloadDirectory.path}/fodx/templates/${getFileName()}/${getFileName()}/${data2.value}")
              .readAsBytes();

          // Convert the bytes to a Base64 string
          final base64String = base64.encode(bytes);

          String mimeType = 'image/png';
          if (data2.value.endsWith('.jpg') || data2.value.endsWith('.jpeg')) {
            mimeType = 'image/jpeg';
          } else if (data2.value.endsWith('.gif')) {
            mimeType = 'image/gif';
          }

          data2.value = "data:$mimeType;base64,$base64String";
        }
      }
      html(html.value.replaceAll(data2.key, data2.value));
    }
    for (int i = 0; i < jsonData.length; i++) {
      if (d.any((element) => element.key == jsonData[i].key)) {
        jsonData[i].value =
            d.where((element) => element.key == jsonData[i].key).first.value;
      } else {
        html(html.value.replaceAll(jsonData[i].key, jsonData[i].value));
      }
    }

    // Reload the WebView with the updated HTML
    webViewController.loadHtmlString(html.value);

    // Optionally trigger a rebuild
    // setState(() {});
  }

  showDataDialog(var data, var message) {
    showDialog(
        context: context,
        builder: (context) => EditPreviewDialog(
            ad: widget.template,
            onSave: (d) async => onSave(d, message),
            title: data['title'],
            data: (data['data'] as List)
                .map((e) => TemplateDataModel.fromMap(e))
                .toList()));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(getFileName(), style: const TextStyle(fontSize: 16)),
            actions: [
              TextButton.icon(
                  onPressed: () {
                    showTemplateNameDialog();
                  },
                  icon: const Icon(
                    Icons.save,
                    size: 20,
                  ),
                  label: const Text(
                    "Save",
                    style: TextStyle(fontSize: 12),
                  )),
            ],
          ),
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: WebViewWidget(controller: webViewController),
          ),
        ),
        Obx(() => isLoading.value ? const FullScreenLoader() : const SizedBox())
      ],
    );
  }

  saveImageToTemplateFolder(String imageName, String image) async {
    try {
      if (imageName != "FODX_IMAGE.png") {
        final base64Image = image.replaceAll("data:image/png;base64,", "");
        final bytes = base64Decode(base64Image);

        print("image Data ********************************");
        print(image);
        print(imageName);
        print("********************************");

        Directory downloadDirectory = await getTemporaryDirectory();
        final imagePath =
            '${downloadDirectory.path}/fodx/templates/${getFileName()}/${getFileName()}/$imageName';
        print("Image Path ***********");
        print(imagePath);
        print("********************************");
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(bytes);
      }
    } catch (e) {
      print("Error decoding or saving image: $e");
    }
  }

  showTemplateNameDialog() {
    showDialog(
        context: context,
        builder: (context) => SaveTemplateConfirmationDialog(onSave: () async {
              await saveImageJson(getFileName());
            }));
  }

  saveImageJson(String templateName) async {
    AppServices.popView(context);
    isLoading(true);
    try {
      Directory downloadDirectory = await getTemporaryDirectory();
      final file = File(
          '${downloadDirectory.path}/fodx/templates/${getFileName()}/${getFileName()}/data.json');

      for (var i = 0; i < jsonFile.value.length; i++) {
        for (var j = 0;
            j < jsonFile.value.entries.toList()[i].value['data'].length;
            j++) {
          final d = TemplateDataModel.fromMap(
              jsonFile.value.entries.toList()[i].value['data'][j]);
          if (d.type == TemplateDataType.IMAGE) {
            print(tempJson.entries.toList()[i].value['data'][j]);
            print(d);
            saveImageToTemplateFolder(
                TemplateDataModel.fromMap(
                        tempJson.entries.toList()[i].value['data'][j])
                    .value,
                d.value);
            jsonFile.value.entries.toList()[i].value['data'][j]['value'] =
                tempJson.entries.toList()[i].value['data'][j]['value'];
          }
        }
      }
      var newData = json.encode(jsonFile.value);
      newData = "data=$newData";
      file.writeAsStringSync(newData);

      final adsController = Get.find<AdsController>();

      await zipTemplate(context, templateName, () async {
        Directory downloadDirectory = await getTemporaryDirectory();
        final zipFile = File(
            "${downloadDirectory.path}/fodx/templates/${getFileName()}/${getFileName()}.zip");

        await Future.delayed(const Duration(milliseconds: 1200));
        print("Ads Controller Add new add function");
        await adsController.updateAd(
          zipFile,
          previousFileNetworkUrl: widget.template.fileName,
          previousFileUrl: "",
          isZip: true,
          // Todo : templateType:  "Image"
        );
        if (zipFile.existsSync()) {
          zipFile.deleteSync();
        }
        if (mounted) {
          await Future.delayed(const Duration(seconds: 3));
          AppServices.pushAndRemoveUntil(RouteConstants.welcome_lounge_view);
          AppServices.pushTo(RouteConstants.bottom_nav_bar, argument: true);
        }
        isLoading(false);
      });
    } catch (e) {
      print("Error in saveImageJson");
      debugPrint(e.toString());
      Utils.showErrorSnackbar(message: "Something went wrong", duration: 3);
      isLoading(false);
    }
  }

  Future zipTemplate(
      BuildContext context, String name, Function() onZipping) async {
    Directory downloadDirectory = await getTemporaryDirectory();
    Directory destinationDir =
        Directory("${downloadDirectory.path}/fodx/templates/${getFileName()}");
    // Place the zip inside the template folder so unzip/download paths stay consistent
    File zipFile = File(
        "${downloadDirectory.path}/fodx/templates/${getFileName()}/${getFileName()}.zip");

    if (!destinationDir.existsSync()) {
      destinationDir.createSync(recursive: true);
    }

    if (zipFile.existsSync()) {
      zipFile.deleteSync();
    }

    try {
      ZipFile.createFromDirectory(
        zipFile: zipFile,
        sourceDir: destinationDir,
        onZipping: (path, isDirectory, progress) {
          if (progress == 100.toDouble()) {
            Future.delayed(
                const Duration(seconds: 1), () async => await onZipping());
          } else {}
          return ZipFileOperation.includeItem;
        },
      );
      return true;
    } catch (e) {
      print("Error during Zipping: $e");
    }
  }
}
