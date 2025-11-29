// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/View/Components/Loaders/full_screen_loader.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/colors.dart';
import 'package:fodex_new/res/icons_and_images.dart';
import 'package:fodex_new/res/routes/route_constants.dart';
import 'package:fodex_new/res/utils/utils.dart';
import 'package:fodex_new/view_model/controllers/function_controller.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/templates_controller.dart';
import 'package:fodex_new/view_model/enums/enums.dart';
import 'package:fodex_new/view_model/models/item_model.dart';
import 'package:fodex_new/view_model/models/templates/file_storage.dart';
import 'package:fodex_new/view_model/models/templates/templates_model.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../../view_model/controllers/getXControllers/ads_controller.dart';
import '../../Components/error_view.dart';
import '../image/image_editor.dart';
import '../video/video_editor.dart';

class ItemsView extends StatefulWidget {
  const ItemsView({super.key});

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  final TextEditingController _search = TextEditingController();

  CategoryModel allItem = const CategoryModel(id: "AllData", title: "All Item");

  bool permissionGranted = true;
  String selectedCategory = "";

  String? path = "";

  final String _searchValue = '';
  late final CategoryModel _activeIndex = allItem;

  checkFolderExists(String path, TemplatesModel template) async {
    Directory downloadDir = await getDownloadDirectory();
    final directory = Directory("${downloadDir.path}/fodx");
    if (directory.existsSync()) {
      print("folder deleted");
      await directory.delete(recursive: true);
    }
    downloadAndUnzipTemplate(template);
  }

  String temporaryDirectoryPath = "";

  @override
  void initState() {
    super.initState();
    createFolderinTemporaryDirectory();
    getInitialState();
  }

  showRecreateFolderDialog(TemplatesModel template) {
    Get.dialog(AlertDialog(
      title: const Text("Recreate Folder"),
      content: const Text("Do you want to recreate the folder?"),
      actions: [
        TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("Cancel")),
        TextButton(
            onPressed: () {
              downloadAndUnzipTemplate(template);
            },
            child: const Text("Recreate"))
      ],
    ));
  }

  createFolderinTemporaryDirectory() async {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/fodx';
    setState(() {
      temporaryDirectoryPath = path;
    });
  }

  downloadAndUnzipTemplate(TemplatesModel template) async {
    final controller = Get.find<AdsController>();

    controller.setLoading(true);
    try {
      var pathForImages = Directory(temporaryDirectoryPath);
      try {
        if (pathForImages.existsSync()) {
          pathForImages.deleteSync(recursive: true);
        }
      } catch (e) {
        print("error deleting folder");
      }
      var path = "$temporaryDirectoryPath/templates/${template.id}";

      var fileExist = File(path);
      if (fileExist.existsSync()) {
        fileExist.deleteSync();
      }

      print("Template file url *************************");
      print(template.file);
      bool downloaded =
          await FileStorage.downloadAndSaveImage(template.file, template.id);
      String p =
          "$temporaryDirectoryPath/templates/${template.id}/${template.id}/index.html";
      if (downloaded) {
        await unzipTemplate(context, template.id, () {
          print("Template Type");
          print(template.templateType);
          if (template.templateType.toLowerCase() == "video") {
            print("Template Type inside video");
            AppServices.pushTo(RouteConstants.video_view,
                argument: {"template": template, "path": p});
          } else {
            AppServices.pushTo(RouteConstants.html_view,
                argument: {"template": template, "path": p});
          }
        });
      }

      controller.setLoading(false);
    } catch (e) {
      controller.setLoading(false);
    }
  }

  Future unzipTemplate(var context, String file, Function() onComplete) async {
    late Directory destinationDir;
    late File zipFile;
    zipFile = File("$temporaryDirectoryPath/templates/$file/$file.zip");
    destinationDir = Directory("$temporaryDirectoryPath/templates/$file");
    try {
      if (!await Directory("${destinationDir.path}/$file").exists()) {
        await Directory("${destinationDir.path}/$file").delete(recursive: true);
      }
    } catch (e) {
      print("File delete fail");
    }
    try {
      ZipFile.extractToDirectory(
        zipFile: zipFile,
        destinationDir: destinationDir,
        onExtracting: (entry, progress) {
          if (progress == 100) {
            zipFile.deleteSync();
            onComplete();
          } else {}
          return ZipFileOperation.includeItem;
        },
      );
      // showSnackBar("Unzipped", title: "Success");
    } catch (e) {
      Utils.showErrorSnackbar(message: "Error during unzipping: $e");
      print("Error during unzipping: $e");
    }
  }

