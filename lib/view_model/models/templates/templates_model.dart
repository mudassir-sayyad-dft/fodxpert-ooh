// ignore_for_file: public_member_api_docs, sort_constructors_first
// class TemplatesModel {
//   final String templateName;
//   final String path;
//   String thumbnail = "";

//   TemplatesModel({this.templateName = "", this.path = ""});

//   TemplatesModel.fromJson({required Map<String, dynamic> json})
//       : templateName = json['templateName'] ?? '',
//         path = json['path'] ?? '';

//   TemplatesModel copyWith({
//     String? templateName,
//     String? path,
//   }) {
//     return TemplatesModel(
//       templateName: templateName ?? this.templateName,
//       path: path ?? this.path,
//     );
//   }

//   generateThumbnail() async {
//     if (FunctionsController.checkFileIsVideo(path)) {
//       var data = (await FunctionsController.getVideoThumbnail(path));
//       if (data != null) {
//         thumbnail = data;
//       }
//     }
//   }

//   @override
//   String toString() =>
//       'TemplatesModel(templateName: $templateName, path: $path)';
// }

import 'dart:convert';

class TemplatesModel {
  final String id;
  final String description;
  final String file;
  final String previewUrl;
  final String fileUrl;
  final String category;
  final String name;
  final String templateType;

  const TemplatesModel(
      {required this.id,
      required this.description,
      required this.file,
      required this.previewUrl,
      required this.fileUrl,
      required this.name,
      required this.category,
      required this.templateType});

  @override
  String toString() {
    return 'TemplatesModel(id: $id, description: $description, file: $file, previewUrl: $previewUrl, fileUrl: $fileUrl, category: $category, name: $name, templateType: $templateType)';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'description': description,
      'filePath': file,
      'previewUrl': previewUrl,
      'fileUrl': fileUrl,
      'templateName': name,
      'category': category,
      'templateType': templateType
    };
  }

  factory TemplatesModel.fromMap(Map<String, dynamic> map) {
    // Handle both old and new API response formats
    final previewUrl = map['previewUrl'] ?? map['thumbnail'] ?? '';
    final fileUrl = map['fileUrl'] ?? map['filePath'] ?? '';

    return TemplatesModel(
      id: (map["id"] ?? '') as String,
      description: (map['description'] ?? '') as String,
      file: (map['filePath'] ?? '') as String,
      previewUrl: previewUrl as String,
      fileUrl: fileUrl as String,
      name: (map['templateName'] ?? '') as String,
      templateType: (map['templateType'] ?? 'Image') as String,
      category: (map['category'] ?? '').toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory TemplatesModel.fromJson(String source) =>
      TemplatesModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class TemplateDataModel {
  final String key;
  final String height;
  final String width;
  String value;
  final TemplateDataType type;
  final String aspectRatio;
  TemplateDataModel(
      {required this.key,
      required this.value,
      required this.type,
      this.aspectRatio = "3:4",
      this.height = "1080",
      this.width = "1920"});

  @override
  String toString() =>
      'TemplateDataModel(key: $key, value: $value, type: $type, height: $height, width: $width)';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'key': key,
      'value': value,
      'height': height,
      'width': width,
      'type': type.name,
      'aspectratio': aspectRatio,
    };
  }

  factory TemplateDataModel.fromMap(Map<String, dynamic> map) {
    return TemplateDataModel(
      key: (map["key"] ?? '') as String,
      value: (map["value"] ?? '') as String,
      aspectRatio: (map["aspectratio"] ?? '3:4') as String,
      height: (map["height"] ?? '1080') as String,
      width: (map["width"] ?? '1920') as String,
      type: TemplateDataType.values.firstWhere(
          (element) =>
              element.name ==
              (map["type"] ?? TemplateDataType.TEXT.name)
                  .toString()
                  .toUpperCase(),
          orElse: () => TemplateDataType.TEXT),
    );
  }

  String toJson() => json.encode(toMap());

  factory TemplateDataModel.fromJson(String source) =>
      TemplateDataModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant TemplateDataModel other) {
    if (identical(this, other)) return true;

    return other.key == key &&
        other.height == height &&
        other.width == width &&
        other.value == value &&
        other.type == type &&
        other.aspectRatio == aspectRatio;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        height.hashCode ^
        width.hashCode ^
        value.hashCode ^
        type.hashCode ^
        aspectRatio.hashCode;
  }
}

enum TemplateDataType { IMAGE, TEXT, FONT, VIDEO }
