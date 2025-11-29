// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/View/Components/Loaders/full_screen_loader.dart';
import 'package:fodex_new/app_config.dart';
import 'package:fodex_new/data/network/network_api_services.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/res/routes/route_constants.dart';
import 'package:fodex_new/res/utils/utils.dart';
import 'package:fodex_new/view_model/enums/enums.dart';
import 'package:fodex_new/view_model/models/Instagram/insta_media_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
// import 'package:insta_login/insta_view.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../res/base_getters.dart';
import '../../../res/colors.dart';
import '../../../res/icons_and_images.dart';
import '../../../view_model/controllers/function_controller.dart';
import '../../../view_model/controllers/getXControllers/ads_controller.dart';
import '../image/image_editor.dart';
import '../video/video_editor.dart';

class InstaGramView extends StatefulWidget {
  const InstaGramView({super.key});

  @override
  State<InstaGramView> createState() => InstaGramViewState();
}

class InstaGramViewState extends State<InstaGramView> {
  Future<void> _logIn(String code) async {
    try {
      final http.Response response = await http.post(
          Uri.parse("https://api.instagram.com/oauth/access_token"),
          body: {
            "client_id": InstagramConstant.clientID,
            "redirect_uri": InstagramConstant.redirectUri,
            "client_secret": InstagramConstant.appSecret,
            "code": code,
            "grant_type": "authorization_code"
          });
      // Step 2. Change Instagram Short Access Token -> Long Access Token.
      final http.Response responseLongAccessToken = await http.get(Uri.parse(
          'https://graph.instagram.com/access_token?grant_type=ig_exchange_token&client_secret=${InstagramConstant.appSecret}&access_token=${json.decode(response.body)['access_token']}'));

      final http.Response responseUserData = await http.get(Uri.parse(
          'https://graph.instagram.com/${json.decode(response.body)['user_id'].toString()}?fields=id,username,account_type,media_count&access_token=${json.decode(responseLongAccessToken.body)['access_token']}'));
      prefs.put("insta_token",
          json.decode(responseLongAccessToken.body)['access_token']);
      prefs.put(
          "insta_userid", json.decode(response.body)['user_id'].toString());
      prefs.put(
          "insta_username", json.decode(responseUserData.body)['username']);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SocialMediaView(insta: {
                    "token": json
                        .decode(responseLongAccessToken.body)['access_token'],
                    "userid": json.decode(response.body)['user_id'],
                    "username": json.decode(responseUserData.body)['username']
                  }, logout: logout)));
    } catch (e) {
      print(e.toString());
    }
  }

  bool showInstaLogin = false;
  bool loading = false;

  findToken() async {
    setState(() {
      loading = true;
    });
    var token = prefs.get("insta_token");
    var userid = prefs.get("insta_userid");
    var username = prefs.get("insta_username");

    if (token != null && userid != null && username != null) {
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          loading = false;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SocialMediaView(insta: {
                      "token": token,
                      "userid": userid,
                      "username": username
                    }, logout: logout)));
      });
    } else {
      setState(() {
        loading = false;
        showInstaLogin = true;
      });
    }
  }

  late WebViewController webViewController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    findToken();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            print(progress);
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(InstagramConstant.redirectUri)) {
              final startIndex = request.url.indexOf('code=');
              final endIndex = request.url.lastIndexOf('#');
              final code = request.url.substring(startIndex + 5, endIndex);
              _logIn(code);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(InstagramConstant.url), headers: {
        "User-Agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
      });
  }

  final WebViewCookieManager cookieManager = WebViewCookieManager();

  logout() async {
    await webViewController.clearLocalStorage();
    await cookieManager.clearCookies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : !showInstaLogin
              ? const Center(child: Text("PLease wait ...."))
              : WebViewWidget(
                  controller: webViewController,
                ),
    ));
  }
}

/// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

class SocialMediaView extends StatefulWidget {
  // final InstagramModel instaData;
  final Map<String, dynamic> insta;
  final Function logout;
  const SocialMediaView({super.key, required this.insta, required this.logout});

  @override
  State<SocialMediaView> createState() => _SocialMediaViewState();
}

