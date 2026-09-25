import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';

class BannerModel {
  final int bannerId;
  final String bannerImage;

  BannerModel({
    required this.bannerId,
    required this.bannerImage,
  });

  String? get bannerImageUrl => resolveMediaUrl(bannerImage);

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      bannerId: _readInt(json['bannerId'] ?? json['BannerId']),
      bannerImage: _readString(json['bannerImage'] ?? json['BannerImage']),
    );
  }

  static String _readString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
