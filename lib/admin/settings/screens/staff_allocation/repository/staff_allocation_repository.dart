import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../model/create_staff_request_model.dart';
import '../model/create_staff_response_model.dart';
import '../model/get_investors_by_staff_response_model.dart';
import '../model/get_staff_response_model.dart';

class StaffRepository {
  final Dio dio;

  StaffRepository({required this.dio});

  Future<CreateStaffResponseModel> createStaff(
      CreateStaffRequestModel request,
      ) async {
    try {
      final response = await dio.post(
        ApiEndpoints.createStaff,
        data: request.toJson(),
      );

      final result = CreateStaffResponseModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );

      return result;
    } on DioException catch (e, stackTrace) {
      log(
        'Create staff API failed: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      log(
        'Error while creating staff: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // get staff

  Future<GetStaffResponseModel> getStaff() async {
    try {
      final response = await dio.get(
        ApiEndpoints.staffList,
      );

      return GetStaffResponseModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e, stackTrace) {
      log(
        'Get staff API failed: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      log(
        'Error while retrieving staff: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<GetInvestorsByStaffResponseModel> getInvestorByStaff(
      int staffId,
      ) async {
    try {
      final response = await dio.get(
        ApiEndpoints.getInvestorByStaff.replaceFirst(
          '{staffId}',
          staffId.toString(),
        ),
      );

      return GetInvestorsByStaffResponseModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e, stackTrace) {
      log(
        'Get investors by staff API failed: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      log(
        'Error retrieving investors by staff: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}