import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/View/Components/empty_data_view.dart';
import 'package:fodex_new/app_config.dart';
import 'package:fodex_new/data/response/response.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/colors.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/ads_controller.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/screens_controller.dart';
import 'package:fodex_new/view_model/enums/enums.dart';
import 'package:get/get.dart';

import '../../../res/routes/route_constants.dart';
import '../../Components/Loaders/full_screen_loader.dart';
import '../../Components/dialogs/logout_confirmation_dialog.dart';
import '../../Components/error_view.dart';
import '../../Components/primary_app_bar.dart';

class WelcomeLoungeView extends StatefulWidget {
  const WelcomeLoungeView({super.key});

  @override
  State<WelcomeLoungeView> createState() => _WelcomeLoungeViewState();
}

class _WelcomeLoungeViewState extends State<WelcomeLoungeView> {
  final controller = Get.put(ScreensController());
  @override
  void initState() {
    super.initState();
    controller.getScreensForUser();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScreensController>(
        init: controller,
        builder: (_) {
          final screens = controller.screens;
          return Stack(
            children: [
              screens.status == ApiStatus.ERROR
                  ? ErrorView(
                      onRetry: () async => {
                            controller.setScreens(ApiResponse.loading()),
                            await controller.getScreensForUser()
                          })
                  : Scaffold(
                      body: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              const PrimaryAppBar(),
                              Positioned(
                                top: 50.h,
                                right: 20.w,
                                child: IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            return const LogoutConfirmationDialog();
                                          });
                                    },
                                    icon: const Icon(
                                      Icons.logout,
                                      color: GetColors.white,
                                    )),
                              )
                            ],
                          ),
                          Flexible(
                            child: Column(
                              children: [
                                AppServices.addHeight(20),
                                Text("Welcome ${AppConfig.app_name} Lounge",
                                    style: textTheme.fs_24_bold),
                                AppServices.addHeight(15),
                                screens.status == ApiStatus.COMPLETE
                                    ? (screens.data!.isNotEmpty
                                        ? Flexible(
                                            child: ListView.separated(
                                                padding: EdgeInsets.symmetric(
                                                        horizontal: 20.w)
                                                    .copyWith(top: 10),
                                                separatorBuilder: (context,
                                                        i) =>
                                                    AppServices.addHeight(15),
                                                itemCount: screens.data!.length,
                                                itemBuilder: (context, i) {
                                                  final data = screens.data![i];
                                                  return InkWell(
                                                    onTap: () {
                                                      final controller =
                                                          Get.put(
                                                              AdsController());

                                                      controller
                                                          .setSelectedScreen(
                                                              data.screenId);
                                                      controller
                                                          .setSelectedScreenName(
                                                              data.screenName);
                                                      controller
                                                          .setSelectedScreenData(
                                                              data);
                                                      AppServices.pushTo(
                                                          RouteConstants
                                                              .bottom_nav_bar);
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color:
                                                              GetColors.white,
                                                          boxShadow: [
                                                            BoxShadow(
                                                                blurRadius: 8.r,
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
                                                          ]),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            alignment: Alignment
                                                                .center,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        20.w,
                                                                    vertical:
                                                                        30.h),
                                                            color:
                                                                GetColors.grey6,
                                                            child: Icon(
                                                                data.zone ==
                                                                        "Landscape"
                                                                    ? Icons
                                                                        .stay_current_landscape
                                                                    : Icons
                                                                        .stay_current_portrait,
                                                                size: 45.sp),
                                                          ),
                                                          AppServices.addWidth(
                                                              20),
                                                          Expanded(
                                                              child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text.rich(TextSpan(
                                                                  text: data
                                                                      .restaurantName,
                                                                  style: textTheme.fs_16_bold,
                                                                  children: [
                                                                    TextSpan(
                                                                        text:
                                                                            " (${data.spotCode})",
                                                                        style: textTheme
                                                                            .fs_10_regular)
                                                                  ])),
                                                              AppServices
                                                                  .addHeight(5),
                                                              Text.rich(TextSpan(
                                                                  text:
                                                                      "Status: ",
                                                                  style: textTheme.fs_12_bold,
                                                                  children: [
                                                                    TextSpan(
                                                                        text: data
                                                                            .status,
                                                                        style: textTheme
                                                                            .fs_12_regular)
                                                                  ])),
                                                              AppServices
                                                                  .addHeight(2),
                                                              Text.rich(TextSpan(
                                                                  text:
                                                                      "Screen Name: ",
                                                                  style: textTheme.fs_12_bold,
                                                                  children: [
                                                                    TextSpan(
                                                                        text: data
                                                                            .screenName,
                                                                        style: textTheme
                                                                            .fs_12_regular)
                                                                  ])),
                                                              AppServices
                                                                  .addHeight(2),
                                                              Text.rich(TextSpan(
                                                                  text:
                                                                      "Note: ",
                                                                  style: textTheme
                                                                      .fs_12_bold,
                                                                  children: [
                                                                    TextSpan(
                                                                        text: data
                                                                            .screenType,
                                                                        style: textTheme
                                                                            .fs_12_regular)
                                                                  ])),
                                                            ],
                                                          ))
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }))
                                        : const EmptyDataView())
                                    : const SizedBox()
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
              screens.status == ApiStatus.LOADING
                  ? const FullScreenLoader()
                  : const SizedBox()
            ],
          );
        });
  }
}
