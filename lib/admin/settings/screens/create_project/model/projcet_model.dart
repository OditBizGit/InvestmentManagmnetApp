import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';

class ProjectRequestModel {
  final int projectId;
  final String name;
  final String description;
  final double totalFund;
  final MultipartFile? image;

  ProjectRequestModel({
    this.projectId = 0,
    required this.name,
    required this.description,
    required this.totalFund,
    this.image,
  });

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'ProjectId': projectId,
      'Name': name,
      'Description': description,
      'TotalFund': totalFund,
      if (image != null) 'Image': image,
    });
  }
}


/// Create / Update response
class ProjectResponseModel {
  final bool status;
  final String message;
  final ProjectModel? data;
  final int code;

  ProjectResponseModel({
    required this.status,
    required this.message,
    this.data,
    required this.code,
  });

  factory ProjectResponseModel.fromJson(Map<String, dynamic> json) {
    return ProjectResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ProjectModel.fromJson(json['data'])
          : null,
      code: json['code'] ?? 0,
    );
  }
}


/// Get Projects response
class ProjectListResponseModel {
  final bool status;
  final String message;
  final List<ProjectModel> data;
  final int code;

  ProjectListResponseModel({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
  });

  factory ProjectListResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ProjectListResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<ProjectModel>.from(
        (json['data'] as List).map(
              (item) => ProjectModel.fromJson(item),
        ),
      )
          : [],
      code: json['code'] ?? 0,
    );
  }
}


/// Project data
class ProjectModel {
  final int projectId;
  final String name;
  final String description;
  final double totalFund;
  final int status;
  final String? image;
  final int? createdBy;
  final DateTime? createdDate;
  final int? modifiedBy;
  final DateTime? modifiedDate;

  ProjectModel({
    required this.projectId,
    required this.name,
    required this.description,
    required this.totalFund,
    required this.status,
    this.image,
    this.createdBy,
    this.createdDate,
    this.modifiedBy,
    this.modifiedDate,
  });

  String? get imageUrl => resolveMediaUrl(image);

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      projectId: json['ProjectId'] ?? json['projectId'] ?? 0,

      name: json['Name'] ?? json['name'] ?? '',

      description:
      json['Description'] ?? json['description'] ?? '',

      totalFund: (
          json['TotalFund'] ??
              json['totalFund'] ??
              0
      ).toDouble(),

      status: json['Status'] ?? json['status'] ?? 0,

      image: json['Image'] ?? json['image'],

      createdBy:
      json['Createdby'] ?? json['createdby'],

      createdDate:
      json['CreatedDate'] != null
          ? DateTime.tryParse(json['CreatedDate'])
          : json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'])
          : null,

      modifiedBy:
      json['Modifiedby'] ?? json['modifiedby'],

      modifiedDate:
      json['ModifiedDate'] != null
          ? DateTime.tryParse(json['ModifiedDate'])
          : json['modifiedDate'] != null
          ? DateTime.tryParse(json['modifiedDate'])
          : null,
    );
  }
}