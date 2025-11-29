// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fodex_new/view_model/controllers/function_controller.dart';

class ItemModel {
  final String id;
  final String image;
  final String category;
  final String name;
  final String thumbnail;
  final String videoFile;

  ItemModel(
      {required this.image,
      required this.category,
      required this.name,
      required this.thumbnail,
      required this.videoFile})
      : id = FunctionsController.generateId();
}

class CategoryModel {
  final String id;
  final String title;

  const CategoryModel({required this.id, required this.title});

  @override
  bool operator ==(covariant CategoryModel other) {
    if (identical(this, other)) return true;

    return other.id == id && other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}
