import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../model/refund_termination_model.dart';

class RefundTerminationRepository {
  RefundTerminationRepository(this.dio);

  final Dio dio;

  static String formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Throws [DioException] on HTTP errors, or an [Exception] carrying the
  /// server message when the envelope says `success: false`.
  Future<RefundTerminationReportModel> getReport({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final response = await dio.get(
      ApiEndpoints.reportRefundTermination,
      queryParameters: {
        'fromDate': formatDate(fromDate),
        'toDate': formatDate(toDate),
      },
    );

    final body = response.data;
    if (body is! Map) throw Exception('Unexpected response from server.');
    if (body['success'] != true) {
      throw Exception(body['message']?.toString() ?? '');
    }
    final data = body['data'];
    if (data is! Map) return const RefundTerminationReportModel();
    return RefundTerminationReportModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }
}
