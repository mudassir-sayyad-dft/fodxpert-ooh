import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fodex_new/app_config.dart';
import 'package:fodex_new/res/base_getters.dart';
import 'package:fodex_new/res/routes/route_constants.dart';
import 'package:fodex_new/res/routes/routes.dart';
import 'package:fodex_new/res/theme/get_theme.dart';
import 'package:fodex_new/view_model/bindings/initial_binding.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart'; // For Flutter specific functionality
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

import 'res/text_theme.dart';

LocalhostServer localhostServer = LocalhostServer();

final textTheme = GetTextTheme();

// Initialize Hive instance
late Box prefs;

Future<void> main() async {
  print("main started");
  WidgetsFlutterBinding.ensureInitialized();
  print("binding completed");

  // Initialize Hive
  final directory = Directory('/data/user/0/com.fodx.fodxpertooh/app_flutter');
  Hive.init(directory.path);
  prefs = await Hive.openBox('app_prefs');
  print("Hive initialized");

  await localhostServer.start();
  print("server started");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("app build");
    AppServices.screenSize = MediaQuery.of(context).size;
    print("app build screen size : ${AppServices.screenSize}");
    return ScreenUtilInit(
      builder: (context, child) => GetMaterialApp(
          title: 'Fodxpert OOH',
          debugShowCheckedModeBanner: false,
          theme: GetTheme.lightTheme,
          initialBinding: InitialBindings(),
          onGenerateRoute: (settings) =>
              Routes(context: context).onGenerateRoute(settings),
          initialRoute: RouteConstants.splash),
      splitScreenMode: false,
      designSize: const Size(AppConfig.width, AppConfig.height),
    );
  }
}
