class DeleteBannerModel {
  final bool? status;
  final String? message;
  final int bannerId;

  DeleteBannerModel({
    required this.bannerId,
    this.status,
    this.message,
  });

  factory DeleteBannerModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataMap = data is Map ? Map<String, dynamic>.from(data) : null;

    return DeleteBannerModel(
      status: json['status'] as bool?,
      message: (json['message'] ?? dataMap?['message'])?.toString(),
      bannerId: _readInt(
        dataMap?['bannerId'] ??
            dataMap?['BannerId'] ??
            json['bannerId'] ??
            json['BannerId'],
      ),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
