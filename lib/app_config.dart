// ignore_for_file: constant_identifier_names

class AppConfig {
  static const String app_name = 'FODEX';
  static const String app_logo = 'assets/app_logo.png';
  static const String splash_logo = 'assets/splash_logo.gif';
  static const double width = 360;
  static const double height = 784;
  static const String appVersion = "Fodex_V2.0.14";
}

class InstagramConstant {
  static InstagramConstant? _instance;
  static InstagramConstant get instance {
    _instance ??= InstagramConstant._init();
    return _instance!;
  }

  InstagramConstant._init();

  static const String clientID = '1438730867480270';
  static const String appSecret = '94389b7a611e61b7a03c36de64538c66';
  static const String redirectUri =
      'https://contentmanager.fodxpert.com/redirectToFodxpert/';
  // 'https://contentmanager.fodxpert.com/';
  static const String scope =
      'instagram_business_basic,instagram_business_content_publish,instagram_business_manage_messages,instagram_business_manage_comments';
  static const String responseType = 'code';
  static const url =
      "https://www.instagram.com/oauth/authorize?client_id=$clientID&redirect_uri=$redirectUri&scope=$scope&response_type=$responseType";
}
