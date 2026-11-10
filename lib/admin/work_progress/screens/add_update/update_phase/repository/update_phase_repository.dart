
import 'package:maribel_wellness_centre_application/core/utils/app_log.dart';
import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../model/add_or_update_phase_request_model.dart';
import '../model/add_or_update_phase_response_model.dart';
import '../model/add_phase_model.dart';
import '../model/work_phase_list_model.dart';

class AddPhaseRepository {
  final Dio dio;

  AddPhaseRepository({
    required this.dio,
  });

  Future<AddPhaseModel?> addPhase(
      AddPhaseRequestModel request,
      ) async {
    try {
      appLog('Adding project phase...');
      appLog('Stage Name: ${request.stageName}');

      final response = await dio.post(
        ApiEndpoints.addStage,
        data: request.toJson(),
      );


      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData is! Map) return null;

        final map = Map<String, dynamic>.from(responseData);
        final status = map['status'] ?? map['Status'];
        final isSuccess = status == true ||
            status == 1 ||
            status?.toString().toLowerCase() == 'true' ||
            status?.toString().toLowerCase() == 'success';

        if (isSuccess) {
          final data = map['data'] ?? map['Data'];
          if (data is! Map) return null;
          return AddPhaseModel.fromJson(
            Map<String, dynamic>.from(data),
          );
        }

        appLog(
          'Add Phase API Error: '
          '${map['message'] ?? map['Message'] ?? 'Something went wrong'}',
        );

        return null;
      }

      appLog(
        'Add Phase API failed with status code: '
            '${response.statusCode}',
      );

      return null;
    } on DioException catch (e) {
      appLog('Add Phase Dio Error: ${e.message}');

      return null;
    } catch (e, stackTrace) {
      appLog(
        'Add Phase Error: $e',
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  Future<List<AddPhaseModel>> getStageList() async {
    try {
      appLog('Fetching project stage list...');

      final response = await dio.get(
        ApiEndpoints.stageList,
      );


      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;

        if (responseData is! Map) {
          appLog('Stage List Error: Response is not a Map');
          return [];
        }

        final map = Map<String, dynamic>.from(responseData);

        final status = map['status'] ?? map['Status'];

        final isSuccess = status == true ||
            status == 1 ||
            status?.toString().toLowerCase() == 'true' ||
            status?.toString().toLowerCase() == 'success';

        if (!isSuccess) {
          appLog(
            'Stage List API Error: '
                '${map['message'] ?? map['Message'] ?? 'Something went wrong'}',
          );

          return [];
        }

        final data = map['data'] ?? map['Data'];

        if (data is! List) {
          appLog('Stage List Error: Data is not a List');
          return [];
        }

        return data
            .whereType<Map>()
            .map(
              (item) => AddPhaseModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList();
      }

      appLog(
        'Stage List API failed with status code: '
            '${response.statusCode}',
      );

      return [];
    } on DioException catch (e) {
      appLog('Stage List Dio Error: ${e.message}');

      return [];
    } catch (e, stackTrace) {
      appLog(
        'Stage List Error: $e',
        stackTrace: stackTrace,
      );

      return [];
    }
  }


  Future<AddOrUpdatePhaseResponseModel?> addOrUpdatePhase(
      AddOrUpdatePhaseRequestModel request,
      ) async {
    try {
      appLog('Adding/Updating project phase...');
      appLog('Stage ID: ${request.stageId}');
      appLog('Construction Team: ${request.constructionTeam}');
      appLog('Progress: ${request.progress}');
      appLog("due date: ${request.dueDate}");
      appLog('Status: ${request.status}');

      final response = await dio.post(
        ApiEndpoints.addOrUpdatePhase,
        data: request.toJson(),
      );


      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;

        if (responseData is! Map) {
          return null;
        }

        final map = Map<String, dynamic>.from(responseData);

        final status = map['status'] ?? map['Status'];

        final isSuccess = status == true ||
            status == 1 ||
            status?.toString().toLowerCase() == 'true' ||
            status?.toString().toLowerCase() == 'success';

        if (isSuccess) {
          final data = map['data'] ?? map['Data'];

          if (data is! Map) {
            return null;
          }

          return AddOrUpdatePhaseResponseModel.fromJson(
            Map<String, dynamic>.from(data),
          );
        }

        appLog(
          'Add/Update Phase API Error: '
              '${map['message'] ?? map['Message'] ?? 'Something went wrong'}',
        );

        return null;
      }

      appLog(
        'Add/Update Phase API failed with status code: '
            '${response.statusCode}',
      );

      return null;
    } on DioException catch (e) {
      appLog('Add/Update Phase Dio Error: ${e.message}');

      return null;
    } catch (e, stackTrace) {
      appLog(
        'Add/Update Phase Error: $e',
        stackTrace: stackTrace,
      );

      return null;
    }
  }
  
  Future<List<WorkPhaseListModel>> workPhaseList() async {
    try {
      appLog('Fetching work phase list...');

      final response = await dio.get(
        ApiEndpoints.workPhaseList,
      );


      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;

        if (responseData is! Map) {
          throw Exception('Invalid work phase list response');
        }

        final map = Map<String, dynamic>.from(responseData);

        final status = map['status'] ?? map['Status'];

        final isSuccess = status == true ||
            status == 1 ||
            status?.toString().toLowerCase() == 'true' ||
            status?.toString().toLowerCase() == 'success';

        if (!isSuccess) {
          final message = (map['message'] ??
                  map['Message'] ??
                  'Failed to load work progress')
              .toString();
          throw Exception(message);
        }

        final data = map['data'] ?? map['Data'];

        if (data == null) return [];
        if (data is! List) {
          throw Exception('Invalid work phase list data');
        }

        return data
            .whereType<Map>()
            .map(
              (item) => WorkPhaseListModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      throw Exception(
        'Failed to load work progress (status ${response.statusCode})',
      );
    } on DioException catch (e) {
      appLog('Work Phase List Dio Error: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      appLog(
        'Work Phase List Error: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}