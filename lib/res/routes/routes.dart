import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fodex_new/View/Components/storage_permission_required_view.dart';
import 'package:fodex_new/View/Screens/Bottom_nav_bar/bottom_nav_bar.dart';
import 'package:fodex_new/View/Screens/Bottom_nav_bar/user_profile.dart';
import 'package:fodex_new/View/Screens/Bottom_nav_bar/videos_view.dart';
import 'package:fodex_new/View/Screens/Dashboard/welcome_lounge_view.dart';
import 'package:fodex_new/View/Screens/auth/forgot_password/create_new_password.dart';
import 'package:fodex_new/View/Screens/auth/forgot_password/otp_verification_view.dart';
import 'package:fodex_new/View/Screens/auth/forgot_password/reset_password_view.dart';
import 'package:fodex_new/View/Screens/auth/login.dart';
import 'package:fodex_new/View/Screens/image/image_editor.dart';
import 'package:fodex_new/View/Screens/items/edit_video_template.dart';
import 'package:fodex_new/View/Screens/items/html_preview_screen.dart';
import 'package:fodex_new/View/Screens/items/html_view_screen.dart';
import 'package:fodex_new/View/Screens/items/items_view.dart';
import 'package:fodex_new/View/Screens/items/video_template.dart';
import 'package:fodex_new/View/Screens/onboarding/terms.dart';
import 'package:fodex_new/View/Screens/social_media/social_media_view.dart';
import 'package:fodex_new/res/routes/route_constants.dart';
import 'package:fodex_new/view_model/models/Ads/ads_model.dart';
import 'package:fodex_new/view_model/models/templates/templates_model.dart';

import '../../View/Screens/items/edit_template/edit_template_html_view.dart';
import '../../View/Screens/onboarding/splash.dart';

class Routes {
  BuildContext context;
  Routes({required this.context});

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      /// On - Boarding Routes
      case RouteConstants.splash:
        return MaterialPageRoute(builder: (context) => const Splash());

      /// Auth Routes
      case RouteConstants.login:
        return MaterialPageRoute(builder: (context) => const Login());

      /// Forgot Password routes
      case RouteConstants.reset_password:
        return MaterialPageRoute(
            builder: (context) => const ResetPasswordView());

      case RouteConstants.otp_verification:
        {
          final isForgotPassword =
              (settings.arguments as Map<String, dynamic>)['forgotPassword'];
          // final data = (settings.arguments as Map<String, dynamic>)['data'];
          return MaterialPageRoute(
              builder: (context) => OtpVerificationView(
                    forgotPassword: isForgotPassword,
                    // withEmail: isForgotPassword ? data['with_email'] : null,
                    // data: data
                  ));
        }

      case RouteConstants.create_new_password:
        return MaterialPageRoute(
            builder: (context) => const CreateNewPassword());

      /// Dashboard Routes
      case RouteConstants.welcome_lounge_view:
        return MaterialPageRoute(
            builder: (context) => const WelcomeLoungeView());

      /// Bottom Nav Bar Routes
      case RouteConstants.bottom_nav_bar:
        return MaterialPageRoute(builder: (context) {
          final bool shouldDelay = settings.arguments == true;
          return BottomNavBar(shouldDelay: shouldDelay);
        });

      case RouteConstants.videos_view:
        return MaterialPageRoute(builder: (context) => const VideosView());

      case RouteConstants.storage_permission:
        return MaterialPageRoute(builder: (context) {
          return StoragePermissionRequiredView(
              route: settings.arguments.toString());
        });

      case RouteConstants.user_profile_view:
        return MaterialPageRoute(builder: (context) => const UserProfileView());

      case RouteConstants.items_view:
        return MaterialPageRoute(builder: (context) => const ItemsView());

      case RouteConstants.terms_view:
        return MaterialPageRoute(builder: (context) => const TermsAndConditions());

      case RouteConstants.social_media_view:
        return MaterialPageRoute(builder: (context) => const InstaGramView());

      case RouteConstants.image_editor_view:
        List imageUrl = jsonDecode(settings.arguments.toString());
        return MaterialPageRoute(
            builder: (context) => ImageEditorView(
                  imagePath: imageUrl.first,
                  imageType: imageUrl.last,
                ));

      case RouteConstants.html_preview:
        TemplatesModel path = settings.arguments as TemplatesModel;
        return MaterialPageRoute(
            builder: (context) => HtmlPreviewScreen(template: path));
      case RouteConstants.html_view:
        TemplatesModel template = (settings.arguments
            as Map<String, dynamic>)['template'] as TemplatesModel;
        String path =
            (settings.arguments as Map<String, dynamic>)['path'] as String;
        return MaterialPageRoute(
            builder: (context) => HtmlViewScreen(template: template));
      case RouteConstants.edit_template_html_view:
        AdsModel template = (settings.arguments
            as Map<String, dynamic>)['template'] as AdsModel;
        String path =
            (settings.arguments as Map<String, dynamic>)['path'] as String;
        return MaterialPageRoute(
            builder: (context) =>
                EditTemplateHtmlViewScreen(template: template));

      case RouteConstants.edit_template_video_view:
        AdsModel template = (settings.arguments
            as Map<String, dynamic>)['template'] as AdsModel;
        String path =
            (settings.arguments as Map<String, dynamic>)['path'] as String;
        return MaterialPageRoute(
            builder: (context) =>
                EditVideoTemplateScreen(template: template, path: path));

      case RouteConstants.video_view:
        TemplatesModel template = (settings.arguments
            as Map<String, dynamic>)['template'] as TemplatesModel;
        String path =
            (settings.arguments as Map<String, dynamic>)['path'] as String;
        return MaterialPageRoute(
            builder: (context) =>
                VideoTemplateScreen(template: template, path: path));

      default:
        return MaterialPageRoute(
            builder: (context) => const Scaffold(
                  body: Center(child: Text("No route found")),
                ));
    }
  }
}
