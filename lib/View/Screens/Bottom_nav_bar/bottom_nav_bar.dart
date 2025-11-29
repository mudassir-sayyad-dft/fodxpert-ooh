import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/View/Components/upload_video_bottom_sheet.dart';
import 'package:fodex_new/View/Screens/Bottom_nav_bar/user_profile.dart';
import 'package:fodex_new/View/Screens/Bottom_nav_bar/videos_view.dart';
import 'package:fodex_new/res/colors.dart';
import 'package:fodex_new/res/utils/utils.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/ads_controller.dart';
import 'package:get/get.dart';

import '../../Components/Loaders/full_screen_loader.dart';

class BottomNavBar extends StatefulWidget {
  final bool shouldDelay;
  const BottomNavBar({super.key, this.shouldDelay = false});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late List<Widget> screens = [
    VideosView(shouldDelay: widget.shouldDelay),
    const SizedBox(),
    const UserProfileView()
  ];
  List<IconData?> icons = [Icons.home_filled, null, Icons.person];

  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final adsController = Get.find<AdsController>();
    return Stack(
      children: [
        Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: GetColors.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(1000.r)),
            onPressed: () {
              Get.find<AdsController>().ads.length < 16
                  ? showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return const UploadVideoBottomSheet();
                      })
                  : Utils.showErrorSnackbar(
                      message: "You can upload only 16 files for a screen.");
            },
            child: const Icon(Icons.add, color: GetColors.white),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: ClipPath(
            clipper: BottomNavBarClipper(),
            child: BottomAppBar(
              color: GetColors.primary,
              elevation: 0.8,
              surfaceTintColor: GetColors.grey6,
              shape: const CircularNotchedRectangle(),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(icons.length, (i) {
                    return GestureDetector(
                      onTap: icons[i] != null
                          ? () {
                              setState(() => _activeIndex = i);
                            }
                          : null,
                      child: Padding(
                        padding: EdgeInsets.all(5.sp),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icons[i],
                              size: 25.sp,
                              color: _activeIndex == i
                                  ? GetColors.white
                                  : Colors.white60,
                            ),
                            _activeIndex == i
                                ? Icon(
                                    Icons.circle,
                                    size: 7.sp,
                                    color: GetColors.white,
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          body: screens[_activeIndex],
        ),
        Obx(() => adsController.isFileDownload
            ? FullScreenLoader(text: adsController.downloadProgress)
            : const SizedBox())
      ],
    );
  }
}

class BottomNavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height - 50.h);
    path.quadraticBezierTo(
        size.width * 0.1.w, size.height * 0.15.h, size.width * 0.36.w, 0);
    path.lineTo(size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.85.w, size.height * 0.15.h,
        size.width, size.height - 50.h);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
