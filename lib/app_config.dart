// ignore_for_file: constant_identifier_names

class AppConfig {
  static const String app_name = 'FODEX';
  static const String app_logo = 'assets/app_logo.png';
  static const String splash_logo = 'assets/splash_logo.gif';
  static const double width = 360;
  static const double height = 784;
  static const String appVersion = "Fodex_V2.0.15";
}

class InstagramConstant {
  static InstagramConstant? _instance;
  static InstagramConstant get instance {
    _instance ??= InstagramConstant._init();
    return _instance!;
  }

  InstagramConstant._init();

  static const String clientID = '1166851315487443';
  static const String appSecret = '13d279d118c998e4092ff350e632e4ce';
  static const String redirectUri =
      'https://contentmanager.fodxpert.com/redirectToFodxpert/';
  // 'https://contentmanager.fodxpert.com/';
  static const String scope = 'instagram_business_basic';
  static const String responseType = 'code';
  static const url =
      "https://www.instagram.com/oauth/authorize?client_id=$clientID&redirect_uri=$redirectUri&scope=$scope&response_type=$responseType";
}


/* 
"IGAAQlPr4qUtNBZAFBUU0lBZA0w1bmprbm0xVmgxYV9YTUxabFN0RUNGRTNQZAk42Tzc4ZAnNELXd2SnFLLXBfMDQ0ZAHE1NzB2UzFPTHI2U01jZAmRCZAGhrZAko3cEc1V09fNURaeFkteXdHaFhXaEpXS1J2bGRlWXVGTHB4RWFaZAkV4YwZDZD"


13d279d118c998e4092ff350e632e4ce
1166851315487443
https://www.instagram.com/oauth/authorize?force_reauth=true&client_id=1166851315487443&redirect_uri=https://contentmanager.fodxpert.com/redirectToFodxpert/&response_type=code&scope=instagram_business_basic%2Cinstagram_business_manage_messages%2Cinstagram_business_manage_comments%2Cinstagram_business_content_publish%2Cinstagram_business_manage_insights
https://www.instagram.com/oauth/authorize?force_reauth=true&client_id=1166851315487443&redirect_uri=https://contentmanager.fodxpert.com/&response_type=code&scope=instagram_business_basic%2Cinstagram_business_manage_messages%2Cinstagram_business_manage_comments%2Cinstagram_business_content_publish%2Cinstagram_business_manage_insights



https://www.instagram.com/oauth/authorize?force_reauth=true&client_id=1166851315487443&redirect_uri=https://contentmanager.fodxpert.com/&response_type=code&scope=instagram_business_basic%2Cinstagram_business_manage_messages%2Cinstagram_business_manage_comments%2Cinstagram_business_content_publish%2Cinstagram_business_manage_insights
 */