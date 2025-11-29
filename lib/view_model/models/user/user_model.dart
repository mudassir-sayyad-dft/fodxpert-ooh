class UserModel {
  String uid;
  String userName;
  String firstName;
  String lastName;
  late String email;
  late String phone;
  String managerID;
  String tocVersion;

  UserModel(
      {this.uid = "",
      this.userName = "",
      this.firstName = "",
      this.lastName = "",
      String userIdentification = "",
      this.managerID = "",
      this.tocVersion = ""}) {
    email = getEmail(userIdentification);
    phone = getPhoneNumber(userIdentification);
  }

  factory UserModel.fromMap({required Map<String, dynamic> json}) {
    return UserModel(
        uid: json['userID'] ?? '',
        managerID: json['managerID'] ?? '',
        userIdentification: json['userIdentification'] ?? '',
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        userName: json['userName'] ?? '',
        tocVersion: json['tocVersion'] ?? '');
  }

  Map<String, dynamic> toJson() => {
        'userID': uid,
        'userIdentification': email,
        'managerID': managerID,
        'phone': phone,
        'userName': userName,
        'firstName': firstName,
        'lastName': lastName,
        'tocVersion': tocVersion
      };

  UserModel copyWithMap({required Map<String, dynamic> json}) {
    return UserModel(
        uid: json['userID'] ?? uid,
        userName: json['userName'] ?? userName,
        managerID: json['managerID'] ?? managerID,
        firstName: json['firstName'] ?? firstName,
        lastName: json['lastName'] ?? lastName,
        tocVersion: json['tocVersion'] ?? tocVersion,
        userIdentification: json['userIdentification'] ??
            [email, phone].where((element) => element.isNotEmpty).join());
  }

  bool isLoginWithPhoneNumber(String userIdentification) {
    // if (userIdentification.startsWith("+91")) {

    if (RegExp(r'^[6-9]\d{9}$').hasMatch(userIdentification)) {
      return true;
    }
    // }

    return false;
  }

  String getPhoneNumber(String userIdentification) {
    return isLoginWithPhoneNumber(userIdentification) ? userIdentification : "";
  }

  String getEmail(String userIdentification) {
    return isLoginWithPhoneNumber(userIdentification) ? "" : userIdentification;
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, userName: $userName, email: $email, phone: $phone, managerID: $managerID, firstName: $firstName, lastName: $lastName, tocVersion: $tocVersion)';
  }
}
