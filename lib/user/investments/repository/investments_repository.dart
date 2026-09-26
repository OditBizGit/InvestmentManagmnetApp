import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';
import 'package:maribel_wellness_centre_application/user/home/model/work_progress_details_response_model.dart';
import 'package:maribel_wellness_centre_application/user/investments/model/investor_transaction_history_response_model.dart';
import 'package:maribel_wellness_centre_application/user/investments/model/project_stage_model.dart';
import 'package:maribel_wellness_centre_application/user/investments/model/work_progress_graph_point_model.dart';
import 'package:maribel_wellness_centre_application/user/investments/model/work_progress_graph_response_model.dart';

class InvestmentsRepository {
  InvestmentsRepository({
    required this.dio,
  });

  final Dio dio;

  Future<InvestorTransactionHistoryResponseModel> getInvestorTransactionHistory(
    String userId,
  ) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.investorTransactionHistory}$userId',
      );

      return InvestorTransactionHistoryResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      log('Get Investor Transaction History Error: ${e.message}');
      rethrow;
    } catch (e) {
      log('Get Investor Transaction History Error: $e');
      rethrow;
    }
  }

  /// Stages that have work-progress data (`stageId` / `stageName`).
  Future<List<ProjectStageModel>> getWorkProgressStages() async {
    try {
      final response = await dio.get(ApiEndpoints.workProgressDetails);
      final parsed = WorkProgressDetailsResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      final looksSuccessful = parsed.status ||
          parsed.code == 200 ||
          parsed.message.toLowerCase().contains('success');

      if (!looksSuccessful && parsed.data.isEmpty) {
        throw Exception(
          parsed.message.isNotEmpty
              ? parsed.message
              : 'Failed to load work progress stages',
        );
      }

      final seenStageIds = <int>{};
      final stages = <ProjectStageModel>[];

      for (final item in parsed.data) {
        final stageName = item.stageName.trim();
        if (stageName.isEmpty || item.stageId <= 0) continue;
        if (!seenStageIds.add(item.stageId)) continue;

        stages.add(
          ProjectStageModel(
            stageId: item.stageId,
            stageName: stageName,
          ),
        );
      }

      return List.unmodifiable(stages);
    } on DioException catch (e) {
      log('Get Work Progress Stages Error: ${e.message}');
      rethrow;
    } catch (e) {
      log('Get Work Progress Stages Error: $e');
      rethrow;
    }
  }

  /// Work-progress graph points for a stage (`date` / `progress`).
  Future<List<WorkProgressGraphPointModel>> getWorkProgressGraph(
    int stageId,
  ) async {
    try {
      final response = await dio.get(
        ApiEndpoints.workProgressGraph,
        queryParameters: {'stageId': stageId},
      );
      final parsed = WorkProgressGraphResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      final looksSuccessful = parsed.status ||
          parsed.code == 200 ||
          parsed.message.toLowerCase().contains('success');

      if (!looksSuccessful && parsed.data.isEmpty) {
        throw Exception(
          parsed.message.isNotEmpty
              ? parsed.message
              : 'Failed to load work progress graph',
        );
      }

      return List.unmodifiable(parsed.data);
    } on DioException catch (e) {
      log('Get Work Progress Graph Error: ${e.message}');
      rethrow;
    } catch (e) {
      log('Get Work Progress Graph Error: $e');
      rethrow;
    }
  }
}
