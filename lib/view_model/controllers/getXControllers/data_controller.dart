import 'package:fodex_new/view_model/models/item_model.dart';
import 'package:get/get.dart';

class DataController extends GetxController {
  final List<ItemModel> _videoList = [];
  List<ItemModel> get videoList => _videoList;

  setVideoList(List<ItemModel> list) {
    _videoList.addAll(list);
    update();
  }

  updateVideoList(ItemModel item) {
    _videoList.add(item);
    update();
  }

  clearVideoList() {
    _videoList.clear();
    update();
  }

  updateItemThumbnail(ItemModel item) {
    update();
  }
}
