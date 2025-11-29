import 'dart:io';

import 'package:downloadsfolder/downloadsfolder.dart' as dw;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/View/Services/splash_services.dart';
import 'package:fodex_new/app_config.dart';
import 'package:fodex_new/res/colors.dart';
import 'package:path_provider/path_provider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  // @override
  // void initState() {
  //   super.initState();
  //   initialize();
  // }

  initialize() {
    Future.delayed(const Duration(milliseconds: 2500), () async {
      SplashServices()
          .checkAuthentication(context); // Check authentication after a delay

      try {
        var path = await getTemporaryDirectory();
        var pathToDelete = Directory("${path.path}/fodx");
        if (await pathToDelete.exists()) {
          await pathToDelete.delete(recursive: true);
          print("Directory deleted: ${pathToDelete.path}");
        }
      } catch (e) {
        print(
            "Error deleting directory: $e"); // Catch any errors that may occur
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GetColors.primary,
      body: Center(
        child: Image.asset(
          AppConfig.splash_logo,
        ),
      ),
    );
  }
}
