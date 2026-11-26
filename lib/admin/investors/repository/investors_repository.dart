
import 'package:maribel_wellness_centre_application/core/utils/app_log.dart';
import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../model/investor_response_model.dart';
import '../model/investor_type_model.dart';
import '../model/staff_model.dart';
import '../model/register_investor_model.dart';
import '../model/update_investor_model.dart';

class InvestorsRepository {
  final Dio dio;

  /// Register and update can carry up to 20 images (about 40 MB), more than the
  /// shared 30 s send timeout allows on slow links. Applied to those two calls
  /// only, through per-request options.
  static const Duration _uploadTimeout = Duration(seconds: 180);

  static Options get _uploadOptions => Options(
        sendTimeout: _uploadTimeout,
        receiveTimeout: _uploadTimeout,
      );

  InvestorsRepository({
    required this.dio,
  });

  Future<InvestorResponseModel> getInvestors() async {
    try {
      final response = await dio.get(
        ApiEndpoints.investorsList,
      );

      return InvestorResponseModel.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      appLog(
        'Get Investors Error: ${e.message}',
      );

      rethrow;
    } catch (e) {
      appLog(
        'Get Investors Error: $e',
      );

      rethrow;
    }
  }

  Future<StaffListResponseModel> getStaffList() async {
    try {
      final response = await dio.get(
        ApiEndpoints.staffList,
      );

      return StaffListResponseModel.fromJson(
        response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      appLog(
        'Get Staff List Error: ${e.message}',
      );

      rethrow;
    } catch (e) {
      appLog(
        'Get Staff List Error: $e',
      );

      rethrow;
    }
  }

  Future<InvestorTypeResponseModel> getInvestorTypes() async {
    try {
      final response = await dio.get(
        ApiEndpoints.investorTypes,
      );

      return InvestorTypeResponseModel.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      appLog(
        'Get Investor Types Error: ${e.message}',
      );

      rethrow;
    } catch (e) {
      appLog(
        'Get Investor Types Error: $e',
      );

      rethrow;
    }
  }


  ///  register investor

  Future<RegisterInvestorResponseModel> registerInvestor(
      RegisterInvestorRequestModel request,
      ) async {
    try {
      final formData = await request.toFormData();

      final response = await dio.post(
        ApiEndpoints.registerInvestor,
        data: formData,
        options: _uploadOptions,
      );

      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : Map<String, dynamic>.from(response.data as Map);

      appLog('Register Investor completed with status code ${response.statusCode}');

      return RegisterInvestorResponseModel.fromJson(payload);
    } on DioException catch (e) {
      appLog(
        'Register Investor Error: ${e.message} (status ${e.response?.statusCode})',
      );

      rethrow;
    } catch (e) {
      appLog(
        'Register Investor Error: $e',
      );

      rethrow;
    }
  }

  ///update user details

  Future<UpdateInvestorResponseModel> updateInvestor(
      UpdateInvestorRequestModel request,
      ) async {
    try {
      final formData = await request.toFormData();

      final response = await dio.post(
        ApiEndpoints.updateInvestor,
        data: formData,
        options: _uploadOptions,
      );

      if (response.statusCode == 200) {
        appLog(
          'Update Investor request body:\n${_formDataForLog(formData)}',
          name: 'InvestorsRepository',
        );
      }

      return UpdateInvestorResponseModel.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      appLog(
        'Update Investor Error: ${e.message}',
      );


      rethrow;
    } catch (e) {
      appLog(
        'Update Investor Error: $e',
      );

      rethrow;
    }
  }

  String _formDataForLog(FormData formData) {
    final buffer = StringBuffer();
    buffer.writeln('fields:');
    for (final field in formData.fields) {
      buffer.writeln('  ${field.key}: ${field.value}');
    }
    buffer.writeln('files:');
    if (formData.files.isEmpty) {
      buffer.writeln('  (none)');
    } else {
      for (final file in formData.files) {
        buffer.writeln(
          '  ${file.key}: ${file.value.filename ?? 'unnamed'} '
          '(${file.value.length} bytes)',
        );
      }
    }
    return buffer.toString();
  }

}