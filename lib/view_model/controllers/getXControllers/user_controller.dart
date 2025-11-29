import 'dart:convert';

import 'package:fodex_new/main.dart';
import 'package:get/get.dart';

import '../../models/user/user_model.dart';

class UserController extends GetxController {
  UserModel _currentUser = UserModel();
  UserModel get currentUser => _currentUser;

  UserModel _getUserModel(Map<String, dynamic> data) {
    if (_currentUser.toJson().values.every((element) => element.isEmpty)) {
      return UserModel.fromMap(json: data);
    }
    return _currentUser.copyWithMap(json: data);
  }

  _setCurrentUser(Map<String, dynamic> data) {
    _currentUser = _getUserModel(data);
    update();
  }

  setUser(UserModel user) {
    _currentUser = user;
    update();
  }

  updateUserDetails(String firstName, String lastName) {
    _currentUser.firstName = firstName;
    _currentUser.lastName = lastName;
    prefs.put('user', jsonEncode(_currentUser.toJson()));
    update();
  }

  saveUser(Map<String, dynamic> user, {bool saveStorage = true}) {
    _setCurrentUser(user);
    saveStorage ? prefs.put('user', jsonEncode(_currentUser.toJson())) : null;
  }

  UserModel getUser() {
    final user = prefs.get('user') ?? jsonEncode({});
    return _getUserModel(jsonDecode(user));
  }

  removeUser() {
    prefs.delete('user');
  }
}
