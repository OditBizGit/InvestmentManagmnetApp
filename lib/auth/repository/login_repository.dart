import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../model/login_request_model.dart';
import '../model/login_response_model.dart';

class AuthRepository {
  final Dio dio;

  AuthRepository({
    required this.dio,
  });

  Future<LoginResponseModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final request = LoginRequestModel(
        username: username,
        password: password,
      );

      final response = await dio.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      return LoginResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Something went wrong',
      );
    } catch (e) {
      throw Exception('Something went wrong');
    }
  }
}