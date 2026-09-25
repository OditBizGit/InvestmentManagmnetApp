import 'dart:developer';

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
      log('Adding project phase...');
      log('Stage Name: ${request.stageName}');

      final response = await dio.post(
        ApiEndpoints.addStage,
        data: request.toJson(),
      );

      log('Add Phase Response: ${response.data}');

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

        log(
          'Add Phase API Error: '
          '${map['message'] ?? map['Message'] ?? 'Something went wrong'}',
        );

        return null;
      }

      log(
        'Add Phase API failed with status code: '
            '${response.statusCode}',
      );

      return null;
    } on DioException catch (e) {
      log('Add Phase Dio Error: ${e.message}');
      log('Add Phase Dio Response: ${e.response?.data}');

      return null;
    } catch (e, stackTrace) {
      log(
        'Add Phase Error: $e',
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  Future<List<AddPhaseModel>> getStageList() async {
    try {
      log('Fetching project stage list...');

      final response = await dio.get(
        ApiEndpoints.stageList,
      );

      log('Stage List Response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;

        if (responseData is! Map) {
          log('Stage List Error: Response is not a Map');
          return [];
        }

        final map = Map<String, dynamic>.from(responseData);

        final status = map['status'] ?? map['Status'];

        final isSuccess = status == true ||
            status == 1 ||
            status?.toString().toLowerCase() == 'true' ||
            status?.toString().toLowerCase() == 'success';

        if (!isSuccess) {
          log(
            'Stage List API Error: '
                '${map['message'] ?? map['Message'] ?? 'Something went wrong'}',
          );

          return [];
        }

        final data = map['data'] ?? map['Data'];

        if (data is! List) {
          log('Stage List Error: Data is not a List');
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

      log(
        'Stage List API failed with status code: '
            '${response.statusCode}',
      );

      return [];
    } on DioException catch (e) {
      log('Stage List Dio Error: ${e.message}');
      log('Stage List Dio Response: ${e.response?.data}');

      return [];
    } catch (e, stackTrace) {
      log(
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
      log('Adding/Updating project phase...');
      log('Stage ID: ${request.stageId}');
      log('Construction Team: ${request.constructionTeam}');
      log('Progress: ${request.progress}');
      log("due date: ${request.dueDate}");
      log('Status: ${request.status}');

      final response = await dio.post(
        ApiEndpoints.addOrUpdatePhase,
        data: request.toJson(),
      );

      log('Add/Update Phase Response: ${response.data}');

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

        log(
          'Add/Update Phase API Error: '
              '${map['message'] ?? map['Message'] ?? 'Something went wrong'}',
        );

        return null;
      }

      log(
        'Add/Update Phase API failed with status code: '
            '${response.statusCode}',
      );

      return null;
    } on DioException catch (e) {
      log('Add/Update Phase Dio Error: ${e.message}');
      log('Add/Update Phase Dio Response: ${e.response?.data}');

      return null;
    } catch (e, stackTrace) {
      log(
        'Add/Update Phase Error: $e',
        stackTrace: stackTrace,
      );

      return null;
    }
  }
  
  Future<List<WorkPhaseListModel>> workPhaseList() async {
    try {
      log('Fetching work phase list...');

      final response = await dio.get(
        ApiEndpoints.workPhaseList,
      );

      log('Work Phase List Response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;

        if (responseData is! Map) {
          log('Work Phase List Error: Response is not a Map');
          return [];
        }

        final map = Map<String, dynamic>.from(responseData);

        final status = map['status'] ?? map['Status'];

        final isSuccess = status == true ||
            status == 1 ||
            status?.toString().toLowerCase() == 'true' ||
            status?.toString().toLowerCase() == 'success';

        if (!isSuccess) {
          log(
            'Work Phase List API Error: '
                '${map['message'] ?? map['Message'] ?? 'Something went wrong'}',
          );
          return [];
        }

        final data = map['data'] ?? map['Data'];

        if (data is! List) {
          log('Work Phase List Error: Data is not a List');
          return [];
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

      log(
        'Work Phase List API failed with status code: '
            '${response.statusCode}',
      );

      return [];
    } on DioException catch (e) {
      log('Work Phase List Dio Error: ${e.message}');
      log('Work Phase List Dio Response: ${e.response?.data}');
      return [];
    } catch (e, stackTrace) {
      log(
        'Work Phase List Error: $e',
        stackTrace: stackTrace,
      );
      return [];
    }
  }
}