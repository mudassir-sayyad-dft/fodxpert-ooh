import 'package:fodex_new/data/response/response.dart';
import 'package:get/get.dart';

import '../../../repository/templates_repository.dart';
import '../../models/templates/templates_model.dart';

class TemplatesController extends GetxController {
  final _repo = TemplatesRepository();

  ApiResponse<List<String>> _categories = ApiResponse.loading();
  ApiResponse<List<String>> get categories => _categories;

  setCategories(ApiResponse<List<String>> data) {
    _categories = data;
    update();
  }

  ApiResponse<List<TemplatesModel>> _templates = ApiResponse.loading();
  ApiResponse<List<TemplatesModel>> get templates => _templates;

  final RxString _selectedCategory = "".obs;
  String get selectedCategory => _selectedCategory.value;

  setTemplates(ApiResponse<List<TemplatesModel>> data) {
    _templates = data;
    update();
  }

  final RxList<TemplateDataModel> _previewData = RxList<TemplateDataModel>([]);
  List<TemplateDataModel> get previewData => _previewData;

  setPreviewData(List<TemplateDataModel> data) {
    _previewData(data);
  }

  getCategories() async {
    try {
      final response = await _repo.getCategories();
      getTemplates(response.first);
      setCategories(ApiResponse.complete(data: response));
    } catch (e) {
      setCategories(ApiResponse.error(message: e.toString()));
    }
  }

  Future<void> getTemplates(String category) async {
    try {
      setTemplates(ApiResponse.loading());
      _selectedCategory(category);
      final response = await _repo.getTemplates(category);
      // for (var data in response) {
      //   data.generateThumbnail();
      // }
      setTemplates(ApiResponse.complete(data: response));
    } catch (e) {
      setTemplates(ApiResponse.error(message: e.toString()));
    }
  }

  List<String> get fonts => [
        "Roboto",
        // "Edu Australia VIC WA NT Hand",r
        "Open Sans",
        "Montserrat",
        "Poppins",
        "Lato",
        "Gupter",
        "Tangerine",
        "Kanit",
        "Lora",
        "Dancing Script",
        "Bitter",
        // "Bona Nova SC",
        "Pacifico",
        "Lobster",
        "Caveat",
        // "Bodoni Moda SC",
        "Cormorant Garamond",
        // "Ga Maamli",
        "Permanent Marker",
        "Modern Antiqua",
        "Source Serif 4",
        "Satisfy",
        "Great Vibes",
        "Montserrat Alternates",
        "Kalam",
        "Oleo Script",
        "Merienda",
        // "Playwrite Colombia",
        "Allura"
      ];
}