class _SocialMediaViewState extends State<SocialMediaView> {
  final RxBool _loading = false.obs;

  late String nexturl =
      "https://graph.instagram.com/${widget.insta['userid']}/media?fields=id,caption,media_type,thumbnail_url,media_url,children{media_url,media_type},permalink,username&access_token=${widget.insta['token']!}";

  @override
  void initState() {
    super.initState();
    initialize();
    _scrollController.addListener(_scrollListener);
  }

  RxList<InstaMediaModel> videoUrls = <InstaMediaModel>[].obs;

  Future<List<InstaMediaModel>> fetchVideos(
      BuildContext context, String accessToken) async {
    try {
      final videoUrl = nexturl;
      final response = await NetworkApiService().getGetApiResponse(videoUrl);

      print(response);
      nexturl = response['paging'] != null && response['paging']['next'] != null
          ? response['paging']['next']
          : "";

      if (response['data'] != null) {
        return (response['data'] as List)
            .map((e) => InstaMediaModel.fromJson(json: e))
            .toList();
      }
    } catch (e) {
      Utils.showErrorSnackbar(message: e.toString());
    }

    return <InstaMediaModel>[];
  }

  final ScrollController _scrollController = ScrollController();

  // Scroll listener to trigger fetch when user reaches the end
  void _scrollListener() async {
    if (_scrollController.position.extentAfter < 100) {
      print("Reached the bottom of the list");
      if (nexturl.isNotEmpty && !_loading.value) {
        await initialize();
      }
    }
  }

  initialize() async {
    _loading(true);
    var v = await fetchVideos(context, widget.insta['token']!);
    for (var video in v) {
      video.generateThumbnail();
      if (video.children.isNotEmpty) {
        for (var children in video.children) {
          children.generateThumbnail();
        }
      }
    }
    videoUrls.addAll(v);
    _loading(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        AppServices.pushAndRemoveUntil(RouteConstants.welcome_lounge_view);
        AppServices.pushTo(RouteConstants.bottom_nav_bar, argument: true);
        return true;
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              forceMaterialTransparency: true,
              title: Text("${widget.insta['username']}"),
              leading: IconButton(
                onPressed: () {
                  AppServices.pushAndRemoveUntil(
                      RouteConstants.welcome_lounge_view);
                  AppServices.pushTo(RouteConstants.bottom_nav_bar,
                      argument: true);
                },
                icon: const Icon(Icons.arrow_back),
              ),
              actions: [
                TextButton.icon(
                    onPressed: () async {
                      prefs.delete("insta_token");
                      prefs.delete("insta_userid");
                      prefs.delete("insta_username");

                      await widget.logout();
                      AppServices.pushAndRemoveUntil(
                          RouteConstants.welcome_lounge_view);
                      AppServices.pushTo(RouteConstants.bottom_nav_bar,
                          argument: true);
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"))
              ],
            ),
            body: SafeArea(
                child: Obx(
              () => _loading.value == true
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : widget.insta['token'] == null ||
                          widget.insta['token']!.isEmpty
                      ? const Center(
                          child: Text("Unable to get Data. Try Again Later..."))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 15.h),
                          itemCount: videoUrls.length,
                          shrinkWrap: true,
                          itemBuilder: (context, i) {
                            final video = videoUrls[i];
                            return Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                            radius: 18.r,
                                            backgroundImage: const AssetImage(
                                                GetImages.dummy_profile)),
                                        AppServices.addWidth(10),
                                        Expanded(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                    widget.insta['username']
                                                        .toString(),
                                                    style:
                                                        textTheme.fs_12_bold),
                                                AppServices.addWidth(2),
                                                Icon(Icons.verified,
                                                    color: GetColors.blue,
                                                    size: 12.sp)
                                              ],
                                            ),
                                            // Text("Tokyo, Japan",
                                            //     style: textTheme.fs_10_regular
                                            //         .copyWith(color: GetColors.black3))
                                          ],
                                        )),
                                        AppServices.addWidth(10),
                                        PopupMenuButton(
                                            icon: Icon(Icons.more_horiz,
                                                size: 20.sp),
                                            itemBuilder: (context) => [])
                                      ],
                                    ),
                                  ),
                                  AppServices.addHeight(5),
                                  AspectRatio(
                                      aspectRatio: 1,
                                      child: InstagramMediaView(video: video)),
                                  // AppServices.addHeight(10),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 10.h),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                              text:
                                                  "${widget.insta['username']} ",
                                              style: textTheme.fs_12_bold,
                                              children: [
                                                TextSpan(
                                                    text: video.caption,
                                                    style:
                                                        textTheme.fs_12_regular)
                                              ]),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        AppServices.addHeight(15),
                                        Text(
                                            DateFormat("MMMM dd, yyyy").format(
                                                DateTime.parse(
                                                    video.timestamp)),
                                            style: textTheme.fs_10_regular
                                                .copyWith(
                                                    color: GetColors.black
                                                        .withValues(
                                                            alpha: 0.4)))
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          }),
            )),
          ),
          GetBuilder<AdsController>(
              builder: (controller) => controller.loading
                  ? const FullScreenLoader()
                  : const SizedBox())
        ],
      ),
    );
  }
}

