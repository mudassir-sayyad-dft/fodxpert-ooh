import 'package:fodex_new/view_model/controllers/getXControllers/auth_controller.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/templates_controller.dart';
import 'package:fodex_new/view_model/controllers/getXControllers/user_controller.dart';
import 'package:fodex_new/view_model/controllers/upload_service.dart';
import 'package:get/get.dart';

import '../controllers/getXControllers/data_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(DataController());
    Get.put<AuthController>(AuthController());
    Get.put<UserController>(UserController());
    Get.put(TemplatesController());
    Get.put<UploadService>(UploadService());
  }
}
