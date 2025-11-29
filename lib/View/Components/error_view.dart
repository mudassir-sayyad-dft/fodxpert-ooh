import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/View/Components/buttons/expanded_btn.dart';
import 'package:fodex_new/View/Components/dialogs/logout_confirmation_dialog.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/colors.dart';
import 'package:fodex_new/res/icons_and_images.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ErrorView extends StatelessWidget {
  final Function onRetry;
  const ErrorView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GetColors.grey6,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          children: [
            const Expanded(flex: 3, child: SizedBox()),
            Image.asset(
              GetImages.error_image,
            ),
            Text("Oops!", style: textTheme.fs_24_bold),
            AppServices.addHeight(2),
            Text("Something Went Wrong. Please Try Again",
                textAlign: TextAlign.center, style: textTheme.fs_16_regular),
            const Expanded(child: SizedBox()),
            Row(
              spacing: 20,
              children: [
                ExpandedButton(onPressed: () => onRetry(), title: "Retry"),
                ExpandedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => LogoutConfirmationDialog(
                                onLogout: () => showContactUsDialog(context),
                              ));
                    },
                    title: "Logout",
                    color: GetColors.primary)
              ],
            ),
            const Expanded(flex: 3, child: SizedBox()),
          ],
        ),
      ),
    );
  }
}

showContactUsDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 10.h),
          title: const Text("Contact Us", textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Divider(
                color: GetColors.grey4,
                thickness: 1.5,
                indent: 40,
                endIndent: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Need an account? connect now.",
                      style: textTheme.fs_14_medium,
                      textAlign: TextAlign.center),
                ],
              ),
              AppServices.addHeight(10),
              Row(
                children: [
                  AppServices.addWidth(7),
                  Icon(Icons.email_outlined, size: 16.r),
                  AppServices.addWidth(10),
                  Text("support@fodxpert.com", style: textTheme.fs_16_medium),
                ],
              ),
              AppServices.addHeight(10),
              Row(
                children: [
                  AppServices.addWidth(7),
                  Icon(Icons.phone, size: 16.r),
                  AppServices.addWidth(10),
                  Text("+91 8655874243", style: textTheme.fs_16_medium),
                ],
              ),
              AppServices.addHeight(10),
              Row(
                children: [
                  AppServices.addWidth(7),
                  Icon(FontAwesomeIcons.whatsapp, size: 16.r),
                  AppServices.addWidth(10),
                  Text("+91 8422840313", style: textTheme.fs_16_medium),
                ],
              ),
              AppServices.addHeight(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("We will reply you promptly!",
                      style: textTheme.fs_14_regular,
                      textAlign: TextAlign.center),
                ],
              ),
            ],
          )));
}
