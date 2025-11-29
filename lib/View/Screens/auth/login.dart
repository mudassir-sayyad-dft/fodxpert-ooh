import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/View/Components/Loaders/full_screen_loader.dart';
import 'package:fodex_new/View/Components/buttons/expanded_btn.dart';
import 'package:fodex_new/app_config.dart';
import 'package:fodex_new/main.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/colors.dart';
import 'package:fodex_new/res/utils/utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../view_model/controllers/getXControllers/auth_controller.dart';
import '../../Components/textFields/primary_text_field.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _username = TextEditingController();
  // final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            // resizeToAvoidBottomInset: false,
            body: SingleChildScrollView(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    children: [
                      ClipPath(
                          clipper: Clipper(),
                          child: Container(
                            height: AppServices.getScreenHeight * 0.65.h,
                            color: GetColors.primary,
                          ))
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    width: AppServices.getScreenWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppServices.addHeight(
                            AppServices.getScreenHeight * 0.2.h),
                        Image.asset(AppConfig.app_logo, height: 50.h),
                        Text("App Version : ${AppConfig.appVersion}",
                            style: textTheme.fs_12_regular
                                .copyWith(color: GetColors.white)),
                        AppServices.addHeight(
                            AppServices.getScreenHeight * 0.07.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 30.h),
                          decoration: BoxDecoration(
                              color: GetColors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                    color:
                                        GetColors.black.withValues(alpha: 0.25))
                              ]),
                          child: Column(children: [
                            Text("Login", style: textTheme.fs_24_bold),
                            AppServices.addHeight(32),
                            TextFieldPrimary(
                                controller: _username,
                                prefixIcon: Icons.person,
                                ontapOutside: false,
                                deniedLetters: RegExp('[ ]'),
                                hint: "Enter Email/Phone Number"),
                            // AppServices.addHeight(20),
                            // PasswordTextField(
                            //     controller: _password, hint: "Password"),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            //   children: [
                            //     TextButton(
                            //         onPressed: () {
                            //           AppServices.pushTo(
                            //               RouteConstants.reset_password,
                            //               argument: "true");
                            //         },
                            //         child: const Text("Forget Password?"))
                            //   ],
                            // ),
                            AppServices.addHeight(30),
                            Row(
                              children: [
                                ExpandedButton(
                                    onPressed: () {
                                      Map<String, dynamic> data = {
                                        "userIdentification":
                                            RegExp(r'^[6-9]\d{9}$').hasMatch(
                                                    _username.text.trim())
                                                ? _username.text.trim()
                                                : _username.text.trim(),
                                        // "password": _password.text.trim(),
                                        "resetRequest": "false",
                                        "phone": RegExp(r'^[6-9]\d{9}$')
                                                .hasMatch(_username.text.trim())
                                            ? _username.text.trim()
                                            : ""
                                      };

                                      if (_username.text.isNotEmpty) {
                                        Get.find<AuthController>()
                                            .login(data)
                                            .then((value) {
                                          if (value == true) {
                                            _username.clear();
                                            // _password.clear();
                                          }
                                        });
                                      } else {
                                        Utils.showErrorSnackbar(
                                            message:
                                                "Please Enter username to continue.");
                                      }
                                    },
                                    title: 'Login')
                              ],
                            ),
                            // AppServices.addHeight(10),
                            // Text("Or",
                            //     style: textTheme.fs_12_regular
                            //         .copyWith(color: GetColors.primary)),
                            // AppServices.addHeight(15),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //     InkWell(
                            //         onTap: () {
                            //           print("Continue with google");
                            //         },
                            //         child: SvgPicture.asset(GetIcons.google,
                            //             height: 28.h)),
                            //     AppServices.addWidth(15),
                            //     InkWell(
                            //         onTap: () {
                            //           print("Continue with facebook");
                            //         },
                            //         child: SvgPicture.asset(GetIcons.facebook,
                            //             height: 28.h)),
                            //   ],
                            // )
                            AppServices.addHeight(30),
                            GestureDetector(
                              onTap: () {},
                              child: Text("Don't have an account?",
                                  style: textTheme.fs_14_medium),
                            ),
                            AppServices.addHeight(5),
                            GestureDetector(
                              onTap: () {
                                showContactUsDialog();
                              },
                              child: Text("Contact Us",
                                  style: textTheme.fs_12_medium
                                      .copyWith(color: GetColors.primary)),
                            ),
                          ]),
                        ),
                        // const Expanded(child: SizedBox()),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        GetBuilder<AuthController>(
            builder: (controller) => controller.loading
                ? const FullScreenLoader()
                : const SizedBox())
      ],
    );
  }

  showContactUsDialog() {
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
}

class Clipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // first create the starting point of the path using path.lineTo
    // where x is the horizontal point and y is the vertical point
    path.lineTo(0, size.height - 70.h);

    // To create a curve we'll use the property name quadretic beizer but for this we need some points
    final point1 = Offset(size.width / 2, size.height);
    final point2 = Offset(size.width, size.height - 70.h);

    path.quadraticBezierTo(point1.dx, point1.dy, point2.dx, point2.dy);

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
