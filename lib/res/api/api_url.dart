class ApiUrl {
  // static const _baseUrl = "https://contentmanager.fodxpert.com/";
  static const _baseUrl = "http://192.168.1.11:3100/";

  static const loginEndPoint = "${_baseUrl}api/loginFromApp";

  static const validateOtpEndPoint = "${_baseUrl}api/validateOTP";
  static const getMostRecentTOCEndPoint = "${_baseUrl}api/getMostRecentTOC";
  static const updateTOCDetailsEndPoint = "${_baseUrl}api/updateTOCDetails";

  static const screenDetailsEndPoint = "${_baseUrl}api/getScreenDetailsForApp";

  static const adsListForScreenEndPoint = "${_baseUrl}api/getAdsListForScreen";

  static const uploadCreativeEndPoint = "${_baseUrl}api/uploadFromApp";

  static const deleteCreativeEndPoint = "${_baseUrl}api/deleteCreativeFromApp";

  static const updateCreativeEndPoint =
      "${_baseUrl}api/checkStatusOfUpdatedFiles";

  static const statusOfUploadFileEndPoint =
      "${_baseUrl}api/checkStatusOfUploadedFiles";

  static const sendEmailForResetPasswordEndPoint =
      "${_baseUrl}api/sendEmailForResetFromApp";

  static const sendMessageForResetPasswordEndPoint =
      "${_baseUrl}api/sendMsgForPasswordReset";

  static const changePasswordEndPoint = "${_baseUrl}api/changePassword";

  static const updateUserDetailsEndPoint = "${_baseUrl}api/modifyUserDetails";

  static const updatePlaylistForScreenEndPoint =
      "${_baseUrl}api/updatePlaylistForScreen";

  static const getTemplatesEndPoint = "${_baseUrl}api/getTemplates";

  static const resendOtpViaSMSEndPoint = "${_baseUrl}api/resendOTPViaSMS";

  static const resendOtpViaMailEndPoint = "${_baseUrl}api/resendOTPViaMail";
  static const templateCategoriesEndPoint =
      "${_baseUrl}api/getTemplateCategories";
}
