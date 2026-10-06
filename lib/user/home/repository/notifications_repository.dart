import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';
import 'package:maribel_wellness_centre_application/user/home/model/app_notification_model.dart';
import 'package:maribel_wellness_centre_application/user/home/model/notifications_response_model.dart';

class NotificationsRepository {
  NotificationsRepository({required this.dio});

  final Dio dio;

  Future<RegisterDeviceResponseModel> registerDevice({
    required String deviceToken,
    required String platform,
  }) async {
    try {
      final request = RegisterDeviceRequestModel(
        deviceToken: deviceToken,
        platform: platform,
      );
      final response = await dio.post(
        ApiEndpoints.registerDevice,
        data: request.toJson(),
      );

      return RegisterDeviceResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      log('Register Device Error: ${e.message}');
      log('Register Device Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      log('Register Device Error: $e');
      rethrow;
    }
  }

  Future<List<AppNotificationModel>> getMyNotifications() async {
    try {
      final response = await dio.get(ApiEndpoints.getMyNotifications);
      final parsed = NotificationsResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      final looksSuccessful = parsed.status ||
          parsed.code == 200 ||
          parsed.message.toLowerCase().contains('success');

      if (!looksSuccessful && parsed.data.isEmpty) {
        throw Exception(
          parsed.message.isNotEmpty
              ? parsed.message
              : 'Failed to load notifications',
        );
      }

      return parsed.data;
    } on DioException catch (e) {
      log('Get My Notifications Error: ${e.message}');
      log('Get My Notifications Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      log('Get My Notifications Error: $e');
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await dio.get(ApiEndpoints.getUnreadCount);
      final parsed = UnreadCountResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      final looksSuccessful = parsed.status ||
          parsed.code == 200 ||
          parsed.message.toLowerCase().contains('success');

      if (!looksSuccessful) {
        throw Exception(
          parsed.message.isNotEmpty
              ? parsed.message
              : 'Failed to load unread count',
        );
      }

      return parsed.data < 0 ? 0 : parsed.data;
    } on DioException catch (e) {
      log('Get Unread Count Error: ${e.message}');
      log('Get Unread Count Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      log('Get Unread Count Error: $e');
      rethrow;
    }
  }

  Future<bool> markAsRead({required int notificationId}) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.markAsRead}$notificationId',
      );
      final parsed = MarkAsReadResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      final looksSuccessful = parsed.status ||
          parsed.code == 200 ||
          parsed.data ||
          parsed.message.toLowerCase().contains('success');

      if (!looksSuccessful) {
        throw Exception(
          parsed.message.isNotEmpty
              ? parsed.message
              : 'Failed to mark notification as read',
        );
      }

      return true;
    } on DioException catch (e) {
      log('Mark As Read Error: ${e.message}');
      log('Mark As Read Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      log('Mark As Read Error: $e');
      rethrow;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await dio.post(ApiEndpoints.markAllAsRead);
      final parsed = MarkAsReadResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      final looksSuccessful = parsed.status ||
          parsed.code == 200 ||
          parsed.data ||
          parsed.message.toLowerCase().contains('success');

      if (!looksSuccessful) {
        throw Exception(
          parsed.message.isNotEmpty
              ? parsed.message
              : 'Failed to mark all notifications as read',
        );
      }

      return true;
    } on DioException catch (e) {
      log('Mark All As Read Error: ${e.message}');
      log('Mark All As Read Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      log('Mark All As Read Error: $e');
      rethrow;
    }
  }
}
