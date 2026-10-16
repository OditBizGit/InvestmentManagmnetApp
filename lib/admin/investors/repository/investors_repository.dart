import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../model/investor_response_model.dart';
import '../model/investor_type_model.dart';
import '../model/staff_model.dart';
import '../model/register_investor_model.dart';
import '../model/update_investor_model.dart';

class InvestorsRepository {
  final Dio dio;

  InvestorsRepository({
    required this.dio,
  });

  Future<InvestorResponseModel> getInvestors() async {
    try {
      final response = await dio.get(
        ApiEndpoints.investorsList,
      );

      return InvestorResponseModel.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      log(
        'Get Investors Error: ${e.message}',
      );

      rethrow;
    } catch (e) {
      log(
        'Get Investors Error: $e',
      );

      rethrow;
    }
  }

  Future<StaffListResponseModel> getStaffList() async {
    try {
      final response = await dio.get(
        ApiEndpoints.staffList,
      );

      return StaffListResponseModel.fromJson(
        response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      log(
        'Get Staff List Error: ${e.message}',
      );

      rethrow;
    } catch (e) {
      log(
        'Get Staff List Error: $e',
      );

      rethrow;
    }
  }

  Future<InvestorTypeResponseModel> getInvestorTypes() async {
    try {
      final response = await dio.get(
        ApiEndpoints.investorTypes,
      );

      return InvestorTypeResponseModel.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      log(
        'Get Investor Types Error: ${e.message}',
      );

      rethrow;
    } catch (e) {
      log(
        'Get Investor Types Error: $e',
      );

      rethrow;
    }
  }


  ///  register investor

  Future<RegisterInvestorResponseModel> registerInvestor(
      RegisterInvestorRequestModel request,
      ) async {
    try {
      final formData = await request.toFormData();

      final response = await dio.post(
        ApiEndpoints.registerInvestor,
        data: formData,
      );

      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : Map<String, dynamic>.from(response.data as Map);

      log('Register Investor completed with status code ${response.statusCode}');

      return RegisterInvestorResponseModel.fromJson(payload);
    } on DioException catch (e) {
      log(
        'Register Investor Error: ${e.message} (status ${e.response?.statusCode})',
      );

      rethrow;
    } catch (e) {
      log(
        'Register Investor Error: $e',
      );

      rethrow;
    }
  }

  ///update user details

  Future<UpdateInvestorResponseModel> updateInvestor(
      UpdateInvestorRequestModel request,
      ) async {
    try {
      final formData = await request.toFormData();

      final response = await dio.post(
        ApiEndpoints.updateInvestor,
        data: formData,
      );

      return UpdateInvestorResponseModel.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      log(
        'Update Investor Error: ${e.message}',
      );

      log(
        'Update Investor Response: ${e.response?.data}',
      );

      rethrow;
    } catch (e) {
      log(
        'Update Investor Error: $e',
      );

      rethrow;
    }
  }

}