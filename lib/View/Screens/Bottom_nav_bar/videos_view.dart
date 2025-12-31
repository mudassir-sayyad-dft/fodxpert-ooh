// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/View/Components/Loaders/full_screen_loader.dart';
import 'package:fodex_new/View/Components/dialogs/delete_ad_confirmation_dialog.dart';
import 'package:fodex_new/View/Components/empty_data_view.dart';
import 'package:fodex_new/View/Components/primary_app_bar.dart';
import 'package:fodex_new/View/Components/uploading_ad_shimmer.dart';
import 'package:fodex_new/View/Screens/image/image_editor.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/colors.dart';
import 'package:fodex_new/res/routes/route_constants.dart';
import 'package:fodex_new/res/utils/utils.dart';
import 'package:fodex_new/view_model/controllers/function_controller.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/ads_controller.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/templates_controller.dart';
import 'package:fodex_new/view_model/controllers/upload_service.dart';
import 'package:fodex_new/view_model/models/Ads/ads_model.dart';
import 'package:fodex_new/view_model/models/templates/file_storage.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

import '../video/video_editor.dart';

class VideosView extends StatefulWidget {
  final bool shouldDelay;
  const VideosView({super.key, this.shouldDelay = false});

  @override
  State<VideosView> createState() => _VideosViewState();
}

class _VideosViewState extends State<VideosView> {
  late VideoPlayerController _controller;

  int currentVideoIndex = 0;
  AdsModel selectedAd = AdsModel();

  initialize() async {
    await getAds();
    _initializeVideoController();
  }

  getAds() async {
    final adsController = Get.find<AdsController>();
    adsController.setAds([]);

    await adsController.getAds();
  }

