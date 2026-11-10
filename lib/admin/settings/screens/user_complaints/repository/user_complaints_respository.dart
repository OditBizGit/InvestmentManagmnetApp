import 'package:maribel_wellness_centre_application/core/utils/app_log.dart';
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
      appLog('Fetching user complaints...');
      appLog('From Date: $fromDate');
      appLog('To Date: $toDate');

      final response = await dio.get(
        ApiEndpoints.userComplaints,
        queryParameters: {
          'fromDate': fromDate,
          'toDate': toDate,
        },
      );


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

      appLog('Get User Complaints failed: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      appLog('Get User Complaints Dio Error: ${e.message}');
      return null;
    } catch (e) {
      appLog('Get User Complaints Error: $e');
      return null;
    }
  }

  Future<ViewComplaintModel?> viewComplaint({
    required int complaintId,
  }) async {
    try {
      appLog('Viewing complaint...');
      appLog('Complaint ID: $complaintId');

      final response = await dio.post(
        ApiEndpoints.viewComplaint,
        data: {
          'complaintId': complaintId,
        },
      );


      if (response.statusCode == 200 && response.data != null) {
        return ViewComplaintModel.fromJson(response.data);
      }

      appLog('View Complaint failed: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      appLog('View Complaint Dio Error: ${e.message}');
      return null;
    } catch (e) {
      appLog('View Complaint Error: $e');
      return null;
    }
  }

  Future<SolveComplaintModel?> solveComplaint({
    required int complaintId,
  }) async {
    try {
      appLog('Solving complaint...');
      appLog('Complaint ID: $complaintId');

      final response = await dio.post(
        ApiEndpoints.solveComplaint,
        data: {
          'complaintId': complaintId,
        },
      );


      if (response.statusCode == 200 && response.data != null) {
        return SolveComplaintModel.fromJson(response.data);
      }

      appLog('Solve Complaint failed: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      appLog('Solve Complaint Dio Error: ${e.message}');
      return null;
    } catch (e) {
      appLog('Solve Complaint Error: $e');
      return null;
    }
  }
}