class InstagramMediaView extends StatelessWidget {
  final InstaMediaModel video;
  const InstagramMediaView({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return video.mediaType == InstagramMediaType.IMAGE
        ? GestureDetector(
            onTap: () {
              _onEdit(video.mediaType, video.mediaUrl, context);
            },
            child: CachedNetworkImage(
              imageUrl: video.mediaUrl,
              fit: BoxFit.cover,
              placeholder: (context, v) => Shimmer.fromColors(
                baseColor: GetColors.black.withValues(alpha: 0.1),
                highlightColor: GetColors.black.withValues(alpha: 0.04),
                child: Container(
                  decoration: const BoxDecoration(color: GetColors.black),
                ),
              ),
            ),
          )
        : video.mediaType == InstagramMediaType.VIDEO
            ? InstagramVideoPlayer(video: video.mediaUrl, type: video.mediaType)

            // video.thumbnail.startsWith("http")
            //     ? CachedNetworkImage(
            //         imageUrl: video.thumbnail,
            //         fit: BoxFit.cover,
            //         placeholder: (context, v) => Shimmer.fromColors(
            //           baseColor: GetColors.black.withValues(alpha:0.1),
            //           highlightColor: GetColors.black.withValues(alpha:0.04),
            //           child: Container(
            //             decoration: const BoxDecoration(color: GetColors.black),
            //           ),
            //         ),
            //       )
            //     : Image.file(File(video.thumbnail), fit: BoxFit.cover)
            : InstaMediaCarousel(video: video);
  }
}

// =====================================================================================================================
// =============================================== Instagram Video Player ==============================================
// =====================================================================================================================

class InstagramVideoPlayer extends StatefulWidget {
  final String video;
  final InstagramMediaType type;
  const InstagramVideoPlayer(
      {super.key, required this.video, required this.type});

  @override
  State<InstagramVideoPlayer> createState() => _InstagramVideoPlayerState();
}

class _InstagramVideoPlayerState extends State<InstagramVideoPlayer> {
  late VideoPlayerController _videoPlayer;

  initializeVideoController() {
    _videoPlayer = VideoPlayerController.networkUrl(Uri.parse(widget.video),
        videoPlayerOptions: VideoPlayerOptions())
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {
          _videoPlayer.play();
        });
      })
      ..addListener(() {
        if (_videoPlayer.value.position == _videoPlayer.value.duration) {
          // Video has completed, you can handle it as needed
        }
        setState(() {});
      });
  }

  @override
  void initState() {
    super.initState();
    initializeVideoController();
  }

  @override
  void dispose() {
    try {
      _videoPlayer.dispose();
      _videoPlayer.value.isPlaying ? _videoPlayer.pause() : null;
    } catch (e) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _videoPlayer.value.isInitialized
        ? Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Shimmer.fromColors(
                baseColor: GetColors.black.withValues(alpha: 0.1),
                highlightColor: GetColors.black.withValues(alpha: 0.04),
                child: Container(
                  decoration: const BoxDecoration(color: GetColors.black),
                ),
              ),
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                    width: _videoPlayer.value.size.width,
                    height: _videoPlayer.value.size.height,
                    child: VideoPlayer(_videoPlayer)),
              ),
              _ControlsOverlay(
                  controller: _videoPlayer,
                  video: widget.video,
                  type: widget.type),
            ],
          )
        : Shimmer.fromColors(
            baseColor: GetColors.black.withValues(alpha: 0.1),
            highlightColor: GetColors.black.withValues(alpha: 0.04),
            child: Container(
              decoration: const BoxDecoration(color: GetColors.black),
            ),
          );
  }
}

