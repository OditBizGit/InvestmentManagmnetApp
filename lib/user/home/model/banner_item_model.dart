import 'package:maribel_wellness_centre_application/core/utils/media_url.dart';

class BannerItemModel {
  const BannerItemModel({
    required this.bannerId,
    this.bannerImage,
  });

  final int bannerId;
  final String? bannerImage;

  String? get bannerImageUrl => resolveMediaUrl(bannerImage);

  factory BannerItemModel.fromJson(Map<String, dynamic> json) {
    return BannerItemModel(
      bannerId: _readInt(json['bannerId'] ?? json['BannerId']),
      bannerImage: _readString(json['bannerImage'] ?? json['BannerImage']),
    );
  }

  static String? _readString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
