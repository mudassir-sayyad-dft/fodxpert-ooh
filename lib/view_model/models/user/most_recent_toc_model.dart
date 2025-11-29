// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class MostRecentTocModel {
  String id;
  String versionNumber;
  String v;
  String dateUploaded;
  String fileName;
  String owner;
  String docPath;

  MostRecentTocModel(
      {required this.id,
      required this.versionNumber,
      required this.v,
      required this.dateUploaded,
      required this.fileName,
      required this.owner,
      this.docPath = ""});

  MostRecentTocModel copyWith(
      {String? id,
      String? versionNumber,
      String? v,
      String? dateUploaded,
      String? fileName,
      String? owner,
      String? docPath}) {
    return MostRecentTocModel(
        id: id ?? this.id,
        versionNumber: versionNumber ?? this.versionNumber,
        v: v ?? this.v,
        dateUploaded: dateUploaded ?? this.dateUploaded,
        fileName: fileName ?? this.fileName,
        owner: owner ?? this.owner,
        docPath: docPath ?? this.docPath);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'versionNumber': versionNumber,
      '__v': v,
      'dateUploaded': dateUploaded,
      'fileName': fileName,
      'owner': owner,
    };
  }

  factory MostRecentTocModel.fromMap(Map<String, dynamic> map) {
    return MostRecentTocModel(
      id: (map["_id"] ?? '').toString(),
      versionNumber: (map["versionNumber"] ?? '').toString(),
      v: (map["__v"] ?? 0).toString(),
      dateUploaded: (map["dateUploaded"] ?? '').toString(),
      fileName: "${(map["fileName"] ?? '')}",
      owner: (map["owner"] ?? '').toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory MostRecentTocModel.fromJson(String source) =>
      MostRecentTocModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MostRecentTocModel(_id: $id, versionNumber: $versionNumber, __v: $v, dateUploaded: $dateUploaded, fileName: $fileName, owner: $owner)';
  }

  @override
  bool operator ==(covariant MostRecentTocModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.versionNumber == versionNumber &&
        other.v == v &&
        other.dateUploaded == dateUploaded &&
        other.fileName == fileName &&
        other.owner == owner;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        versionNumber.hashCode ^
        v.hashCode ^
        dateUploaded.hashCode ^
        fileName.hashCode ^
        owner.hashCode;
  }
}