class _ControlsOverlay extends StatelessWidget {
  final String video;
  final InstagramMediaType type;
  const _ControlsOverlay(
      {required this.controller, required this.video, required this.type});

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
            _onEdit(type, video, context);
          },
          onDoubleTap: () {
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
      ],
    );
  }
}

// =====================================================================================================================
// =============================================== Insta Carousel Slider ===============================================
// =====================================================================================================================

class InstaMediaCarousel extends StatelessWidget {
  InstaMediaCarousel({
    super.key,
    required this.video,
  });

  final InstaMediaModel video;

  final RxInt _activeIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
            items: video.children.map((e) {
              return e.mediaType == InstagramMediaType.IMAGE
                  ? GestureDetector(
                      onTap: () {
                        _onEdit(e.mediaType, e.mediaUrl, context);
                      },
                      child: CachedNetworkImage(
                        imageUrl: e.mediaUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, v) => Shimmer.fromColors(
                          baseColor: GetColors.black.withValues(alpha: 0.1),
                          highlightColor:
                              GetColors.black.withValues(alpha: 0.04),
                          child: Container(
                            decoration:
                                const BoxDecoration(color: GetColors.black),
                          ),
                        ),
                      ),
                    )
                  : e.mediaType == InstagramMediaType.VIDEO
                      ? InstagramVideoPlayer(
                          video: e.mediaUrl, type: e.mediaType)
                      // e.thumbnail.startsWith("http")
                      //     ? CachedNetworkImage(
                      //         imageUrl: e.thumbnail,
                      //         fit: BoxFit.cover,
                      //         placeholder: (context, v) => Shimmer.fromColors(
                      //           baseColor: GetColors.black.withValues(alpha:0.1),
                      //           highlightColor:
                      //               GetColors.black.withValues(alpha:0.04),
                      //           child: Container(
                      //             decoration: const BoxDecoration(
                      //                 color: GetColors.black),
                      //           ),
                      //         ),
                      //       )
                      //     : Image.file(File(e.thumbnail), fit: BoxFit.cover)
                      : const SizedBox();
            }).toList(),
            options: CarouselOptions(
                onPageChanged: (i, r) => _activeIndex(i),
                viewportFraction: 1,
                aspectRatio: 1,
                enlargeCenterPage: false)),
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10)
                          .copyWith(bottom: 10.h),
                      decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(15.r)),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 10.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...List.generate(
                            video.children.length,
                            (index) => AnimatedContainer(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              duration: const Duration(milliseconds: 500),
                              height: 5,
                              width: _activeIndex.value == index ? 30 : 10,
                              decoration: const BoxDecoration(
                                  color: GetColors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

_onEdit(InstagramMediaType type, String fileName, BuildContext context) async {
  final controllerData = Get.find<AdsController>();
  if (type == InstagramMediaType.VIDEO) {
    controllerData.setLoading(true);
    final file = await FunctionsController.fileFromImageUrl(image: fileName);
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            VideoEditor(file: file, isFromNetwork: true
                // duration: info!.duration!.truncate(),
                ),
      ),
    );
    controllerData.setLoading(false);
  } else if (type == InstagramMediaType.IMAGE) {
    controllerData.setLoading(true);
    final file = await FunctionsController.fileFromImageUrl(image: fileName);
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ImageEditorView(
            imagePath: file.path, isFromNetwork: true, imageType: "file"),
      ),
    );
    controllerData.setLoading(false);
  }
}