  void _initializeVideoController() async {
    final adsController = Get.find<AdsController>();

    if (adsController.ads.isNotEmpty) {
      selectedAd = adsController.ads[currentVideoIndex];
      setState(() {});
      if (adsController.ads[currentVideoIndex].checkIsVideo() ||
          FunctionsController.checkFileIsVideo(
              adsController.ads[currentVideoIndex].thumbnail)) {
        print(adsController.ads[currentVideoIndex].thumbnail);
        final chosenUrl = FunctionsController.checkFileIsVideo(
                adsController.ads[currentVideoIndex].thumbnail)
            ? adsController.ads[currentVideoIndex].thumbnail
            : adsController.ads[currentVideoIndex].fileName;
        try {
          print('Initializing video player with URL: $chosenUrl');
          _controller = VideoPlayerController.networkUrl(Uri.parse(chosenUrl),
              videoPlayerOptions: VideoPlayerOptions())
            ..setLooping(false)
            ..initialize().then((_) {
              setState(() {
                _controller.play();
              });
            }).catchError((e) {
              print('Video initialize failed: $e');
            })
            ..addListener(() {
              if (_controller.value.position == _controller.value.duration) {
                _controller.seekTo(const Duration(seconds: 0));
                _controller.pause();
              }
              setState(() {});
            });
        } catch (e) {
          print('Error creating VideoPlayerController: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    try {
      _controller.dispose();
      _controller.value.isPlaying ? _controller.pause() : null;
    } catch (e) {}
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.shouldDelay
        ? Future.delayed(Duration.zero, () async => initialize())
        : initialize();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdsController>(builder: (adsController) {
      final ads = adsController.ads;

      return Stack(
        children: [
          Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PrimaryAppBar(
                    action: IconButton(
                        onPressed: () async => await adsController.getAds(),
                        color: GetColors.white,
                        icon: Icon(Icons.refresh))),
                adsController.loading
                    ? const Flexible(
                        child: FullScreenLoader(color: GetColors.white))
                    : ads.isEmpty
                        ? const EmptyDataView()
                        : Flexible(
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: (16 / 9).sp,
                                child: selectedAd.fileName.isNotEmpty &&
                                        selectedAd.checkIsVideo()
                                    ? (_controller.value.isInitialized
                                        ? Stack(
                                            alignment: Alignment.bottomCenter,
                                            children: <Widget>[
                                              FittedBox(
                                                fit: BoxFit.contain,
                                                child: SizedBox(
                                                    width: _controller
                                                        .value.size.width,
                                                    height: _controller
                                                        .value.size.height,
                                                    child: VideoPlayer(
                                                        _controller)),
                                              ),
                                              _ControlsOverlay(
                                                  controller: _controller),
                                            ],
                                          )
                                        : Shimmer.fromColors(
                                            baseColor: GetColors.black
                                                .withValues(alpha: .1),
                                            highlightColor: GetColors.black
                                                .withValues(alpha: 0.04),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                  color: GetColors.black),
                                            ),
                                          ))
                                    : selectedAd.checkIsImage()
                                        ? Image.network(selectedAd.fileName,
                                            fit: BoxFit.contain)
                                        : (FunctionsController.checkFileIsVideo(
                                                selectedAd.thumbnail)
                                            ? (_controller.value.hasError
                                                ? Shimmer.fromColors(
                                                    baseColor: GetColors.black
                                                        .withValues(alpha: .5),
                                                    highlightColor: GetColors
                                                        .black
                                                        .withValues(
                                                            alpha: 0.09),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 20),
                                                      child: Column(
                                                          spacing: 10,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            CircularProgressIndicator
                                                                .adaptive(),
                                                            Text(
                                                                "Loading ...."),
                                                            Text(
                                                              "Preview loading in progress. Estimated time: 5-7 minutes. You can proceed with other tasks.",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ]),
                                                    ),
                                                  )
                                                : _controller
                                                        .value.isInitialized
                                                    ? Stack(
                                                        alignment: Alignment
                                                            .bottomCenter,
                                                        children: <Widget>[
                                                          FittedBox(
                                                            fit: BoxFit.contain,
                                                            child: SizedBox(
                                                                width:
                                                                    _controller
                                                                        .value
                                                                        .size
                                                                        .width,
                                                                height:
                                                                    _controller
                                                                        .value
                                                                        .size
                                                                        .height,
                                                                child: VideoPlayer(
                                                                    _controller)),
                                                          ),
                                                          _ControlsOverlay(
                                                              controller:
                                                                  _controller),
                                                        ],
                                                      )
                                                    : Shimmer.fromColors(
                                                        baseColor: GetColors
                                                            .black
                                                            .withValues(
                                                                alpha: .1),
                                                        highlightColor:
                                                            GetColors
                                                                .black
                                                                .withValues(
                                                                    alpha:
                                                                        0.04),
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                                  color: GetColors
                                                                      .black),
                                                        ),
                                                      ))
                                            : Image.network(
                                                selectedAd.thumbnail,
                                                errorBuilder: (context, error,
                                                        stacktrace) =>
                                                    Shimmer.fromColors(
                                                      baseColor: GetColors.black
                                                          .withValues(
                                                              alpha: 0.1),
                                                      highlightColor: GetColors
                                                          .black
                                                          .withValues(
                                                              alpha: 0.04),
                                                      child: Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                                color: GetColors
                                                                    .black),
                                                      ),
                                                    ))),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w)
                                    .copyWith(top: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                        adsController.selectedScreenData.zone ==
                                                "landscape"
                                            ? Icons.stay_current_landscape
                                            : Icons.stay_current_portrait,
                                        size: 30.sp),
                                    AppServices.addWidth(10),
                                    Text(adsController.selectedScreenName,
                                        style: textTheme.fs_16_medium),
                                  ],
                                ),
                              ),
                              ads.length < 4
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w),
                                      child: Text(
                                          "Please upload minimum 4 creatives.",
                                          style: textTheme.fs_14_regular
                                              .copyWith(
                                                  color: GetColors.primary)),
                                    )
                                  : ads.length >= 16
                                      ? Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w),
                                          child: Text(
                                              "You can upload only 16 creatives per screen. You have reached the limit to 16 creatives.",
                                              style: textTheme.fs_14_regular
                                                  .copyWith(
                                                      color:
                                                          GetColors.primary)),
                                        )
                                      : const SizedBox(),
                              Expanded(
                                child: Obx(() {
                                  final uploadService =
                                      Get.find<UploadService>();
                                  final uploadingTasks = uploadService
                                      .getActiveUploads()
                                      .where((task) =>
                                          task.screenId ==
                                          adsController.selectedScreen)
                                      .toList();

                                  return ReorderableListView(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 24.h),
                                    onReorder: (int oldIndex, int newIndex) {
                                      // Only allow reordering of actual ads, not uploading tasks
                                      if (oldIndex >= uploadingTasks.length &&
                                          newIndex >= uploadingTasks.length) {
                                        try {
                                          _controller.pause();
                                        } catch (e) {}
                                        setState(() {
                                          if (oldIndex < newIndex) {
                                            newIndex -= 1;
                                          }
                                          final item = ads.removeAt(
                                              oldIndex - uploadingTasks.length);
                                          ads.insert(
                                              newIndex - uploadingTasks.length,
                                              item);
                                          adsController
                                              .updatePlaylistForScreen(ads);
                                        });
                                      }
                                    },
                                    children: [
                                      // Show uploading tasks first
                                      ...uploadingTasks.map((task) {
                                        return Padding(
                                          key: Key('upload_${task.id}'),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 7),
                                          child: UploadingAdShimmer(
                                            fileName: task.fileName,
                                            progress: task.state ==
                                                    UploadState.polling
                                                ? null
                                                : task.progress,
                                            isLongRunning:
                                                task.showTimeoutWarning,
                                          ),
                                        );
                                      }).toList(),
                                      // Show actual ads
                                      ...List.generate(ads.length, (index) {
                                        final ad = ads[index];
                                        return Padding(
                                          key: Key(ad.fileName +
                                              ad.index.toString() +
                                              index.toString()),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 7),
                                          child: InkWell(
                                            onTap: () {
                                              currentVideoIndex = index;
                                              try {
                                                _controller.pause();
                                                _controller.dispose();
                                              } catch (e) {}
                                              _initializeVideoController();
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(4.sp),
                                              decoration: BoxDecoration(
                                                  color: GetColors.white,
                                                  boxShadow:
                                                      currentVideoIndex == index
                                                          ? [
                                                              BoxShadow(
                                                                  blurRadius:
                                                                      8.r,
                                                                  spreadRadius:
                                                                      0.5.r,
                                                                  offset:
                                                                      const Offset(
                                                                          4, 4),
                                                                  color: GetColors
                                                                      .black
                                                                      .withValues(
                                                                          alpha:
                                                                              0.25))
                                                            ]
                                                          : null),
                                              child: Row(
                                                children: [
                                                  ThumbnailPreviewWithGenerateThumbnailOfVideo(
                                                      ad: ad),
                                                  AppServices.addWidth(20),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          ad.displayShortName(),
                                                          maxLines: 3,
                                                          style: textTheme
                                                              .fs_14_bold,
                                                        ),
                                                        AppServices.addHeight(
                                                            4.h),
                                                        Text(
                                                          ad.checkIsVideo()
                                                              ? "Video"
                                                              : ad.checkIsImage()
                                                                  ? "Image"
                                                                  : "Zip",
                                                          style: textTheme
                                                              .fs_14_regular
                                                              .copyWith(
                                                                  color: GetColors
                                                                      .secondary),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuButton(
                                                      color: GetColors.white,
                                                      surfaceTintColor:
                                                          GetColors.white,
                                                      onSelected: (v) async {
                                                        if (v == "Edit") {
                                                          onEdit(ad);
                                                        } else if (v ==
                                                            "Download") {
                                                          onDownload(ad,
                                                              adsController);
                                                        } else {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return DeleteAdConfirmationDialog(
                                                                    isVideo: ad
                                                                        .checkIsVideo(),
                                                                    onDelete: () =>
                                                                        onDelete(
                                                                            ad.displayName));
                                                              });
                                                        }
                                                      },
                                                      itemBuilder: (ctx) => [
                                                            PopupMenuItem(
                                                                value: "Edit",
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .edit_square,
                                                                        size: 20
                                                                            .sp),
                                                                    AppServices
                                                                        .addWidth(
                                                                            10),
                                                                    Text(
                                                                      "Edit",
                                                                      style: textTheme
                                                                          .fs_16_regular,
                                                                    )
                                                                  ],
                                                                )),
                                                            PopupMenuItem(
                                                                value: "Delete",
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .delete,
                                                                        size: 20
                                                                            .sp),
                                                                    AppServices
                                                                        .addWidth(
                                                                            10),
                                                                    Text(
                                                                      "Delete",
                                                                      style: textTheme
                                                                          .fs_16_regular,
                                                                    )
                                                                  ],
                                                                )),
                                                            PopupMenuItem(
                                                                value:
                                                                    "Download",
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .download,
                                                                        size: 20
                                                                            .sp),
                                                                    AppServices
                                                                        .addWidth(
                                                                            10),
                                                                    Text(
                                                                      "Download",
                                                                      style: textTheme
                                                                          .fs_16_regular,
                                                                    )
                                                                  ],
                                                                )),
                                                          ])
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  );
                                }),
                              ),
                            ],
                          ))
              ],
            ),
          ),
        ],
      );
    });
  }

  onDownload(AdsModel ad, AdsController adsController) async {
    if (ad.isZipFile()) {
      await adsController.downloadFile(
          context: context, file: ad.thumbnail, fileName: ad.fileName);
    } else {
      await adsController.downloadFile(context: context, file: ad.fileName);
    }
  }

  onEdit(AdsModel ad) async {
    final controllerData = Get.find<AdsController>();

    // Check if it's a zip file first (video zip or image zip templates)
    if (ad.isZipFile()) {
      Get.find<TemplatesController>().setPreviewData([]);
      await downloadAndUnzipTemplate(ad);
    } else if (ad.checkIsVideo()) {
      controllerData.setLoading(true);
      final file =
          await FunctionsController.fileFromImageUrl(image: ad.fileName);
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              VideoEditor(file: file, fileUrl: ad.fileName
                  // duration: info!.duration!.truncate(),
                  ),
        ),
      ).then((value) => setState(() {
            currentVideoIndex = 0;
            _initializeVideoController();
          }));
      controllerData.setLoading(false);
    } else if (ad.checkIsImage()) {
      controllerData.setLoading(true);
      final file =
          await FunctionsController.fileFromImageUrl(image: ad.fileName);
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => ImageEditorView(
              imagePath: file.path,
              imageType: "file",
              imageNetworkUrl: ad.fileName),
        ),
      ).then((value) => setState(() {
            currentVideoIndex = 0;
            _initializeVideoController();
          }));
      controllerData.setLoading(false);
    }
  }

  downloadAndUnzipTemplate(AdsModel template) async {
    final controller = Get.find<AdsController>();

    final directory = await getTemporaryDirectory();
    final temporaryDirectoryPath = '${directory.path}/fodx';

    /// Generate a clean filename without query parameters or special characters
    String getCleanFileName() {
      // Use displayShortName() which strips UUID/timestamp prefixes
      // Then strip the trailing `.zip` extension to get the base folder name.
      String nameWithExt = template.displayShortName();
      String base =
          nameWithExt.replaceAll(RegExp(r'\.zip$', caseSensitive: false), '');
      // Keep spaces and common characters; fall back if empty/too long
      if (base.isEmpty || base.length > 150) {
        base = 'template_${DateTime.now().millisecondsSinceEpoch}';
      }
      return base;
    }

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

      final cleanFileName = getCleanFileName();
      var path = "$temporaryDirectoryPath/templates/$cleanFileName";

      var fileExist = File(path);
      if (fileExist.existsSync()) {
        fileExist.deleteSync();
      }

      // Use zipUrl if available (new API), otherwise use thumbnail or fileName (old API)
      final downloadUrl = template.zipUrl.isNotEmpty
          ? template.zipUrl
          : template.thumbnail.isNotEmpty
              ? template.thumbnail
              : template.fileName;

      bool downloaded =
          await FileStorage.downloadAndSaveImage(downloadUrl, cleanFileName);
      // Path to index.html inside the unzipped folder structure
      String p =
          "$temporaryDirectoryPath/templates/$cleanFileName/$cleanFileName/index.html";
      if (downloaded) {
        await unzipTemplate(context, cleanFileName, () {
          // Use type field if available to determine routing
          if (template.type.startsWith('video/') ||
              (template.type.isEmpty &&
                  FunctionsController.checkFileIsVideo(template.thumbnail))) {
            print("This is a video thumbnail template");
            AppServices.pushTo(RouteConstants.edit_template_video_view,
                argument: {"template": template, "path": p});
          } else {
            print("This is an image or HTML template");
            AppServices.pushTo(RouteConstants.edit_template_html_view,
                argument: {"template": template, "path": p});
          }
        });
      }

      controller.setLoading(false);
    } catch (e) {
      print('Error downloading/unzipping template: $e');
      controller.setLoading(false);
    }
  }

  Future unzipTemplate(
      BuildContext context, String file, Function() onComplete) async {
    late Directory destinationDir;
    late File zipFile;

    final directory = await getTemporaryDirectory();
    final temporaryDirectoryPath = '${directory.path}/fodx';

    zipFile = File("$temporaryDirectoryPath/templates/$file/$file.zip");
    destinationDir = Directory("$temporaryDirectoryPath/templates/$file");
    try {
      // Delete inner folder if it exists to ensure a clean unzip target
      if (await Directory("${destinationDir.path}/$file").exists()) {
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
          print(progress);
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

  onDelete(String displayName) async {
    await Get.find<AdsController>().deleteAd(fileName: displayName);
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  static const List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  String _formatDuration(Duration duration) {
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : ColoredBox(
                  color: Colors.black26,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(10.sp),
                      decoration: const BoxDecoration(
                          color: GetColors.primary, shape: BoxShape.circle),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 35.sp,
                        semanticLabel: 'Play',
                      ),
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 10.w).copyWith(bottom: 10.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProgressIndicator(
                  controller,
                  allowScrubbing: true,
                ),
                AppServices.addHeight(5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.r),
                          color: GetColors.black.withValues(alpha: 0.45)),
                      child: Text(_formatDuration(controller.value.position),
                          style: textTheme.fs_12_medium
                              .copyWith(color: GetColors.white)),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.r),
                          color: GetColors.black.withValues(alpha: 0.45)),
                      child: Text(_formatDuration(controller.value.duration),
                          style: textTheme.fs_12_medium
                              .copyWith(color: GetColors.white)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            decoration: BoxDecoration(
                color: GetColors.black.withValues(alpha: 0.35),
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(10.r))),
            child: PopupMenuButton<double>(
              initialValue: controller.value.playbackSpeed,
              tooltip: 'Playback speed',
              onSelected: (double speed) {
                controller.setPlaybackSpeed(speed);
              },
              itemBuilder: (BuildContext context) {
                return <PopupMenuItem<double>>[
                  for (final double speed in _examplePlaybackRates)
                    PopupMenuItem<double>(
                      value: speed,
                      child: Text('${speed}x', style: textTheme.fs_14_medium),
                    )
                ];
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  // Using less vertical padding as the text is also longer
                  // horizontally, so it feels like it would need more spacing
                  // horizontally (matching the aspect ratio of the video).
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Text('${controller.value.playbackSpeed}x',
                    style: textTheme.fs_14_regular
                        .copyWith(color: GetColors.white)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GetImage extends StatelessWidget {
  final AdsModel ad;
  const GetImage({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    if (ad.isZipFile()) {
      return Image.network(
        ad.thumbnail,
        width: 90.w,
        height: 80.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stacktrace) => SizedBox(
          width: 90.w,
          height: 80.h,
          child: Shimmer.fromColors(
            baseColor: GetColors.black.withValues(alpha: 0.1),
            highlightColor: GetColors.black.withValues(alpha: 0.04),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: GetColors.black),
            ),
          ),
        ),
      );
    } else if (ad.checkIsImage()) {
      return Image.network(
        ad.fileName,
        width: 90.w,
        height: 80.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: 90.w,
            height: 80.h,
            child: Shimmer.fromColors(
              baseColor: GetColors.black.withValues(alpha: 0.1),
              highlightColor: GetColors.black.withValues(alpha: 0.04),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: GetColors.black),
              ),
            ),
          );
        },
      );
    } else if (ad.checkIsVideo() && ad.thumbnail.isNotEmpty) {
      return Image.file(
        File(ad.thumbnail),
        width: 90.w,
        height: 80.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: 90.w,
            height: 80.h,
            child: Shimmer.fromColors(
              baseColor: GetColors.black.withValues(alpha: 0.1),
              highlightColor: GetColors.black.withValues(alpha: 0.04),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: GetColors.black),
              ),
            ),
          );
        },
      );
    } else {
      return SizedBox(
        width: 90.w,
        height: 80.h,
        child: Shimmer.fromColors(
          baseColor: GetColors.black.withValues(alpha: 0.1),
          highlightColor: GetColors.black.withValues(alpha: 0.04),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: GetColors.black),
          ),
        ),
      );
    }
  }
}

