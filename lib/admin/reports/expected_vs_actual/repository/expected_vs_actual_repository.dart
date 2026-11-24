import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_log.dart';

import '../model/expected_vs_actual_model.dart';

class ExpectedVsActualRepository {
  ExpectedVsActualRepository(this.dio);

  final Dio dio;

  /// [fromMonth] / [toMonth] are sent as `yyyy-MM-01` (whole months).
  Future<ExpectedVsActualResponseModel> getReport({
    required DateTime fromMonth,
    required DateTime toMonth,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.reportExpectedVsActual,
        queryParameters: {
          'fromDate': formatMonthParam(fromMonth),
          'toDate': formatMonthParam(toMonth),
        },
      );
      return ExpectedVsActualResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (e, stackTrace) {
      appLog(
        'Error fetching expected vs actual: $e',
        name: 'ExpectedVsActualAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<ExpectedVsActualDetailsResponseModel> getDetails({
    required DateTime month,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.reportExpectedVsActualDetails,
        queryParameters: {'month': formatMonthParam(month)},
      );
      return ExpectedVsActualDetailsResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (e, stackTrace) {
      appLog(
        'Error fetching expected vs actual details: $e',
        name: 'ExpectedVsActualDetailsAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static String formatMonthParam(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-01';
}
