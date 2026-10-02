import 'dart:developer';

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
      log('Fetching top investors...');

      final response = await dio.get(
        ApiEndpoints.topInvestors,
      );

      log('Top Investors Response: ${response.data}');

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
      log('Top Investors Dio Error: ${e.message}');
      log('Top Investors Dio Response: ${e.response?.data}');
      rethrow;
    } catch (e, stackTrace) {
      log(
        'Top Investors Error: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

/// recent payments
  Future<List<TransactionHistoryModel>> getPaymentHistory() async {
    try {
      log('Fetching investor transaction history...');

      final response = await dio.get(
        ApiEndpoints.transactionHistory,
      );

      log(
        'Transaction History Response: ${response.data}',
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
      log(
        'Transaction History Dio Error: ${e.message}',
      );
      log(
        'Transaction History Dio Response: '
        '${e.response?.data}',
      );
      rethrow;
    } catch (e, stackTrace) {
      log(
        'Transaction History Error: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

   //// recent updates
  Future<List<WorkUpdateModel>> recentWorkUpdates() async {
    try {
      log('Fetching work updates...');

      final response = await dio.get(
        ApiEndpoints.getWorkUpdates,
      );

      log(
        'Get Work Updates Response: ${response.data}',
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
      log(
        'Get Work Updates Dio Error: ${e.message}',
      );
      log(
        'Get Work Updates Dio Response: '
        '${e.response?.data}',
      );
      rethrow;
    } catch (e, stackTrace) {
      log(
        'Get Work Updates Error: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// dashboard function
  Future<DashboardModel> getDashboard() async {
    try {
      log('Fetching dashboard data...');

      final response = await dio.get(
        ApiEndpoints.getDashboard,
      );

      log(
        'Get Dashboard Response: ${response.data}',
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
      log(
        'Get Dashboard Dio Error: ${e.message}',
      );
      log(
        'Get Dashboard Dio Response: '
        '${e.response?.data}',
      );
      rethrow;
    } catch (e, stackTrace) {
      log(
        'Get Dashboard Error: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
