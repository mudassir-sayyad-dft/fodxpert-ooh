import 'package:fodex_new/data/response/response.dart';
import 'package:fodex_new/repository/screens_repository.dart';
import 'package:fodex_new/view_model/models/screens_model/screens_model.dart';
import 'package:get/get.dart';

class ScreensController extends GetxController {
  final _repo = ScreensRepository();

  ApiResponse<List<ScreensModel>> _screens = ApiResponse.loading();

  ApiResponse<List<ScreensModel>> get screens => _screens;

  setScreens(ApiResponse<List<ScreensModel>> data) {
    _screens = data;
    update();
  }

  Future<void> getScreensForUser() async {
    try {
      setScreens(ApiResponse.complete(data: await _repo.getScreensForUser()));
    } catch (e) {
      setScreens(ApiResponse.error(message: e.toString()));
    }
  }
}
