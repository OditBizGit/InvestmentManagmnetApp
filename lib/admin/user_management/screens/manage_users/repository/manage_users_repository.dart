import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/manage_users_response_model.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../model/block_user_request_model.dart';
import '../model/pdf_excel_model.dart';
import '../model/refund_investor_request_model.dart';
import '../model/save_investor_mou_request_model.dart';

class ManageUsersRepository {
  ManageUsersRepository({required this.dio});

  final Dio dio;

  Future<ManageUsersResponse> getInvestors() async {
    try {
      final response = await dio.get(ApiEndpoints.investorsList);
      final payload = _decodePayload(response.data);
      return ManageUsersResponse.fromJson(payload);
    } on DioException catch (error) {
      log(
        'Get manage users failed: ${error.message} '
        '(status ${error.response?.statusCode})',
        name: 'ManageUsersRepository',
      );
      rethrow;
    } on FormatException catch (error) {
      log(
        'Get manage users invalid response: $error',
        name: 'ManageUsersRepository',
      );
      rethrow;
    } catch (error) {
      log(
        'Get manage users failed: $error',
        name: 'ManageUsersRepository',
      );
      rethrow;
    }
  }

  Future<BlockUserResponseModel> blockUser({
    required int userId,
    required bool isActive,
  }) async {
    try {
      final request = BlockUserRequestModel(
        userId: userId,
        isActive: isActive,
      );

      final response = await dio.post(
        ApiEndpoints.blockUser,
        data: request.toJson(),
      );

      final raw = response.data;
      if (raw is! Map) {
        throw const FormatException('Invalid block user response');
      }

      final result = BlockUserResponseModel.fromJson(
        Map<String, dynamic>.from(raw),
      );

      final succeeded = result.status || result.code == 200;
      if (!succeeded) {
        throw Exception(
          result.message.trim().isNotEmpty
              ? result.message.trim()
              : 'Failed to update user status',
        );
      }

      return result;
    } on DioException catch (error) {
      log(
        'Block user failed: ${error.message} '
        '(status ${error.response?.statusCode})',
        name: 'ManageUsersRepository',
      );
      rethrow;
    } on FormatException catch (error) {
      log(
        'Block user invalid response: $error',
        name: 'ManageUsersRepository',
      );
      rethrow;
    } catch (error) {
      log(
        'Block user failed: $error',
        name: 'ManageUsersRepository',
      );
      rethrow;
    }
  }

  Future<RefundInvestorResponseModel> refundInvestor({
    required int userId,
    required double refundAmount,
    required String paymentMethod,
    required String remarks,
  }) async {
    try {
      final request = RefundInvestorRequestModel(
        userId: userId,
        refundAmount: refundAmount,
        paymentMethod: paymentMethod,
        remarks: remarks,
      );

      final response = await dio.post(
        ApiEndpoints.refundInvestor,
        data: request.toJson(),
      );

      final raw = response.data;
      if (raw is! Map) {
        throw const FormatException('Invalid refund response');
      }

      final result = RefundInvestorResponseModel.fromJson(
        Map<String, dynamic>.from(raw),
      );

      final succeeded = result.status || result.code == 200;
      if (!succeeded) {
        throw Exception(
          result.message.trim().isNotEmpty
              ? result.message.trim()
              : 'Failed to process refund',
        );
      }

      return result;
    } on DioException catch (error) {
      log(
        'Refund investor failed: ${error.message} '
        '(status ${error.response?.statusCode})',
        name: 'ManageUsersRepository',
      );
      rethrow;
    } on FormatException catch (error) {
      log(
        'Refund investor invalid response: $error',
        name: 'ManageUsersRepository',
      );
      rethrow;
    } catch (error) {
      log(
        'Refund investor failed: $error',
        name: 'ManageUsersRepository',
      );
      rethrow;
    }
  }


// save MOU

  Future<SaveInvestorMOUResponseModel> saveInvestorMOU({
    required int investorId,
    required String status,
  }) async {
    try {
      const allowedStatuses = [
        'Pending',
        'Issued',
        'Completed',
      ];

      if (!allowedStatuses.contains(status)) {
        throw ArgumentError(
          'Invalid status. Allowed values: '
              'Pending, Issued, Completed.',
        );
      }

      final request = SaveInvestorMOURequestModel(
        investorId: investorId,
        status: status,
      );

      final response = await dio.post(
        ApiEndpoints.saveMOU,
        data: request.toJson(),
      );

      final raw = response.data;

      if (raw is! Map) {
        throw const FormatException(
          'Invalid save investor MOU response',
        );
      }

      final result = SaveInvestorMOUResponseModel.fromJson(
        Map<String, dynamic>.from(raw),
      );

      if (!result.status || result.code != 200) {
        throw Exception(
          result.message.isNotEmpty
              ? result.message
              : 'Failed to save investor MOU',
        );
      }

      return result;
    } on DioException catch (error) {
      log(
        'Save investor MOU failed: ${error.message} '
            '(status ${error.response?.statusCode})',
        name: 'ManageUsersRepository',
      );
      rethrow;
    } catch (error) {
      log(
        'Save investor MOU failed: $error',
        name: 'ManageUsersRepository',
      );
      rethrow;
    }
  }


