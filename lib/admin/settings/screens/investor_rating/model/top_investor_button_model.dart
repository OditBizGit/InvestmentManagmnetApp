class TopInvestorButtonRequestModel {
  final bool isEnabled;

  TopInvestorButtonRequestModel({
    required this.isEnabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
    };
  }
}

class TopInvestorButtonResponseModel {
  final bool status;
  final String message;
  final TopInvestorButtonData? data;
  final int code;

  TopInvestorButtonResponseModel({
    required this.status,
    required this.message,
    this.data,
    required this.code,
  });

  factory TopInvestorButtonResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return TopInvestorButtonResponseModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] is Map
          ? TopInvestorButtonData.fromJson(
        Map<String, dynamic>.from(json['data'] as Map),
      )
          : null,
      code: (json['code'] as num?)?.toInt() ?? 0,
    );
  }
}

class TopInvestorButtonData {
  /// The "Top Investors Investor Visibility" row in `GetAllSettings`.
  static const int visibilitySettingId = 9;
  static const String visibilitySettingName =
      'Top Investors Investor Visibility';

  final int id;
  final String name;
  final bool status;

  TopInvestorButtonData({
    required this.id,
    required this.name,
    required this.status,
  });

  factory TopInvestorButtonData.fromJson(
      Map<String, dynamic> json,
      ) {
    return TopInvestorButtonData(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      status: json['status'] as bool? ?? false,
    );
  }
}

/// Response of `GET /api/Settings/GetAllSettings` (a list of settings).
class AllSettingsResponseModel {
  final bool status;
  final String message;
  final List<TopInvestorButtonData> data;
  final int code;

  AllSettingsResponseModel({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
  });

  factory AllSettingsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return AllSettingsResponseModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: rawData is List
          ? rawData
              .whereType<Map>()
              .map(
                (item) => TopInvestorButtonData.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
      code: (json['code'] as num?)?.toInt() ?? 0,
    );
  }

  /// The visibility setting (id 9, exact name), or `null` if the backend did
  /// not return it. Prefers a row matching both id and name, then id, then
  /// name; other settings in the list are ignored.
  TopInvestorButtonData? get topInvestorVisibility {
    for (final setting in data) {
      if (setting.id == TopInvestorButtonData.visibilitySettingId &&
          setting.name == TopInvestorButtonData.visibilitySettingName) {
        return setting;
      }
    }
    for (final setting in data) {
      if (setting.id == TopInvestorButtonData.visibilitySettingId) {
        return setting;
      }
    }
    for (final setting in data) {
      if (setting.name == TopInvestorButtonData.visibilitySettingName) {
        return setting;
      }
    }
    return null;
  }
}
