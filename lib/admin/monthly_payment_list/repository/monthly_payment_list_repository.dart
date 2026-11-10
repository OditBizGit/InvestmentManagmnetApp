
import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../model/monthly_payment_list_model.dart';
import '../model/payment_verification_history_model.dart';
import '../model/review_payment_verification_model.dart';

class MonthlyPaymentListRepository {
  MonthlyPaymentListRepository({required this.dio});

  final Dio dio;

  Future<MonthlyPaymentListResponseModel> getMonthlyPaymentList({
    required String fromDate,
    required String toDate,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.monthlyPaymentList,
        queryParameters: {
          'FromDate': fromDate,
          'ToDate': toDate,
        },
        cancelToken: cancelToken,
      );

      if (response.data is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response received from the server.',
        );
      }

      final result = MonthlyPaymentListResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!result.status) {
        throw Exception(
          result.message.isNotEmpty
              ? result.message
              : 'Failed to fetch monthly payment list.',
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
                'You are not authorized to view monthly payments.',
              );
            case 404:
              throw Exception(
                'Monthly payment list endpoint not found.',
              );
            default:
              throw Exception(
                'Failed to fetch monthly payment list. Please try again.',
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
        'An unexpected error occurred while fetching monthly payments.',
      );
    }
  }

  Future<PaymentVerificationHistoryResponseModel> getPaymentVerificationHistory({
    required String fromDate,
    required String toDate,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.paymentVerificationHistory,
        queryParameters: {
          'FromDate': fromDate,
          'ToDate': toDate,
        },
        cancelToken: cancelToken,
      );

      if (response.data is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response received from the server.',
        );
      }

      final result = PaymentVerificationHistoryResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!result.status) {
        throw Exception(
          result.message.isNotEmpty
              ? result.message
              : 'Failed to fetch payment verification history.',
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
                'You are not authorized to view verification history.',
              );
            case 404:
              throw Exception(
                'Payment verification history endpoint not found.',
              );
            default:
              throw Exception(
                'Failed to fetch verification history. Please try again.',
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
        'An unexpected error occurred while fetching verification history.',
      );
    }
  }

  Future<ReviewPaymentVerificationResponseModel> reviewPaymentVerification({
    required int transactionId,
    required String status,
    String remarks = '',
    CancelToken? cancelToken,
  }) async {
    try {
      final request = ReviewPaymentVerificationRequestModel(
        transactionId: transactionId,
        status: status,
        remarks: remarks,
      );

      final response = await dio.post(
        ApiEndpoints.acceptOrRejectPaymentStatus,
        data: request.toJson(),
        cancelToken: cancelToken,
      );

      if (response.data is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response received from the server.',
        );
      }

      final result = ReviewPaymentVerificationResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!result.status) {
        throw Exception(
          result.message.isNotEmpty
              ? result.message
              : 'Failed to update payment verification status.',
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
                'You are not authorized to review payments.',
              );
            case 404:
              throw Exception(
                'Payment verification endpoint not found.',
              );
            default:
              throw Exception(
                'Failed to review payment. Please try again.',
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
        'An unexpected error occurred while reviewing the payment.',
      );
    }
  }
}
