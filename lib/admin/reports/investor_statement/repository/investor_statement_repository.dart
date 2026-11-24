import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_log.dart';

import '../model/investor_statement_model.dart';

class InvestorStatementRepository {
  InvestorStatementRepository(this.dio);

  final Dio dio;

  /// [fromDate] / [toDate] are optional and sent as `yyyy-MM-dd`.
  Future<InvestorStatementResponseModel> getStatement({
    required int userId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.reportInvestorStatement.replaceFirst(
          '{userId}',
          userId.toString(),
        ),
        queryParameters: {
          if (fromDate != null) 'fromDate': formatDateParam(fromDate),
          if (toDate != null) 'toDate': formatDateParam(toDate),
        },
      );
      return InvestorStatementResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (e, stackTrace) {
      appLog(
        'Error fetching investor statement: $e',
        name: 'InvestorStatementAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static String formatDateParam(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
