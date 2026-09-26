import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_details_response_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/my_complaints_response_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/register_complaint_response_model.dart';

class ProfileRepository {
  ProfileRepository({
    required this.dio,
  });

  final Dio dio;

  Future<InvestorDetailsResponseModel> getInvestorDetails(String userId) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.investorDetails}$userId',
      );

      return InvestorDetailsResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      log('Get Investor Details Error: ${e.message}');
      rethrow;
    } catch (e) {
      log('Get Investor Details Error: $e');
      rethrow;
    }
  }

  Future<RegisterComplaintResponseModel> registerComplaint(
    String complaint,
  ) async {
    try {
      final request = RegisterComplaintRequestModel(complaint: complaint);
      final response = await dio.post(
        ApiEndpoints.registerComplaint,
        data: request.toJson(),
      );

      return RegisterComplaintResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      log('Register Complaint Error: ${e.message}');
      log('Register Complaint Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      log('Register Complaint Error: $e');
      rethrow;
    }
  }

  Future<MyComplaintsResponseModel> getMyComplaints() async {
    try {
      final response = await dio.get(ApiEndpoints.getMyComplaints);

      return MyComplaintsResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      log('Get My Complaints Error: ${e.message}');
      log('Get My Complaints Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      log('Get My Complaints Error: $e');
      rethrow;
    }
  }
}