// Make Video thumnails and data video
  getInitialState() async {
    final provider = Get.put(TemplatesController());
    await provider.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TemplatesController>(builder: (provider) {
      // List<CategoryModel> categories = [allItem, ...DummyData.categories];

      List<TemplatesModel> videosList = _searchValue.isEmpty
          ? (provider.templates.data ?? [])
          : (provider.templates.data ?? [])
              .where((element) =>
                  element.name.toLowerCase().trim().startsWith(_searchValue))
              .toList();

      List<String> categories = provider.categories.data ?? [];

      if (provider.templates.status == ApiStatus.ERROR ||
          provider.categories.status == ApiStatus.ERROR) {
        return ErrorView(onRetry: () async => await provider.getCategories());
      }

      return Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              iconTheme: const IconThemeData(color: GetColors.white),
              toolbarHeight: 50.h,
              backgroundColor: GetColors.primary,
              // foregroundColor: GetColors.primary,
              title: Text("Templates",
                  style: textTheme.fs_18_bold.copyWith(color: GetColors.white)),
              actions: [
                IconButton(
                    onPressed: () async {
                      await getInitialState();
                    },
                    icon: const Icon(Icons.refresh))
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 25.h),
                child: Column(
                  children: [
                    SizedBox(
                      height: (textTheme.fs_16_bold.fontSize! + 25.h),
                      child: ListView.separated(
                          separatorBuilder: (context, i) =>
                              AppServices.addWidth(7),
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          shrinkWrap: true,
                          itemBuilder: (context, i) {
                            final category = categories[i];
                            return InkWell(
                                onTap: () {
                                  provider.getTemplates(category);
                                  setState(() {
                                    selectedCategory = category;
                                  });
                                },
                                child: Obx(
                                  () => Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.w, vertical: 10.h),
                                    decoration: BoxDecoration(
                                        color: provider.selectedCategory ==
                                                category
                                            ? GetColors.primary
                                            : GetColors.white,
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        border: provider.selectedCategory ==
                                                category
                                            ? null
                                            : Border.all(
                                                color: GetColors.grey6)),
                                    child: Text(category,
                                        style: textTheme.fs_12_bold.copyWith(
                                            color: provider.selectedCategory ==
                                                    category
                                                ? GetColors.white
                                                : GetColors.black)),
                                  ),
                                ));
                          }),
                    ),
                    AppServices.addHeight(20),
                    Flexible(
                      child: videosList.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(GetImages.no_data, height: 150.h),
                                Text("Couldn't find results",
                                    style: textTheme.fs_18_bold)
                              ],
                            )
                          : GridView.builder(
                              itemCount: videosList.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.75,
                                      crossAxisSpacing: 15.sp,
                                      mainAxisSpacing: 15.sp),
                              itemBuilder: (context, i) {
                                return Stack(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        provider.setPreviewData([]);
                                        print(videosList[i].file);
                                        print(videosList[i]);
                                        downloadAndUnzipTemplate(videosList[i]);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(6.sp),
                                        decoration: BoxDecoration(
                                            color: GetColors.white,
                                            borderRadius:
                                                BorderRadius.circular(14.r),
                                            boxShadow: [
                                              BoxShadow(
                                                  offset: const Offset(0, 2.14),
                                                  blurRadius: 8.57,
                                                  color: Colors.black
                                                      .withValues(alpha: 0.06))
                                            ]),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AspectRatio(
                                              aspectRatio: 1,
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.r),
                                                  child: Image.network(
                                                      videosList[i].image,
                                                      fit: BoxFit.cover)),
                                            ),
                                            AppServices.addHeight(5),
                                            Text(videosList[i].name,
                                                style: textTheme.fs_14_bold),
                                            Text(videosList[i].description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: textTheme.fs_10_regular)
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 15,
                                      right: 12,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: GetColors.black
                                                .withValues(alpha: 0.3)),
                                        child: IconButton(
                                            onPressed: () {
                                              checkFolderExists(
                                                  "fodx/templates/${videosList[i].id}.zip",
                                                  videosList[i]);
                                            },
                                            icon: const Icon(
                                              Icons.download,
                                              color: GetColors.white,
                                            )),
                                      ),
                                    )
                                  ],
                                );

                                // GestureDetector(
                                //     onTap: () async {
                                //       _onEdit(videosList[i].path, context);
                                //     },
                                //     child: FunctionsController.checkFileIsVideo(
                                //             videosList[i].path)
                                //         ? Container(
                                //             alignment: Alignment.center,
                                //             decoration: BoxDecoration(
                                //               borderRadius:
                                //                   BorderRadius.circular(15.r),
                                //               color: GetColors.black,
                                //               image: DecorationImage(
                                //                 image: FileImage(File(
                                //                     videosList[i].thumbnail)),
                                //                 fit: BoxFit.cover,
                                //               ),
                                //             ),
                                //             child: Container(
                                //               decoration: BoxDecoration(
                                //                 color: Colors.black38,
                                //                 borderRadius:
                                //                     BorderRadius.circular(15.r),
                                //               ),
                                //               child: Center(
                                //                   child: Icon(
                                //                 Icons.play_arrow,
                                //                 size: 40.sp,
                                //                 color: GetColors.white,
                                //               )),
                                //             ),
                                //           )
                                //         : ClipRRect(
                                //             borderRadius:
                                //                 BorderRadius.circular(15.r),
                                //             child: CachedNetworkImage(
                                //                 imageUrl: videosList[i].path,
                                //                 fit: BoxFit.cover,
                                //                 placeholder: (context, _) =>
                                //                     Shimmer.fromColors(
                                //                       baseColor: GetColors.black
                                //                           .withValues(alpha:0.1),
                                //                       highlightColor: GetColors
                                //                           .black
                                //                           .withValues(alpha:0.04),
                                //                       child: Container(
                                //                         decoration: BoxDecoration(
                                //                             borderRadius:
                                //                                 BorderRadius
                                //                                     .circular(
                                //                                         15.r),
                                //                             color: GetColors
                                //                                 .black),
                                //                       ),
                                //                     )),
                                //           ));
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          provider.templates.status == ApiStatus.LOADING ||
                  provider.categories.status == ApiStatus.LOADING
              ? const FullScreenLoader()
              : const SizedBox(),
          GetBuilder<AdsController>(
              builder: (controller) => controller.loading
                  ? const FullScreenLoader()
                  : const SizedBox())
        ],
      );
    });
  }

  _onEdit(String fileName, BuildContext context) async {
    final controllerData = Get.find<AdsController>();
    if (FunctionsController.checkFileIsVideo(fileName)) {
      controllerData.setLoading(true);
      try {
        final file =
            await FunctionsController.fileFromImageUrl(image: fileName);
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                VideoEditor(file: file, isFromNetwork: true),
          ),
        );
        controllerData.setLoading(false);
      } catch (e) {
        controllerData.setLoading(false);
      }
    } else if (FunctionsController.checkFileIsImage(fileName)) {
      controllerData.setLoading(true);
      try {
        final file =
            await FunctionsController.fileFromImageUrl(image: fileName);
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => ImageEditorView(
                imagePath: file.path, isFromNetwork: true, imageType: "file"),
          ),
        );
        controllerData.setLoading(false);
      } catch (e) {
        controllerData.setLoading(false);
      }
    }
  }
}
