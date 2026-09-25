import 'package:dio/dio.dart';

class AddBannerModel {
  // Request
  final MultipartFile? image;

  // Response
  final bool? status;
  final String? message;
  final int? code;
  final int? bannerId;
  final String? bannerImage;

  AddBannerModel({
    this.image,
    this.status,
    this.message,
    this.code,
    this.bannerId,
    this.bannerImage,
  });

  factory AddBannerModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return AddBannerModel(
      status: json['status'],
      message: json['message'],
      code: json['code'],
      bannerId: data?['bannerId'],
      bannerImage: data?['bannerImage'],
    );
  }
}