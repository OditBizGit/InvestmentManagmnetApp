import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../../core/constants/api_endpoints.dart';
import '../model/staff_report_details_model.dart';
import '../model/staff_report_model.dart';

class StaffReportRepository {
  final Dio dio;

  StaffReportRepository(this.dio);

  Future<StaffReportResponseModel> getStaffReport({
    String period = 'ThisMonth',
    String? fromDate,
    String? toDate,
    String? search,
  }) async {
    try {
      log(
        'Fetching staff report: period=$period, fromDate=$fromDate, '
            'toDate=$toDate, search=$search',
        name: 'GetStaffReportAPI',
      );

      final response = await dio.get(
        ApiEndpoints.getStaffReport,
        queryParameters: {
          'Period': period,
          if (fromDate != null && fromDate.isNotEmpty)
            'FromDate': fromDate,
          if (toDate != null && toDate.isNotEmpty)
            'ToDate': toDate,
          if (search != null && search.isNotEmpty)
            'Search': search,
        },
      );

      log(
        'Staff report response: ${response.data}',
        name: 'GetStaffReportAPI',
      );

      return StaffReportResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e, stackTrace) {
      log(
        'Dio error fetching staff report: '
            '${e.response?.data ?? e.message}',
        name: 'GetStaffReportAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      log(
        'Unexpected error fetching staff report: $e',
        name: 'GetStaffReportAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }


  Future<StaffReportDetailsResponseModel> getStaffReportDetails({
    required int staffId,
    String period = 'ThisMonth',
    String? fromDate,
    String? toDate,
    String? search,
  }) async {
    try {
      log(
        'Fetching staff report details: staffId=$staffId, '
            'period=$period, fromDate=$fromDate, '
            'toDate=$toDate, search=$search',
        name: 'GetStaffReportDetailsAPI',
      );

      final response = await dio.get(
        ApiEndpoints.getStaffReportByID.replaceFirst(
          '{staffId}',
          staffId.toString(),
        ),
        queryParameters: {
          'Period': period,
          if (fromDate != null && fromDate.isNotEmpty)
            'FromDate': fromDate,
          if (toDate != null && toDate.isNotEmpty)
            'ToDate': toDate,
          if (search != null && search.isNotEmpty)
            'Search': search,
        },
      );

      log(
        'Staff report details response: ${response.data}',
        name: 'GetStaffReportDetailsAPI',
      );

      return StaffReportDetailsResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e, stackTrace) {
      log(
        'Dio error fetching staff report details: '
            '${e.response?.data ?? e.message}',
        name: 'GetStaffReportDetailsAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      log(
        'Unexpected error fetching staff report details: $e',
        name: 'GetStaffReportDetailsAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

}