import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../model/payment_status_report_model.dart';


class PaymentStatusReportRepository {
  PaymentStatusReportRepository({required this.dio});

  final Dio dio;

  Future<PaymentStatusReportResponseModel> getPaymentStatusReport({
    String status = 'All',
    String? search,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.paymentStatusReport,
        queryParameters: {
          'status': status,
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
        },
        cancelToken: cancelToken,
      );

      if (response.data is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response received from the server.',
        );
      }

      final result = PaymentStatusReportResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!result.status) {
        throw Exception(
          result.message.isNotEmpty
              ? result.message
              : 'Failed to fetch payment status report.',
        );
      }

      return result;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) rethrow;

      final responseData = e.response?.data;

      if (responseData is Map<String, dynamic> &&
          responseData['message'] != null) {
        throw Exception(responseData['message'].toString());
      }

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw Exception(
            'Request timed out. Please try again.',
          );

        case DioExceptionType.connectionError:
          throw Exception(
            'Unable to connect to the server. Check your internet connection.',
          );

        case DioExceptionType.badResponse:
          switch (e.response?.statusCode) {
            case 401:
              throw Exception(
                'Session expired. Please log in again.',
              );
            case 403:
              throw Exception(
                'You are not authorized to view this report.',
              );
            case 404:
              throw Exception(
                'Payment status report endpoint not found.',
              );
            default:
              throw Exception(
                'Failed to fetch payment status report. Please try again.',
              );
          }

        default:
          throw Exception(
            'An unexpected network error occurred.',
          );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
        'An unexpected error occurred while fetching the report.',
      );
    }
  }
}