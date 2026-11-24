import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../model/collection_aging_model.dart';

class CollectionAgingRepository {
  CollectionAgingRepository(this.dio);

  final Dio dio;

  static String formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Throws [DioException] on HTTP errors, or an [Exception] carrying the
  /// server message when the envelope says `success: false`.
  Future<CollectionAgingReportModel> getReport({
    required DateTime asOfDate,
  }) async {
    // Today (device date) is not sent: the server then uses its own date, so
    // a time-zone difference around midnight cannot trigger the future-date
    // 400.
    final now = DateTime.now();
    final isToday =
        asOfDate.year == now.year &&
        asOfDate.month == now.month &&
        asOfDate.day == now.day;
    final response = await dio.get(
      ApiEndpoints.reportCollectionAging,
      queryParameters: {if (!isToday) 'asOfDate': formatDate(asOfDate)},
    );

    final body = response.data;
    if (body is! Map) throw Exception('Unexpected response from server.');
    if (body['success'] != true) {
      throw Exception(body['message']?.toString() ?? '');
    }
    final data = body['data'];
    if (data is! Map) return const CollectionAgingReportModel();
    return CollectionAgingReportModel.fromJson(Map<String, dynamic>.from(data));
  }
}
