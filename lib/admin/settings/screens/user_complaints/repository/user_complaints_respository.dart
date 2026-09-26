import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';
import '../model/complaint_ui_model.dart';
import '../model/solve_complaint_model.dart';
import '../model/view_complaint_model.dart';

class UserComplaintsRepository {
  final Dio dio;

  UserComplaintsRepository({
    required this.dio,
  });

  Future<List<UserComplaintModel>?> getUserComplaints({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      log('Fetching user complaints...');
      log('From Date: $fromDate');
      log('To Date: $toDate');

      final response = await dio.get(
        ApiEndpoints.userComplaints,
        queryParameters: {
          'fromDate': fromDate,
          'toDate': toDate,
        },
      );

      log('User Complaints Response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];

        return data
            .map(
              (item) => UserComplaintModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
            .toList();
      }

      log('Get User Complaints failed: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      log('Get User Complaints Dio Error: ${e.message}');
      log('Get User Complaints Response: ${e.response?.data}');
      return null;
    } catch (e) {
      log('Get User Complaints Error: $e');
      return null;
    }
  }

  Future<ViewComplaintModel?> viewComplaint({
    required int complaintId,
  }) async {
    try {
      log('Viewing complaint...');
      log('Complaint ID: $complaintId');

      final response = await dio.post(
        ApiEndpoints.viewComplaint,
        data: {
          'complaintId': complaintId,
        },
      );

      log('View Complaint Response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return ViewComplaintModel.fromJson(response.data);
      }

      log('View Complaint failed: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      log('View Complaint Dio Error: ${e.message}');
      log('View Complaint Response: ${e.response?.data}');
      return null;
    } catch (e) {
      log('View Complaint Error: $e');
      return null;
    }
  }

  Future<SolveComplaintModel?> solveComplaint({
    required int complaintId,
  }) async {
    try {
      log('Solving complaint...');
      log('Complaint ID: $complaintId');

      final response = await dio.post(
        ApiEndpoints.solveComplaint,
        data: {
          'complaintId': complaintId,
        },
      );

      log('Solve Complaint Response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return SolveComplaintModel.fromJson(response.data);
      }

      log('Solve Complaint failed: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      log('Solve Complaint Dio Error: ${e.message}');
      log('Solve Complaint Response: ${e.response?.data}');
      return null;
    } catch (e) {
      log('Solve Complaint Error: $e');
      return null;
    }
  }
}