import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../model/payment_request_model.dart';
import '../model/review_payment_model.dart';

class PaymentRequestRepository {
  final Dio dio;

  PaymentRequestRepository({required this.dio});

  Future<PaymentRequestResponseModel> getPaymentRequests({
    String status = 'All',
  }) async {
    try {
      log(
        '[PaymentRequestRepository] Fetching payment requests. '
        'Status: $status',
      );

      final request = PaymentRequestModel(status: status);

      final response = await dio.get(
        ApiEndpoints.getPaymentRequests,
        queryParameters: request.toQueryParameters(),
      );

      log('[PaymentRequestRepository] Response: ${response.data}');

      final result = PaymentRequestResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      if (result.status) {
        log(
          '[PaymentRequestRepository] Successfully fetched '
          '${result.data.length} payment requests.',
        );

        return result;
      }

      log('[PaymentRequestRepository] API Error: ${result.message}');

      throw Exception(result.message);
    } on DioException catch (e, stackTrace) {
      log(
        '[PaymentRequestRepository] Dio Error: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    } catch (e, stackTrace) {
      log(
        '[PaymentRequestRepository] Error: $e',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }


  Future<AcceptOrRejectPaymentResponseModel>
  acceptOrRejectPaymentRequest({
    required int requestId,
    required String status,
    String remarks = '',
  }) async {
    try {
      log(
        '[PaymentRequestRepository] Accept/Reject request started. '
            'RequestId: $requestId, Status: $status',
      );

      final request = AcceptOrRejectPaymentRequestModel(
        requestId: requestId,
        status: status,
        remarks: remarks,
      );

      log(
        '[PaymentRequestRepository] Request Payload: ${request.toJson()}',
      );

      final response = await dio.post(
        ApiEndpoints.acceptOrRejectPaymentRequest,
        data: request.toJson(),
      );

      log(
        '[PaymentRequestRepository] Response: ${response.data}',
      );

      final result = AcceptOrRejectPaymentResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      if (result.status) {
        log(
          '[PaymentRequestRepository] Request processed successfully: '
              '${result.message}',
        );

        return result;
      }

      throw Exception(result.message);
    } on DioException catch (e, stackTrace) {
      log(
        '[PaymentRequestRepository] Dio Error: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    } catch (e, stackTrace) {
      log(
        '[PaymentRequestRepository] Error: $e',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }
}