class ProgressIndicator extends StatefulWidget {
  /// Construct an instance that displays the play/buffering status of the video
  /// controlled by [controller].
  ///
  /// Defaults will be used for everything except [controller] if they're not
  /// provided. [allowScrubbing] defaults to false, and [padding] will default
  /// to `top: 5.0`.
  const ProgressIndicator(
    this.controller, {
    super.key,
    this.colors = const VideoProgressColors(),
    required this.allowScrubbing,
    this.padding = const EdgeInsets.only(top: 5.0),
  });

  /// The [VideoPlayerController] that actually associates a video with this
  /// widget.
  final VideoPlayerController controller;

  /// The default colors used throughout the indicator.
  ///
  /// See [VideoProgressColors] for default values.
  final VideoProgressColors colors;

  /// When true, the widget will detect touch input and try to seek the video
  /// accordingly. The widget ignores such input when false.
  ///
  /// Defaults to false.
  final bool allowScrubbing;

  /// This allows for visual padding around the progress indicator that can
  /// still detect gestures via [allowScrubbing].
  ///
  /// Defaults to `top: 5.0`.
  final EdgeInsets padding;

  @override
  State<ProgressIndicator> createState() => _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicator> {
  _ProgressIndicatorState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  late VoidCallback listener;

  VideoPlayerController get controller => widget.controller;

  VideoProgressColors get colors => widget.colors;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    Widget progressIndicator;
    if (controller.value.isInitialized) {
      final int duration = controller.value.duration.inMilliseconds;
      final int position = controller.value.position.inMilliseconds;

      int maxBuffering = 0;
      for (final DurationRange range in controller.value.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }

      progressIndicator = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          LinearProgressIndicator(
            value: maxBuffering / duration,
            valueColor: AlwaysStoppedAnimation<Color>(colors.bufferedColor),
            backgroundColor: colors.backgroundColor,
          ),
          LinearProgressIndicator(
            value: position / duration,
            valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
            backgroundColor: Colors.transparent,
          ),
        ],
      );
    } else {
      progressIndicator = LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
        backgroundColor: colors.backgroundColor,
      );
    }
    final Widget paddedProgressIndicator = Padding(
      padding: widget.padding,
      child: progressIndicator,
    );
    if (widget.allowScrubbing) {
      return VideoScrubber(
        controller: controller,
        child: paddedProgressIndicator,
      );
    } else {
      return paddedProgressIndicator;
    }
  }
}

