import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fodex_new/View/Components/Loaders/full_screen_loader.dart';
import 'package:fodex_new/View/Components/dialogs/edit_ad_confirmation_dialog.dart';
import 'package:fodex_new/View/Screens/video/crop_page.dart';
import 'package:fodex_new/View/Screens/video/export_services.dart';
import 'package:fodex_new/View/Screens/video/video_editor_config.dart';
import 'package:fodex_new/res/colors.dart';
import 'package:fodex_new/res/routes/route_constants.dart';
import 'package:fodex_new/res/utils/utils.dart';
import 'package:get/get.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:video_editor_2/video_editor.dart';

import '../../../res/base_getters.dart';
import '../../../view_model/controllers/getXControllers/ads_controller.dart';
import '../../Components/buttons/border_btn.dart';
import '../../Components/buttons/expanded_btn.dart';
import '../../Components/dialogs/select_grp_dialog.dart';
// import 'video_editor_config.dart';
import 'widgets/export_result.dart';

//-------------------//
//VIDEO EDITOR SCREEN//
//-------------------//

class VideoEditor extends StatefulWidget {
  final String fileUrl;
  final bool isFromNetwork;
  final String aspectRatio;
  final bool isFromTemplate;
  const VideoEditor(
      {super.key,
      required this.file,
      this.fileUrl = "",
      this.isFromNetwork = false,
      this.aspectRatio = "9:16",
      this.isFromTemplate = false});

