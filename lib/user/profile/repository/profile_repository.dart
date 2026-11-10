
import 'package:maribel_wellness_centre_application/core/utils/app_log.dart';
import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_details_response_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_llp_response_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_mou_response_model.dart';
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
      appLog('Get Investor Details Error: ${e.message}');
      rethrow;
    } catch (e) {
      appLog('Get Investor Details Error: $e');
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
      appLog('Register Complaint Error: ${e.message}');
      rethrow;
    } catch (e) {
      appLog('Register Complaint Error: $e');
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
      appLog('Get My Complaints Error: ${e.message}');
      rethrow;
    } catch (e) {
      appLog('Get My Complaints Error: $e');
      rethrow;
    }
  }

  Future<InvestorMouResponseModel> getInvestorMou(int investorId) async {
    try {
      final response = await dio.get(
        ApiEndpoints.getInvestorsMOU.replaceFirst(
          '{investorId}',
          '$investorId',
        ),
      );

      return InvestorMouResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      appLog('Get Investor MOU Error: ${e.message}');
      rethrow;
    } catch (e) {
      appLog('Get Investor MOU Error: $e');
      rethrow;
    }
  }

  Future<InvestorLlpResponseModel> getInvestorLlp(int investorId) async {
    try {
      final response = await dio.get(
        ApiEndpoints.getInvestorsLLP.replaceFirst(
          '{investorId}',
          '$investorId',
        ),
      );

      return InvestorLlpResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      appLog('Get Investor LLP Error: ${e.message}');
      rethrow;
    } catch (e) {
      appLog('Get Investor LLP Error: $e');
      rethrow;
    }
  }
}