class ThumbnailPreviewWithVideo extends StatefulWidget {
  final AdsModel ad;
  const ThumbnailPreviewWithVideo({super.key, required this.ad});

  @override
  State<ThumbnailPreviewWithVideo> createState() =>
      _ThumbnailPreviewWithVideoState();
}

class _ThumbnailPreviewWithVideoState extends State<ThumbnailPreviewWithVideo> {
  late VideoPlayerController _controller;

  @override
  initState() {
    super.initState();
    if (FunctionsController.checkFileIsVideo(widget.ad.thumbnail)) {
      try {
        print(
            'Thumbnail preview initializing video with: ${widget.ad.thumbnail}');
        _controller = VideoPlayerController.networkUrl(
            Uri.parse(widget.ad.thumbnail),
            videoPlayerOptions: VideoPlayerOptions())
          ..setLooping(false)
          ..initialize().then((_) {
            setState(() {
              _controller.play();
            });
          }).catchError((e) {
            print('Thumbnail Video init failed: $e');
          })
          ..addListener(() {
            if (_controller.value.position == _controller.value.duration) {
              _controller.seekTo(const Duration(seconds: 0));
              _controller.pause();
            }
            setState(() {});
          });
      } catch (e) {
        print('Error creating thumbnail VideoPlayerController: $e');
      }
    }
  }

