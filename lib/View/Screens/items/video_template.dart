import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:fodex_new/View/Components/Loaders/full_screen_loader.dart';
import 'package:fodex_new/View/Components/dialogs/save_template_confirmation_dialog.dart';
import 'package:fodex_new/View/Components/dialogs/select_grp_dialog.dart';
import 'package:fodex_new/View/Components/dialogs/video_template_dialog.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/utils/utils.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/ads_controller.dart';
import 'package:fodex_new/view_model/models/templates/templates_model.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

import '../../../res/routes/route_constants.dart';

class VideoTemplateScreen extends StatefulWidget {
  final TemplatesModel template;
  final String path;
  const VideoTemplateScreen(
      {super.key, required this.template, required this.path});

  @override
  State<VideoTemplateScreen> createState() => _VideoTemplateScreenState();
}

class _VideoTemplateScreenState extends State<VideoTemplateScreen> {
  late WebViewControllerPlus _controler;

  Rx<Map<String, dynamic>> jsonFile = Rx<Map<String, dynamic>>({});
  Map<String, dynamic> tempJson = {};
  RxList<TemplateDataModel> jsonData = RxList<TemplateDataModel>([]);
  final grpNameController = TextEditingController();

  RxBool isLoading = false.obs;

  reInitializeController() async {
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

  Future<String> extractJsonData() async {
    Directory downloadDirectory = await getTemporaryDirectory();
    final file = File(
        '${downloadDirectory.path}/fodx/templates/${widget.template.id}/${widget.template.id}/data.json');

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
        '${downloadDirectory.path}/fodx/templates/${widget.template.id}/${widget.template.id}/data.json');
    final data = "data=$json";
    file.writeAsStringSync(data);
  }

  loadTemplateData() async {
    Directory downloadDirectory = await getTemporaryDirectory();
    final file = File(
        '${downloadDirectory.path}/fodx/templates/${widget.template.id}/${widget.template.id}/data.json');

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
            temp: widget.template,
            onSave: (d) async {
              Directory downloadDirectory = await getTemporaryDirectory();
              String oldJson = await extractJsonData();
              for (var i = 0; i < d.length; i++) {
                print("type -------->>>>>>: ${d[i].type}");
                if (d[i].type == TemplateDataType.IMAGE ||
                    d[i].type == TemplateDataType.VIDEO) {
                  var path =
                      "${downloadDirectory.path}/fodx/templates/${widget.template.id}/${widget.template.id}/${jsonData[i].value}";
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

  double _height = 0.001;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(widget.template.name),
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
        Obx(() => isLoading.value ? const FullScreenLoader() : const SizedBox())
      ],
    );
  }

  saveImageJson(String templateName) async {
    AppServices.popView(context);
    AppServices.popView(context);
    isLoading(true);
    try {
      Directory downloadDirectory = await getTemporaryDirectory();

      final adsController = Get.find<AdsController>();

      await zipTemplate(context, templateName, () async {
        Directory downloadDirectory = await getTemporaryDirectory();
        final zipFile = File(
            "${downloadDirectory.path}/fodx/templates/$templateName/$templateName.zip");

        await adsController.addNewAd(zipFile,
            fileName: zipFile.path.split("/").last,
            isZip: true,
            sampleTemplateName: widget.template.name,
            templateType: widget.template.templateType);
        if (zipFile.existsSync()) {
          zipFile.deleteSync();
        }
        if (mounted) {
          Utils.showSuccessSnackbar(message: "Template saved successfully");
          await Future.delayed(const Duration(seconds: 5));
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
    final oldName = widget.template.id;

    // Rename parent folder to new name if different
    Directory oldParentDir =
        Directory("${downloadDirectory.path}/fodx/templates/$oldName");
    Directory newParentDir =
        Directory("${downloadDirectory.path}/fodx/templates/$name");

    if (oldParentDir.existsSync() && oldName != name) {
      oldParentDir.renameSync(newParentDir.path);

      // Also rename inner folder to match
      Directory innerDir =
          Directory("${downloadDirectory.path}/fodx/templates/$name/$oldName");
      Directory newInnerDir =
          Directory("${downloadDirectory.path}/fodx/templates/$name/$name");
      if (innerDir.existsSync()) {
        innerDir.renameSync(newInnerDir.path);
      }
    }

    // Create zip at parent level to avoid including itself
    File zipFile =
        File("${downloadDirectory.path}/fodx/templates/${name}_temp.zip");
    File finalZipFile =
        File("${downloadDirectory.path}/fodx/templates/$name/$name.zip");
    Directory destinationDir =
        Directory("${downloadDirectory.path}/fodx/templates/$name");

    try {
      ZipFile.createFromDirectory(
        zipFile: zipFile,
        sourceDir: destinationDir,
        onZipping: (path, isDirectory, progress) {
          if (progress == 100.toDouble()) {
            // Move zip to final location
            if (zipFile.existsSync()) {
              zipFile.renameSync(finalZipFile.path);
            }
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