  final File file;

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  late final VideoEditorController _controller = VideoEditorController.file(
    XFile(widget.file.path),
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(seconds: 15),
  );

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    print("Current picked file path : ${widget.file.path}");
    _controller
        .initialize(
            aspectRatio: double.parse(widget.aspectRatio.split(":").first) /
                double.parse(widget.aspectRatio.split(":").last))
        .then((_) {
      _controller.applyCacheCrop();
      setState(() {});
    }).catchError((error) {
      // handle minumum duration bigger than video duration error
      Navigator.pop(context);
    }, test: (e) => e is VideoMinDurationError);
  }

  @override
  void dispose() async {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    ExportService.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );

  Future<void> _exportVideo(String videoName) async {
    if (!widget.isFromTemplate) {
      AppServices.popView(context);
    }

    _exportingProgress.value = 0;
    _isExporting.value = true;
    // NOTE: To use `-crf 1` and [VideoExportPreset] you need `ffmpeg_kit_flutter_min_gpl` package (with `ffmpeg_kit` only it won't work)
    try {
      // _controller.applyCacheCrop();

      final config = VideoFFmpegVideoEditorConfig(
        _controller,
        isFiltersEnabled: true,
      );

      await ExportService.runFFmpegCommand(
        await config.getExecuteConfig(),
        onProgress: (stats) {
          _exportingProgress.value =
              config.getFFmpegProgress(stats.getTime().truncate());
        },
        onError: (e, s) {
          print(e);
          print(s);
          _showErrorSnackBar("Error on export video :(");
        },
        onCompleted: (File file) async {
          print(widget.file.path);
          print(file.path);
          print(
              "Video name ****************************************************");
          print(videoName);
          _isExporting.value = false;
          if (!mounted) return;
          // print(
          //     "Video Export ****************************************************");
          setState(() {
            _loading = true;
          });

          if (widget.isFromTemplate) {
            Navigator.pop(context, file);
            return;
          } else {
            try {
              if (widget.fileUrl.isEmpty) {
                // Fire-and-forget upload - returns upload ID, doesn't wait for completion
                final uploadId = await Get.find<AdsController>().addNewAd(file,
                    sampleTemplateName: videoName,
                    fileName: "$videoName.${file.path.split(".").last}",
                    previousFile:
                        widget.isFromNetwork == true ? widget.file : null);

                // Don't show success message yet, let background upload handle it
                // Pop back immediately so user can continue working
                Navigator.pop(context);
              } else {
                // Fire-and-forget update
                final uploadId = await Get.find<AdsController>().updateAd(file,
                    previousFileNetworkUrl: widget.fileUrl,
                    previousFileUrl: widget.file.path);

                Navigator.pop(context);
              }
            } catch (e) {
              Utils.showErrorSnackbar(message: e.toString(), showLogout: true);
            }
          }

          setState(() {
            _loading = false;
          });
          AppServices.pushAndRemoveUntil(RouteConstants.welcome_lounge_view);
          AppServices.pushTo(RouteConstants.bottom_nav_bar, argument: true);
        },
      );
    } catch (e) {
      print(
          "Error on exporting video *****************************************************************");
      print(e);
      print(
          "Error on exporting video End *****************************************************************");
      _showErrorSnackBar("Error on export video :(");
      setState(() {
        _loading = false;
      });
    }
  }

  void _exportCover() async {
    final config = CoverFFmpegVideoEditorConfig(_controller);
    final execute = await config.getExecuteConfig();
    if (execute == null) {
      _showErrorSnackBar("Error on cover exportation initialization.");
      return;
    }

    await ExportService.runFFmpegCommand(
      execute,
      onError: (e, s) => _showErrorSnackBar("Error on cover exportation :("),
      onCompleted: (cover) {
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (_) => CoverResultPopup(cover: File(cover.path)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.black,
            body: _controller.initialized
                ? SafeArea(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            _topNavBar(),
                            Expanded(
                              child: DefaultTabController(
                                length: 1,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: TabBarView(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        children: [
                                          Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              CropGridViewer.preview(
                                                  controller: _controller),
                                              AnimatedBuilder(
                                                animation: _controller.video,
                                                builder: (_, __) =>
                                                    AnimatedOpacity(
                                                  opacity: _controller.isPlaying
                                                      ? 0
                                                      : 1,
                                                  duration:
                                                      kThemeAnimationDuration,
                                                  child: GestureDetector(
                                                    onTap:
                                                        _controller.video.play,
                                                    child: Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons.play_arrow,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          // CoverViewer(controller: _controller)
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 200,
                                      margin: const EdgeInsets.only(top: 10),
                                      child: Column(
                                        children: [
                                          const TabBar(
                                            tabs: [
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        child: Icon(
                                                            Icons.content_cut)),
                                                    Text('Trim')
                                                  ]),
                                              // Row(
                                              //   mainAxisAlignment:
                                              //       MainAxisAlignment.center,
                                              //   children: [
                                              //     Padding(
                                              //         padding:
                                              //             EdgeInsets.all(5),
                                              //         child: Icon(
                                              //             Icons.video_label)),
                                              //     Text('Cover')
                                              //   ],
                                              // ),
                                            ],
                                          ),
                                          Expanded(
                                            child: TabBarView(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: _trimSlider(),
                                                ),
                                                // _coverSelection(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ValueListenableBuilder(
                                      valueListenable: _isExporting,
                                      builder:
                                          (_, bool export, Widget? child) =>
                                              AnimatedSize(
                                        duration: kThemeAnimationDuration,
                                        child: export ? child : null,
                                      ),
                                      child: AlertDialog(
                                        title: ValueListenableBuilder(
                                          valueListenable: _exportingProgress,
                                          builder: (_, double value, __) =>
                                              Text(
                                            "Exporting video ${(value * 100).ceil()}%",
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
              child: Row(
                children: [
                  ExpandedBorderButton(
                    onPressed: () {
                      AppServices.popView(context);
                    },
                    title: 'Back',
                    color: GetColors.white,
                  ),
                  AppServices.addWidth(20),
                  ExpandedButton(
                      onPressed: () {
                        if (_controller.endTrim.inSeconds < 14) {
                          print(_controller.endTrim.inSeconds);
                          Utils.showErrorSnackbar(
                              message:
                                  "The video should be atleast 15 seconds.");
                          return;
                        }
                        if (widget.isFromTemplate) {
                          _exportVideo(widget.fileUrl);
                          return;
                        }
                        if (widget.fileUrl.isNotEmpty) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return EditAdConfirmationDialog(
                                    onSave: () => _exportVideo(widget.fileUrl));
                              });
                          // return;
                        } else {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return SelectGroupDialog(
                                    loading: _loading,
                                    onSave: (String videoName) {
                                      if (Get.find<AdsController>().ads.any(
                                          (element) =>
                                              element.fileName
                                                  .split("/")
                                                  .last
                                                  .split("-")
                                                  .last
                                                  .split(".")
                                                  .first ==
                                              videoName.trim())) {
                                        Utils.showErrorSnackbar(
                                            message:
                                                "This name has already been used.");
                                        return;
                                      }
                                      _exportVideo(videoName);
                                    });
                              });
                        }
                      },
                      title: widget.isFromTemplate ? 'Use Template' : 'Next',
                      color: GetColors.primary),
                ],
              ),
            ),
          ),
          _loading ? const FullScreenLoader() : const SizedBox(),
        ],
      ),
    );
  }

  Widget _topNavBar() {
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.exit_to_app, color: GetColors.white),
                tooltip: 'Leave editor',
              ),
            ),
            const VerticalDivider(endIndent: 22, indent: 22),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.left),
                icon: const Icon(Icons.rotate_left, color: GetColors.white),
                tooltip: 'Rotate unclockwise',
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.right),
                icon: const Icon(Icons.rotate_right, color: GetColors.white),
                tooltip: 'Rotate clockwise',
              ),
            ),
            if (!widget.isFromTemplate)
              Expanded(
                child: IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => CropPage(controller: _controller),
                    ),
                  ),
                  icon: const Icon(Icons.crop, color: GetColors.white),
                  tooltip: 'Open crop screen',
                ),
              ),
            if (!widget.isFromTemplate)
              const VerticalDivider(endIndent: 22, indent: 22),
            Expanded(
              child: PopupMenuButton(
                tooltip: 'Open export menu',
                icon: const Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: _exportCover,
                    child: const Text('Export cover'),
                  ),
                  // PopupMenuItem(
                  //   onTap: _exportVideo,
                  //   child: const Text('Export video'),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          _controller.video,
        ]),
        builder: (_, __) {
          final int duration = _controller.videoDuration.inSeconds;
          final double pos = _controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt())),
                  style: const TextStyle(color: GetColors.white)),
              const Expanded(child: SizedBox()),
              AnimatedOpacity(
                opacity: _controller.isTrimming ? 1 : 0,
                duration: kThemeAnimationDuration,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    formatter(_controller.startTrim),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    formatter(_controller.endTrim),
                  ),
                ]),
              ),
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          controller: _controller,
          height: height,
          horizontalMargin: height / 4,
          child: TrimTimeline(
            controller: _controller,
            padding: const EdgeInsets.only(top: 10),
            textStyle: const TextStyle(color: GetColors.white),
          ),
        ),
      )
    ];
  }

  Widget _coverSelection() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: CoverSelection(
            controller: _controller,
            size: height + 10,
            quantity: 8,
            selectedCoverBuilder: (cover, size) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  cover,
                  Icon(
                    Icons.check_circle,
                    color: const CoverSelectionStyle().selectedBorderColor,
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