  @override
  dispose() {
    try {
      _controller.dispose();
    } catch (e) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.ad.videoTemplateThumbnail);
    return ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: widget.ad.isZipFile()
            ? Image.network(
                widget.ad.thumbnail,
                width: 90.w,
                height: 80.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stacktrace) => SizedBox(
                  width: 90.w,
                  height: 80.h,
                  child: Shimmer.fromColors(
                    baseColor: GetColors.black.withValues(alpha: 0.1),
                    highlightColor: GetColors.black.withValues(alpha: 0.04),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: GetColors.black),
                    ),
                  ),
                ),
              )
            : widget.ad.checkIsImage()
                ? Image.network(
                    widget.ad.fileName,
                    width: 90.w,
                    height: 80.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return SizedBox(
                        width: 90.w,
                        height: 80.h,
                        child: Shimmer.fromColors(
                          baseColor: GetColors.black.withValues(alpha: 0.1),
                          highlightColor:
                              GetColors.black.withValues(alpha: 0.04),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                color: GetColors.black),
                          ),
                        ),
                      );
                    },
                  )
                : (widget.ad.checkIsVideo() && widget.ad.thumbnail.isNotEmpty)
                    ? Image.file(
                        File(widget.ad.thumbnail),
                        width: 90.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return SizedBox(
                            width: 90.w,
                            height: 80.h,
                            child: Shimmer.fromColors(
                              baseColor: GetColors.black.withValues(alpha: 0.1),
                              highlightColor:
                                  GetColors.black.withValues(alpha: 0.04),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.r),
                                    color: GetColors.black),
                              ),
                            ),
                          );
                        },
                      )
                    : SizedBox(
                        width: 90.w,
                        height: 80.h,
                        child: Shimmer.fromColors(
                          baseColor: GetColors.black.withValues(alpha: 0.1),
                          highlightColor:
                              GetColors.black.withValues(alpha: 0.04),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                color: GetColors.black),
                          ),
                        ),
                      ));
  }
}

