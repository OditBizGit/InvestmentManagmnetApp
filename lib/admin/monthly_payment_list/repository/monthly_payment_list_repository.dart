
import 'dart:developer';

import 'package:dio/dio.dart';

import '../model/monthly_payment_list_model.dart';

class MonthlyPaymentListRepository {
  final Dio _dio;

  MonthlyPaymentListRepository(this._dio);

  Future<MonthlyPaymentListResponseModel> getMonthlyPaymentList({
    required DateTime fromDate,
    required DateTime toDate,
    CancelToken? cancelToken,
  }) async {
    try {
      final queryParameters = {
        'FromDate': _formatDate(fromDate),
        'ToDate': _formatDate(toDate),
      };

      log(
        'Fetching monthly payment list',
        name: 'MonthlyPaymentListAPI',
      );

      log(
        'Query Parameters: $queryParameters',
        name: 'MonthlyPaymentListAPI',
      );

      final response = await _dio.get<dynamic>(
        '/api/Investor/MonthlyPaymentList',
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );

      log(
        'Response: ${response.data}',
        name: 'MonthlyPaymentListAPI',
      );

      return MonthlyPaymentListResponseModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (error) {
      log(
        'API Error: ${error.message}',
        name: 'MonthlyPaymentListAPI',
      );

      log(
        'Error Response: ${error.response?.data}',
        name: 'MonthlyPaymentListAPI',
      );

      rethrow;
    } catch (error, stackTrace) {
      log(
        'Unexpected Error: $error',
        name: 'MonthlyPaymentListAPI',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}

