class ScreensModel {
  String screenId;
  String screenName;
  String screenType;
  String spotCode;
  String restaurantId;
  String restaurantName;
  String zone;
  String status;

  ScreensModel(
      {this.screenId = "",
      this.screenName = "",
      this.screenType = "",
      this.spotCode = "",
      this.restaurantId = "",
      this.restaurantName = "",
      this.zone = "",
      this.status = ""});

  ScreensModel.fromJson({required Map<String, dynamic> json})
      : screenName = json['screenName'] ?? '',
        screenId = json['screenID'] ?? '',
        screenType = json['screenType'] ?? '',
        spotCode = json['spotCode'] ?? '',
        restaurantId = json['restaurantId'] ?? '',
        restaurantName = json['restaurantName'] ?? '',
        zone = json['zone'] ?? '',
        status = json['status'] ?? '';

  Map<String, dynamic> toJson() => {
        "screenName": screenName,
        "screenType": screenType,
        "spotCode": spotCode,
        "restaurantId": restaurantId,
        "restaurantName": restaurantName,
        "zone": zone,
        "status": status,
        "screenID": screenId
      };

  ScreensModel copyWith({
    String? screenName,
    String? screenType,
    String? spotCode,
    String? restaurantId,
    String? restaurantName,
    String? zone,
    String? status,
    String? screenID,
  }) {
    return ScreensModel(
        screenName: screenName ?? this.screenName,
        screenType: screenType ?? this.screenType,
        spotCode: spotCode ?? this.spotCode,
        restaurantId: restaurantId ?? this.restaurantId,
        restaurantName: restaurantName ?? this.restaurantName,
        zone: zone ?? this.zone,
        status: status ?? this.status,
        screenId: screenID ?? screenId);
  }

  @override
  bool operator ==(covariant ScreensModel other) {
    if (identical(this, other)) return true;

    return other.screenName == screenName &&
        other.screenType == screenType &&
        other.spotCode == spotCode &&
        other.restaurantId == restaurantId &&
        other.restaurantName == restaurantName &&
        other.zone == zone &&
        other.status == status &&
        other.screenId == screenId;
  }

  @override
  int get hashCode {
    return screenName.hashCode ^
        screenType.hashCode ^
        spotCode.hashCode ^
        restaurantId.hashCode ^
        restaurantName.hashCode ^
        zone.hashCode ^
        status.hashCode ^
        screenId.hashCode;
  }

  @override
  String toString() {
    return 'ScreensModel(screenID: $screenId, screenName: $screenName, screenType: $screenType, spotCode: $spotCode, restaurantId: $restaurantId, restaurantName: $restaurantName, zone: $zone, status: $status)';
  }
}
