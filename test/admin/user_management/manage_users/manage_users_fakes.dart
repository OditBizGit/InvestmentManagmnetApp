import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/model/managed_user_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/block_user_request_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/manage_users_response_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/pdf_excel_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/review_block_request_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/repository/manage_users_repository.dart';

/// Dio adapter that answers from a callback and records every request.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.onRequest);

  Future<ResponseBody> Function(RequestOptions options) onRequest;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return onRequest(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(Object body, {int status = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Dio dioWith(FakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
  dio.httpClientAdapter = adapter;
  return dio;
}

Map<String, dynamic> investorJson(int id, {bool isActive = true}) => {
  'userId': id,
  'userName': 'user$id',
  'fullName': 'Investor $id',
  'email': 'user$id@test.local',
  'phoneNumber': '90000000$id',
  'totalInvestmentAmount': 1000,
  'totalPaidAmount': 400,
  'totalPendingAmount': 600,
  'isActive': isActive,
  'createdDate': '2024-03-01T00:00:00',
};

Map<String, dynamic> listEnvelope(List<Map<String, dynamic>> rows) => {
  'status': true,
  'message': 'Success',
  'code': 200,
  'data': rows,
};

ManageUsersResponse usersResponse(List<ManageUsersInvestor> users) {
  return ManageUsersResponse(
    status: true,
    message: 'Success',
    users: users,
    total: const ManageUsersTotals(),
    code: 200,
    skippedCount: 0,
  );
}

ManageUsersInvestor investor(int id, {bool isActive = true}) {
  return ManageUsersInvestor.fromJson(investorJson(id, isActive: isActive));
}

/// Repository whose `getInvestors` is answered by a callback per filter.
class FakeManageUsersRepository extends ManageUsersRepository {
  FakeManageUsersRepository(this.onGetInvestors) : super(dio: Dio());

  Future<ManageUsersResponse> Function(ManageUsersStatusFilter filter)
  onGetInvestors;
  final List<ManageUsersStatusFilter> calls = [];
  bool blockUserCalled = false;

  @override
  Future<ManageUsersResponse> getInvestors({
    required ManageUsersStatusFilter filter,
  }) {
    calls.add(filter);
    return onGetInvestors(filter);
  }

  /// Optional gates so a test can keep a call in flight.
  Future<BlockUserResponseModel> Function()? onBlockUser;
  Future<PdfExcelResponseModel> Function()? onGetPdfExcel;
  Future<ReviewBlockRequestResponse> Function(int requestId)? onReview;

  @override
  Future<BlockUserResponseModel> blockUser({
    required int userId,
    required bool isActive,
    String? remarks,
  }) async {
    blockUserCalled = true;
    if (onBlockUser != null) return onBlockUser!();
    return const BlockUserResponseModel(
      status: true,
      message: 'Done',
      code: 200,
    );
  }

  @override
  Future<PdfExcelResponseModel> getPdfExcel(PdfExcelRequestModel request) {
    return onGetPdfExcel!();
  }

  @override
  Future<ReviewBlockRequestResponse> reviewBlockRequest({
    required int requestId,
    required String status,
    String remarks = '',
  }) {
    return onReview!(requestId);
  }
}
