import 'dart:developer';

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
      log(
        'Fetching investor rating details',
        name: 'InvestorRatingDetailsAPI',
      );

      final response = await dio.get(
        ApiEndpoints.investorRatingDetails,
      );

      log(
        'Investor rating details response: ${response.data}',
        name: 'InvestorRatingDetailsAPI',
      );

      return InvestorRatingDetailsResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e, stackTrace) {
      log(
        'Dio error fetching investor rating details: '
            '${e.response?.data ?? e.message}',
        name: 'InvestorRatingDetailsAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      log(
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
    required int rating,
  }) async {
    try {
      log(
        'Updating investor rating: investorId=$investorId, rating=$rating',
        name: 'InvestorRatingAPI',
      );

      final request = InvestorRatingUpdateRequestModel(
        investorId: investorId,
        rating: rating,
      );

      final response = await dio.post(
        ApiEndpoints.saveInvestorRating,
        data: request.toJson(),
      );

      log(
        'Investor rating response: ${response.data}',
        name: 'InvestorRatingAPI',
      );

      return InvestorRatingUpdateResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (e, stackTrace) {
      log(
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
      log(
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

      log(
        'AddTopInvestor response: ${response.data}',
        name: 'AddTopInvestorAPI',
      );

      return AddTopInvestorResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (e, stackTrace) {
      log(
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
      log('Fetching top investors', name: 'TopInvestorsAPI');

      final response = await dio.get(ApiEndpoints.topInvestors);

      log(
        'Top investors response: ${response.data}',
        name: 'TopInvestorsAPI',
      );

      return TopInvestorsResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e, stackTrace) {
      log(
        'Dio error fetching top investors: ${e.response?.data ?? e.message}',
        name: 'TopInvestorsAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      log(
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
      log(
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

      log(
        'RemoveTopInvestor response: ${response.data}',
        name: 'RemoveTopInvestorAPI',
      );

      return RemoveTopInvestorResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e, stackTrace) {
      log(
        'RemoveTopInvestor API error: ${e.response?.data ?? e.message}',
        name: 'RemoveTopInvestorAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      log(
        'Unexpected RemoveTopInvestor error: $e',
        name: 'RemoveTopInvestorAPI',
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
      log(
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

      log(
        'TopInvestorButton response: ${response.data}',
        name: 'TopInvestorButtonAPI',
      );

      return TopInvestorButtonResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e, stackTrace) {
      log(
        'TopInvestorButton API error: '
            '${e.response?.data ?? e.message}',
        name: 'TopInvestorButtonAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      log(
        'Unexpected TopInvestorButton error: $e',
        name: 'TopInvestorButtonAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}