  Future<SaveInvestorMOUResponseModel> getInvestorMOU({
    required int investorId,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.getInvestorsMOU.replaceFirst(
          '{investorId}',
          investorId.toString(),
        ),
      );

      final raw = response.data;

      if (raw is! Map) {
        throw const FormatException(
          'Invalid investor MOU response',
        );
      }

      final result = SaveInvestorMOUResponseModel.fromJson(
        Map<String, dynamic>.from(raw),
      );

      if (!result.status || result.code != 200) {
        throw Exception(
          result.message.isNotEmpty
              ? result.message
              : 'Failed to fetch investor MOU',
        );
      }

      return result;
    } on DioException catch (error) {
      log(
        'Get investor MOU failed: ${error.message} '
        '(status ${error.response?.statusCode})',
        name: 'ManageUsersRepository',
      );
      rethrow;
    } on FormatException catch (error) {
      log(
        'Get investor MOU invalid response: $error',
        name: 'ManageUsersRepository',
      );
      rethrow;
    } catch (error) {
      log(
        'Get investor MOU failed: $error',
        name: 'ManageUsersRepository',
      );
      rethrow;
    }
  }

  // save llp
  
  Future<SaveInvestorMOUResponseModel> saveInvestorLLP({
    required int investorId,
    required String status,
  }) async {
    try {
      const allowedStatuses = [
        'Pending',
        'Issued',
        'Completed',
      ];

      if (!allowedStatuses.contains(status)) {
        throw ArgumentError(
          'Invalid status. Allowed values: '
              'Pending, Issued, Completed.',
        );
      }

      final request = SaveInvestorMOURequestModel(
        investorId: investorId,
        status: status,
      );

      final response = await dio.post(
        ApiEndpoints.saveLLP,
        data: request.toJson(),
      );

      final raw = response.data;

      if (raw is! Map) {
        throw const FormatException(
          'Invalid save investor LLP response',
        );
      }

      final result = SaveInvestorMOUResponseModel.fromJson(
        Map<String, dynamic>.from(raw),
      );

      if (!result.status || result.code != 200) {
        throw Exception(
          result.message.isNotEmpty
              ? result.message
              : 'Failed to save investor LLP status',
        );
      }

      return result;
    } on DioException catch (error) {
      log(
        'Save investor LLP failed: ${error.message} '
            '(status ${error.response?.statusCode})',
        name: 'ManageUsersRepository',
      );
      rethrow;
    } on FormatException catch (error) {
      log(
        'Save investor LLP invalid response: $error',
        name: 'ManageUsersRepository',
      );
      rethrow;
    } catch (error) {
      log(
        'Save investor LLP failed: $error',
        name: 'ManageUsersRepository',
      );
      rethrow;
    }
  }


  //  get llp


  Future<SaveInvestorMOUResponseModel> getInvestorLLP({
    required int investorId,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.getInvestorsLLP.replaceFirst(
          '{investorId}',
          investorId.toString(),
        ),
      );

      final raw = response.data;

      if (raw is! Map) {
        throw const FormatException(
          'Invalid investor LLP response',
        );
      }

      final result = SaveInvestorMOUResponseModel.fromJson(
        Map<String, dynamic>.from(raw),
      );

      if (!result.status || result.code != 200) {
        throw Exception(
          result.message.isNotEmpty
              ? result.message
              : 'Failed to fetch investor LLP',
        );
      }

      return result;
    } on DioException catch (error) {
      log(
        'Get investor LLP failed: ${error.message} '
            '(status ${error.response?.statusCode})',
        name: 'ManageUsersRepository',
      );
      rethrow;
    } on FormatException catch (error) {
      log(
        'Get investor LLP invalid response: $error',
        name: 'ManageUsersRepository',
      );
      rethrow;
    } catch (error) {
      log(
        'Get investor LLP failed: $error',
        name: 'ManageUsersRepository',
      );
      rethrow;
    }
  }


  // pdf excel

  Future<PdfExcelResponseModel> getPdfExcel(
      PdfExcelRequestModel request,
      ) async {
    try {
      final response = await dio.post(
        ApiEndpoints.getPdfExcel,
        data: request.toJson(),
      );

      final result = PdfExcelResponseModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );

      if (!result.status || result.code != 200) {
        throw Exception(
          result.message.isNotEmpty
              ? result.message
              : 'Failed to fetch investor details',
        );
      }

      return result;
    } on DioException catch (e) {
      log(
        'Get PDF/Excel API error: ${e.message}',
        name: 'PdfExcelRepository',
      );
      rethrow;
    } catch (e) {
      log(
        'Get PDF/Excel error: $e',
        name: 'PdfExcelRepository',
      );
      rethrow;
    }
  }




  dynamic _decodePayload(dynamic data) {
    if (data == null) {
      throw const FormatException('Empty manage users response');
    }

    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) {
        throw const FormatException('Empty manage users response');
      }
      return jsonDecode(trimmed);
    }

    return data;
  }
}
