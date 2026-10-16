import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/manage_users_response_model.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../model/block_user_request_model.dart';

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
