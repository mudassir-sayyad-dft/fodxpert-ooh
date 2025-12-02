import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:fodex_new/View/Components/Loaders/full_screen_loader.dart';
import 'package:fodex_new/View/Components/dialogs/save_template_confirmation_dialog.dart';
import 'package:fodex_new/View/Components/dialogs/video_template_dialog.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/utils/utils.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/ads_controller.dart';
import 'package:fodex_new/view_model/models/Ads/ads_model.dart';
import 'package:fodex_new/view_model/models/templates/templates_model.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

import '../../../res/routes/route_constants.dart';

class EditVideoTemplateScreen extends StatefulWidget {
  final AdsModel template;
  final String path;
  const EditVideoTemplateScreen(
      {super.key, required this.template, required this.path});

  @override
  State<EditVideoTemplateScreen> createState() =>
      _EditVideoTemplateScreenState();
}

class _EditVideoTemplateScreenState extends State<EditVideoTemplateScreen> {
  late WebViewControllerPlus _controler;

  Rx<Map<String, dynamic>> jsonFile = Rx<Map<String, dynamic>>({});
  Map<String, dynamic> tempJson = {};
  RxList<TemplateDataModel> jsonData = RxList<TemplateDataModel>([]);
  final grpNameController = TextEditingController();

  RxBool isLoading = false.obs;

