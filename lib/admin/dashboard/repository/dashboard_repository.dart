
import 'package:maribel_wellness_centre_application/core/utils/app_log.dart';
import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../model/all_transaction_history_model.dart';
import '../model/dashboard_model.dart';
import '../model/recent_updates_model.dart';
import '../model/top_investors_model.dart';

class DashboardRepository {
  final Dio dio;

  DashboardRepository({
    required this.dio,
  });

  Future<List<TopInvestorsModel>> getTopInvestors() async {
    try {
      appLog('Fetching top investors...');

      final response = await dio.get(
        ApiEndpoints.topInvestors,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;

        if (responseData is! Map) {
          throw Exception('Invalid top investors response');
        }

        final map = Map<String, dynamic>.from(responseData);

        final status = map['status'] ?? map['Status'];

        final isSuccess = status == true ||
            status == 1 ||
            status?.toString().toLowerCase() == 'true' ||
            status?.toString().toLowerCase() == 'success';

        if (!isSuccess) {
          final message = (map['message'] ??
                  map['Message'] ??
                  'Failed to load top investors')
              .toString();
          throw Exception(message);
        }

        final data = map['data'] ?? map['Data'];

        if (data == null) return [];
        if (data is! List) {
          throw Exception('Invalid top investors data');
        }

        return data
            .whereType<Map>()
            .map(
              (item) => TopInvestorsModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      throw Exception(
        'Failed to load top investors (status ${response.statusCode})',
      );
    } on DioException catch (e) {
      appLog('Top Investors Dio Error: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      appLog(
        'Top Investors Error: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

/// recent payments
  Future<List<TransactionHistoryModel>> getPaymentHistory() async {
    try {
      appLog('Fetching investor transaction history...');

      final response = await dio.get(
        ApiEndpoints.transactionHistory,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;

        if (responseData is! Map) {
          throw Exception('Invalid payment history response');
        }

        final map = Map<String, dynamic>.from(responseData);

        final status = map['status'] ?? map['Status'];

        final isSuccess = status == true ||
            status == 1 ||
            status?.toString().toLowerCase() == 'true' ||
            status?.toString().toLowerCase() == 'success';

        if (!isSuccess) {
          final message = (map['message'] ??
                  map['Message'] ??
                  'Failed to load recent payments')
              .toString();
          throw Exception(message);
        }

        final data = map['data'] ?? map['Data'];

        if (data == null) return [];
        if (data is! List) {
          throw Exception('Invalid payment history data');
        }

        return data
            .whereType<Map>()
            .map(
              (item) => TransactionHistoryModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      throw Exception(
        'Failed to load recent payments (status ${response.statusCode})',
      );
    } on DioException catch (e) {
      appLog(
        'Transaction History Dio Error: ${e.message}',
      );
      rethrow;
    } catch (e, stackTrace) {
      appLog(
        'Transaction History Error: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

   //// recent updates
  Future<List<WorkUpdateModel>> recentWorkUpdates() async {
    try {
      appLog('Fetching work updates...');

      final response = await dio.get(
        ApiEndpoints.getWorkUpdates,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;

        if (responseData is! Map) {
          throw Exception('Invalid recent updates response');
        }

        final map = Map<String, dynamic>.from(
          responseData,
        );

        final status = map['status'] ?? map['Status'];

        final isSuccess = status == true ||
            status == 1 ||
            status?.toString().toLowerCase() == 'true' ||
            status?.toString().toLowerCase() == 'success';

        if (!isSuccess) {
          final message = (map['message'] ??
                  map['Message'] ??
                  'Failed to load recent updates')
              .toString();
          throw Exception(message);
        }

        final data = map['data'] ?? map['Data'];

        if (data == null) return [];
        if (data is! List) {
          throw Exception('Invalid recent updates data');
        }

        return data
            .whereType<Map>()
            .map(
              (item) => WorkUpdateModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      throw Exception(
        'Failed to load recent updates (status ${response.statusCode})',
      );
    } on DioException catch (e) {
      appLog(
        'Get Work Updates Dio Error: ${e.message}',
      );
      rethrow;
    } catch (e, stackTrace) {
      appLog(
        'Get Work Updates Error: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// dashboard function
  Future<DashboardModel> getDashboard({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      appLog(
        'Fetching dashboard data ($fromDate — $toDate)...',
      );

      final response = await dio.get(
        ApiEndpoints.getDashboard,
        queryParameters: {
          'FromDate': fromDate,
          'ToDate': toDate,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;

        if (responseData is! Map) {
          throw Exception('Invalid dashboard response');
        }

        final map = Map<String, dynamic>.from(
          responseData,
        );

        final status = map['status'] ?? map['Status'];

        final isSuccess = status == true ||
            status == 1 ||
            status?.toString().toLowerCase() == 'true' ||
            status?.toString().toLowerCase() == 'success';

        if (!isSuccess) {
          final message = (map['message'] ??
                  map['Message'] ??
                  'Failed to load dashboard')
              .toString();
          throw Exception(message);
        }

        final data = map['data'] ?? map['Data'];

        if (data is! Map) {
          throw Exception('Invalid dashboard data');
        }

        return DashboardModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      throw Exception(
        'Failed to load dashboard (status ${response.statusCode})',
      );
    } on DioException catch (e) {
      appLog(
        'Get Dashboard Dio Error: ${e.message}',
      );
      rethrow;
    } catch (e, stackTrace) {
      appLog(
        'Get Dashboard Error: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