class ThumbnailPreviewWithGenerateThumbnailOfVideo extends StatelessWidget {
  final AdsModel ad;
  const ThumbnailPreviewWithGenerateThumbnailOfVideo(
      {super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final videoTemplateThumbnail = ad.videoTemplateThumbnail.value;
      final thumbnailUrl = ad.getThumbnailUrl();

      return ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: ad.isZipFile()
              ? (FunctionsController.checkFileIsVideo(ad.thumbnail)
                  ? (videoTemplateThumbnail.isNotEmpty
                      ? Image.file(
                          File(videoTemplateThumbnail),
                          width: 90.w,
                          height: 80.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stacktrace) =>
                              SizedBox(
                            width: 90.w,
                            height: 80.h,
                            child: Shimmer.fromColors(
                              baseColor: GetColors.black.withValues(alpha: 0.1),
                              highlightColor:
                                  GetColors.black.withValues(alpha: 0.04),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.r),
                                    color: GetColors.black),
                              ),
                            ),
                          ),
                        )
                      : FutureBuilder<void>(
                          future: ad.generateVideoTemplateThumbnail(),
                          builder: (context, snapshot) =>
                              snapshot.connectionState == ConnectionState.done
                                  ? Image.file(
                                      File(videoTemplateThumbnail),
                                      width: 90.w,
                                      height: 80.h,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stacktrace) =>
                                              SizedBox(
                                        width: 90.w,
                                        height: 80.h,
                                        child: Shimmer.fromColors(
                                          baseColor: GetColors.black
                                              .withValues(alpha: 0.1),
                                          highlightColor: GetColors.black
                                              .withValues(alpha: 0.04),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                                color: GetColors.black),
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      width: 90.w,
                                      height: 80.h,
                                      child: Shimmer.fromColors(
                                        baseColor: GetColors.black
                                            .withValues(alpha: 0.1),
                                        highlightColor: GetColors.black
                                            .withValues(alpha: 0.04),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                              color: GetColors.black),
                                        ),
                                      ),
                                    )))
                  : // Image zip - use fileUrl as thumbnail preview
                  Image.network(
                      thumbnailUrl,
                      width: 90.w,
                      height: 80.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stacktrace) => SizedBox(
                        width: 90.w,
                        height: 80.h,
                        child: Shimmer.fromColors(
                          baseColor: GetColors.black.withValues(alpha: 0.1),
                          highlightColor:
                              GetColors.black.withValues(alpha: 0.04),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                color: GetColors.black),
                          ),
                        ),
                      ),
                    ))
              : ad.checkIsImage()
                  ? Image.network(
                      ad.fileName,
                      width: 90.w,
                      height: 80.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox(
                          width: 90.w,
                          height: 80.h,
                          child: Shimmer.fromColors(
                            baseColor: GetColors.black.withValues(alpha: 0.1),
                            highlightColor:
                                GetColors.black.withValues(alpha: 0.04),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: GetColors.black),
                            ),
                          ),
                        );
                      },
                    )
                  : (ad.checkIsVideo() && ad.thumbnail.isNotEmpty)
                      ? Image.file(
                          File(ad.thumbnail),
                          width: 90.w,
                          height: 80.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return SizedBox(
                              width: 90.w,
                              height: 80.h,
                              child: Shimmer.fromColors(
                                baseColor:
                                    GetColors.black.withValues(alpha: 0.1),
                                highlightColor:
                                    GetColors.black.withValues(alpha: 0.04),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      color: GetColors.black),
                                ),
                              ),
                            );
                          },
                        )
                      : SizedBox(
                          width: 90.w,
                          height: 80.h,
                          child: Shimmer.fromColors(
                            baseColor: GetColors.black.withValues(alpha: 0.1),
                            highlightColor:
                                GetColors.black.withValues(alpha: 0.04),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: GetColors.black),
                            ),
                          ),
                        ));
    });
  }
}
