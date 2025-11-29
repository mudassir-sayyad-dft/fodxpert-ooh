import 'package:fodex_new/view_model/enums/enums.dart';

import '../../controllers/function_controller.dart';

class InstaMediaModel {
  final String id;
  final String caption;
  final InstagramMediaType mediaType;
  final String mediaUrl;
  final List<MediaChildrenModel> children;
  final String permaLink;
  final String username;
  final String timestamp;
  String thumbnail = "";

  InstaMediaModel(
      {this.id = "",
      this.caption = "",
      this.mediaType = InstagramMediaType.IMAGE,
      this.mediaUrl = "",
      this.children = const <MediaChildrenModel>[],
      this.permaLink = "",
      this.username = "",
      this.timestamp = ""});

  InstaMediaModel.fromJson({required Map<String, dynamic> json})
      : id = json['id'] ?? '',
        caption = json['caption'] ?? '',
        mediaType = InstagramMediaType.values.firstWhere(
            (element) =>
                element.name.toLowerCase() ==
                (json['media_type'] ?? '').toLowerCase(),
            orElse: () => InstagramMediaType.IMAGE),
        mediaUrl = json['media_url'] ?? '',
        thumbnail = json['thumbnail_url'] ?? '',
        timestamp = json['timestamp'] ?? DateTime.now().toIso8601String(),
        children = ((json['children'] == null
                ? []
                : (json['children']['data'] ?? [])) as List)
            .map((e) => MediaChildrenModel.fromJson(json: e))
            .toList(),
        permaLink = json['permalink'] ?? '',
        username = json['username'] ?? '';

  InstaMediaModel copyWith({
    String? id,
    String? caption,
    InstagramMediaType? mediaType,
    String? mediaUrl,
    List<MediaChildrenModel>? children,
    String? permaLink,
    String? username,
  }) {
    return InstaMediaModel(
      id: id ?? this.id,
      caption: caption ?? this.caption,
      mediaType: mediaType ?? this.mediaType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      children: children ?? this.children,
      permaLink: permaLink ?? this.permaLink,
      username: username ?? this.username,
    );
  }

  generateThumbnail() async {
    if (mediaType == InstagramMediaType.VIDEO && thumbnail.isEmpty) {
      var data = (await FunctionsController.getVideoThumbnail(mediaUrl));
      if (data != null) {
        thumbnail = data;
      }
    }
  }

  @override
  String toString() {
    return 'InstaMediaModel(id: $id, caption: $caption, mediaType: $mediaType, mediaUrl: $mediaUrl, children: $children, permaLink: $permaLink, username: $username)';
  }
}

class MediaChildrenModel {
  final String id;
  final String mediaUrl;
  final InstagramMediaType mediaType;
  String thumbnail = "";

  MediaChildrenModel(
      {this.id = "",
      this.mediaUrl = "",
      this.mediaType = InstagramMediaType.IMAGE});

  MediaChildrenModel.fromJson({required Map<String, dynamic> json})
      : id = json['id'] ?? '',
        mediaUrl = json['media_url'] ?? '',
        mediaType = InstagramMediaType.values.firstWhere(
            (element) =>
                element.name.toLowerCase() ==
                (json['media_type'] ?? '').toLowerCase(),
            orElse: () => InstagramMediaType.IMAGE);

  generateThumbnail() async {
    if (mediaType == InstagramMediaType.VIDEO) {
      var data = (await FunctionsController.getVideoThumbnail(mediaUrl));
      if (data != null) {
        thumbnail = data;
      }
    }
  }

  MediaChildrenModel copyWith({
    String? id,
    String? mediaUrl,
    InstagramMediaType? mediaType,
  }) {
    return MediaChildrenModel(
      id: id ?? this.id,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
    );
  }

  @override
  String toString() =>
      'MediaChildrenModel(id: $id, mediaUrl: $mediaUrl, mediaType: $mediaType)';
}
