import 'package:maribel_wellness_centre_application/core/utils/app_log.dart';
import 'package:dio/dio.dart';
import '../../../../../core/constants/api_endpoints.dart';
import '../model/add_top_investor_model.dart';
import '../model/investor_rating_details_model.dart';
import '../model/investor_rating_update_model.dart';
import '../model/remove_top_investor_model.dart';
import '../model/top_investor_button_model.dart';
import '../model/top_investors_model.dart';


class InvestorRatingRepository {
  final Dio dio;

  InvestorRatingRepository(this.dio);

  Future<InvestorRatingDetailsResponse> getInvestorRatingDetails() async {
    try {
      appLog(
        'Fetching investor rating details',
        name: 'InvestorRatingDetailsAPI',
      );

      final response = await dio.get(
        ApiEndpoints.investorRatingDetails,
      );


      return InvestorRatingDetailsResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e, stackTrace) {
      appLog(
        'Dio error fetching investor rating details: '
            '${e.message}',
        name: 'InvestorRatingDetailsAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      appLog(
        'Error fetching investor rating details: $e',
        name: 'InvestorRatingDetailsAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }


  Future<InvestorRatingUpdateResponseModel> updateInvestorRating({
    required int investorId,
    required double rating,
  }) async {
    try {
      final request = InvestorRatingUpdateRequestModel(
        investorId: investorId,
        rating: rating,
      );

      final requestBody = request.toJson();

      appLog(
        'Request Body: $requestBody',
        name: 'InvestorRatingAPI',
      );

      final response = await dio.post(
        ApiEndpoints.saveInvestorRating,
        data: requestBody,
      );

      appLog(
        'Response: ${response.data}',
        name: 'InvestorRatingAPI',
      );

      return InvestorRatingUpdateResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e, stackTrace) {
      appLog(
        'Status Code: ${e.response?.statusCode}',
        name: 'InvestorRatingAPI',
      );

      appLog(
        'Error Response: ${e.response?.data}',
        name: 'InvestorRatingAPI',
      );

      appLog(
        'Request Data: ${e.requestOptions.data}',
        name: 'InvestorRatingAPI',
      );

      appLog(
        'Failed to update investor rating: $e',
        name: 'InvestorRatingAPI',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    } catch (e, stackTrace) {
      appLog(
        'Failed to update investor rating: $e',
        name: 'InvestorRatingAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<AddTopInvestorResponseModel> addTopInvestor({
    required List<int> investorIds,
  }) async {
    try {
      appLog(
        'AddTopInvestor request: investorIds=$investorIds',
        name: 'AddTopInvestorAPI',
      );

      final request = AddTopInvestorRequestModel(
        investorIds: investorIds,
      );

      final response = await dio.post(
        ApiEndpoints.addTopInvestor,
        data: request.toJson(),
      );


      return AddTopInvestorResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (e, stackTrace) {
      appLog(
        'AddTopInvestor API error: $e',
        name: 'AddTopInvestorAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<TopInvestorsResponse> getTopInvestors() async {
    try {
      appLog('Fetching top investors', name: 'TopInvestorsAPI');

      final response = await dio.get(ApiEndpoints.topInvestors);


      return TopInvestorsResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e, stackTrace) {
      appLog(
        'Dio error fetching top investors: ${e.message}',
        name: 'TopInvestorsAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      appLog(
        'Error fetching top investors: $e',
        name: 'TopInvestorsAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<RemoveTopInvestorResponseModel> removeTopInvestor({
    required List<int> investorIds,
  }) async {
    try {
      appLog(
        'RemoveTopInvestor request: investorIds=$investorIds',
        name: 'RemoveTopInvestorAPI',
      );

      final request = RemoveTopInvestorRequestModel(
        investorIds: investorIds,
      );

      final response = await dio.post(
        ApiEndpoints.removeTopInvestor,
        data: request.toJson(),
      );


      return RemoveTopInvestorResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e, stackTrace) {
      appLog(
        'RemoveTopInvestor API error: ${e.message}',
        name: 'RemoveTopInvestorAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      appLog(
        'Unexpected RemoveTopInvestor error: $e',
        name: 'RemoveTopInvestorAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<AllSettingsResponseModel> getAllSettings() async {
    try {
      appLog('Fetching all settings', name: 'AllSettingsAPI');

      final response = await dio.get(ApiEndpoints.getAllSettings);

      return AllSettingsResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e, stackTrace) {
      appLog(
        'Dio error fetching all settings: ${e.message}',
        name: 'AllSettingsAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      appLog(
        'Error fetching all settings: $e',
        name: 'AllSettingsAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<TopInvestorButtonResponseModel> updateTopInvestorButton({
    required bool isEnabled,
  }) async {
    try {
      appLog(
        'TopInvestorButton request: isEnabled=$isEnabled',
        name: 'TopInvestorButtonAPI',
      );

      final request = TopInvestorButtonRequestModel(
        isEnabled: isEnabled,
      );

      final response = await dio.post(
        ApiEndpoints.topInvestorButton,
        data: request.toJson(),
      );


      return TopInvestorButtonResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e, stackTrace) {
      appLog(
        'TopInvestorButton API error: '
            '${e.message}',
        name: 'TopInvestorButtonAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      appLog(
        'Unexpected TopInvestorButton error: $e',
        name: 'TopInvestorButtonAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}