  reInitializeController() async {
    print("Edit html preview index file path");
    print(widget.path);
    _controler = WebViewControllerPlus()
      ..loadFile(widget.path)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            _controler.webViewHeight.then((h) {
              var height = int.parse(h.toString()).toDouble();
              if (height != _height) {
                setState(() {
                  _height = height;
                });
              }
            });
          },
        ),
      );
    await loadTemplateData();
    setState(() {});
  }

  String getFileName() {
    return widget.template.fileName.split("/").last.split(".").first;
  }

  Future<String> extractJsonData() async {
    Directory downloadDirectory = await getTemporaryDirectory();
    final file = File(
        '${downloadDirectory.path}/fodx/templates/${getFileName()}/${getFileName().split("-").last}/data.json');

    if (!file.existsSync()) {
      print("Error: JSON file does not exist at path: ${file.path}");
      return '';
    }

    var data = file.readAsStringSync();
    data = data.contains("=") ? data.split("=")[1] : data;
    print(data);
    return data;
  }

  overwriteJson(String json) async {
    Directory downloadDirectory = await getTemporaryDirectory();
    final file = File(
        '${downloadDirectory.path}/fodx/templates/${getFileName()}/${getFileName().split("-").last}/data.json');
    final data = "data=$json";
    file.writeAsStringSync(data);
  }

  loadTemplateData() async {
    Directory downloadDirectory = await getTemporaryDirectory();
    final file = File(
        '${downloadDirectory.path}/fodx/templates/${getFileName()}/${getFileName().split("-").last}/data.json');

    if (!file.existsSync()) {
      print("Error: JSON file does not exist at path: ${file.path}");
      return;
    }

    var data = file.readAsStringSync();
    data = data.contains("=") ? data.split("=")[1] : data;

    if (data.isEmpty) {
      print("Error: JSON file is empty.");
      return;
    }

    try {
      tempJson = json.decode(data);
      jsonFile(tempJson); // Assign the parsed JSON to the observable
    } catch (e) {
      print("Error parsing JSON: $e");
      return;
    }

    if (jsonFile.value.isEmpty) {
      print("Error: Parsed JSON is empty.");
      return;
    }

    jsonData.clear();
    for (var entry in jsonFile.value.entries) {
      var list = entry.value['data'];
      if (list != null) {
        jsonData.addAll(
          (list as List<dynamic>)
              .map((e) => TemplateDataModel.fromMap(e))
              .toList(),
        );
      } else {
        print("Warning: No 'data' field found for key: ${entry.key}");
      }
    }

    await _controler.setOnConsoleMessage((var message) {
      var data = jsonFile.value[message.message];
      if (data != null) {
        showDataDialog(message, data);
      } else {
        print("Error: Data for message '${message.message}' is null.");
      }
    });
  }

  showDataDialog(var message, var data) async {
    final d = await showDialog(
        context: context,
        builder: (context) => VideoTemplateDialog(
            ad: widget.template,
            onSave: (d) async {
              Directory downloadDirectory = await getTemporaryDirectory();
              String oldJson = await extractJsonData();
              for (var i = 0; i < d.length; i++) {
                print("type -------->>>>>>: ${d[i].type}");
                if (d[i].type == TemplateDataType.IMAGE ||
                    d[i].type == TemplateDataType.VIDEO) {
                  var path =
                      "${downloadDirectory.path}/fodx/templates/${getFileName()}/${getFileName().split("-").last}/${jsonData[i].value}";
                  var newValue = d
                      .where((element) => element.key == jsonData[i].key)
                      .first;
                  if (newValue.value != path) {
                    final filePath = await writeFileTo(newValue.value, path);
                    // oldHtml.replaceAll(jsonData[i].key, filePath?.path ?? '');
                    // showDialog(context: context, builder: (context) => VideoResultPopup(video: filePath!));
                  }
                } else {
                  // print("else -------->>>>>>: ${jsonData[i].key} ---- ${jsonData[i].value}");
                  var newValue = d
                      .where((element) => element.key == jsonData[i].key)
                      .first;
                  // print("new html file : ${oldHtml.split(" ").where((e) => e.contains(jsonData[i].key))}");

                  print("previous val");
                  print(
                      "Old Json : ${oldJson.split(" ").where((e) => e.contains(jsonData[i].value))}");
                  print(jsonData[i].value);
                  oldJson =
                      oldJson.replaceAll(jsonData[i].value, newValue.value);

                  // for (var category in tempJson.entries) {
                  //   var categoryData = category.value;

                  //   if (categoryData is Map<String, dynamic> && categoryData.containsKey("data")) {
                  //     var dataList = categoryData["data"];

                  //     if (dataList is List) {
                  //       for (var item in dataList) {
                  //         if (item is Map<String, dynamic> && item["key"] == newValue.key) {
                  //           item["value"] = newValue; // ✅ Replace value
                  //           print("Updated '${item['key']}' in '${category.key}' to '${item['value']}'");
                  //         }
                  //       }
                  //     } else {
                  //       print("Error: 'data' is not a List in '${category.key}'");
                  //     }
                  //   } else {
                  //     print("Error: '${category.key}' is not a Map or missing 'data'");
                  //   }
                  // }

                  print(tempJson);

                  print("new key : ${jsonData[i].key}");
                  print("new value : ${newValue.value}");
                }
              }
              overwriteJson(oldJson);
              print("File written successfully");
            }
            // Future.delayed(const Duration(seconds: 1), () {
            //   AppServices.pushTo(RouteConstants.html_preview, argument: widget.path).then((value) {
            //     _controler.reload();
            //   });
            // });
            ,
            title: data['title'],
            data: (data['data'] as List)
                .map((e) => TemplateDataModel.fromMap(e))
                .toList()));

    if (d != null && d) {
      await reInitializeController();
    }
  }

  Future<File?> writeFileTo(String filePath, String newPath) async {
    try {
      final file = File(filePath);
      final a = await file.copy(newPath);
      print("New File Path --------------> ");
      print(a);
      return a;
    } catch (e) {
      print("error -------->>>>>>: $e");
    }
    return null;
  }

  @override
  void initState() {
    _controler = WebViewControllerPlus()
      ..loadFile(widget.path)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            _controler.webViewHeight.then((h) {
              var height = int.parse(h.toString()).toDouble();
              if (height != _height) {
                setState(() {
                  _height = height;
                });
              }
            });
          },
        ),
      );
    loadTemplateData();
    super.initState();
  }

  showTemplateNameDialog() {
    showDialog(
        context: context,
        builder: (context) => SaveTemplateConfirmationDialog(onSave: () async {
              await saveImageJson(getFileName().split("-").last);
            }));
  }

  double _height = 0.001;
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
          body: SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: WebViewWidget(
                controller: _controler,
              ),
            ),
          ),
        ),
        Obx(() => isLoading.value ? FullScreenLoader() : SizedBox())
      ],
    );
  }

  saveImageJson(String templateName) async {
    AppServices.popView(context);
    isLoading(true);
    try {
      Directory downloadDirectory = await getTemporaryDirectory();

      final adsController = Get.find<AdsController>();

      await zipTemplate(context, templateName, () async {
        Directory downloadDirectory = await getTemporaryDirectory();
        final zipFile = File(
            "${downloadDirectory.path}/fodx/templates/${getFileName()}.zip");

        print("ZipFile Path *************************");
        print(zipFile.path);

        await adsController.updateAd(zipFile,
            previousFileNetworkUrl: widget.template.fileName,
            previousFileUrl: "",
            isZip: true,
            templateType: jsonData.any((e) => e.type == TemplateDataType.VIDEO)
                ? "Video"
                : "Image");

        if (zipFile.existsSync()) {
          zipFile.deleteSync();
        }

        // print("ZipFile Path *************************");
        // print(zipFile.path);
        // if (zipFile.existsSync()) {
        //   zipFile.deleteSync();
        // }
        if (mounted) {
          Utils.showSuccessSnackbar(message: "Template Updated successfully");
          // await Future.delayed(const Duration(seconds: 5));
          await Future.delayed(const Duration(seconds: 3));
          AppServices.pushAndRemoveUntil(RouteConstants.welcome_lounge_view);
          AppServices.pushTo(RouteConstants.bottom_nav_bar, argument: true);
        }
        isLoading(false);
      });
    } catch (e) {
      print("Error in saveImageJson");
      debugPrint(e.toString());
      Utils.showErrorSnackbar(
          message: "Something went wrong", duration: 3, showLogout: true);
      isLoading(false);
    }
  }

  Future zipTemplate(
      BuildContext context, String name, Function() onZipping) async {
    Directory downloadDirectory = await getTemporaryDirectory();
    File zipFile =
        File("${downloadDirectory.path}/fodx/templates/${getFileName()}.zip");
    Directory destinationDir =
        Directory("${downloadDirectory.path}/fodx/templates/${getFileName()}");

    try {
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
}
