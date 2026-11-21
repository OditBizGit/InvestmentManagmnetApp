import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/cubit/investor_rating_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/model/add_top_investor_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/model/investor_rating_details_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/model/investor_rating_update_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/model/top_investors_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/repository/investor_rating_repository.dart';

InvestorRatingDetailsModel _investor(String code, int userId, double rating) {
  return InvestorRatingDetailsModel(
    investorName: 'Investor $code',
    investorCode: code,
    totalInvestmentAmount: 1000,
    totalDueCount: 0,
    onTimePaymentCount: 0,
    delayedPaymentCount: 0,
    onTimePaymentPercentage: 0,
    rating: rating,
    userId: userId,
  );
}

class _SavedCall {
  _SavedCall(this.investorId, this.rating);
  final int investorId;
  final double rating;

  @override
  String toString() => '($investorId, $rating)';
}

class _FakeRatingRepository extends InvestorRatingRepository {
  _FakeRatingRepository() : super(Dio());

  List<InvestorRatingDetailsModel> details = [];
  final List<_SavedCall> saveCalls = [];
  final List<List<int>> addTopCalls = [];
  final Set<int> failingUserIds = {};

  /// Runs while a save request is in flight (to simulate edits mid-save).
  void Function(int investorId)? onSaveInFlight;

  @override
  Future<InvestorRatingDetailsResponse> getInvestorRatingDetails() async {
    return InvestorRatingDetailsResponse(
      status: true,
      message: '',
      data: List.of(details),
      code: 200,
    );
  }

  @override
  Future<TopInvestorsResponse> getTopInvestors() async {
    return TopInvestorsResponse(
      status: true,
      message: '',
      data: const [],
      code: 200,
    );
  }

  @override
  Future<InvestorRatingUpdateResponseModel> updateInvestorRating({
    required int investorId,
    required double rating,
  }) async {
    saveCalls.add(_SavedCall(investorId, rating));
    onSaveInFlight?.call(investorId);
    if (failingUserIds.contains(investorId)) {
      return InvestorRatingUpdateResponseModel(
        status: false,
        message: 'boom',
        code: 500,
      );
    }
    return InvestorRatingUpdateResponseModel(
      status: true,
      message: '',
      data: InvestorRatingUpdateData(investorId: investorId, rating: rating),
      code: 200,
    );
  }

  @override
  Future<AddTopInvestorResponseModel> addTopInvestor({
    required List<int> investorIds,
  }) async {
    addTopCalls.add(List.of(investorIds));
    return AddTopInvestorResponseModel(
      status: true,
      message: '',
      code: 200,
    );
  }
}

void main() {
  late _FakeRatingRepository repo;
  late InvestorRatingCubit cubit;

  Map<int, double> sentByUser() => {
        for (final call in repo.saveCalls) call.investorId: call.rating,
      };

  setUp(() {
    repo = _FakeRatingRepository()
      ..details = [
        _investor('A', 11, 3), // backend default 3
        _investor('B', 12, 3), // backend default 3
        _investor('C', 13, 0), // missing rating
        _investor('D', 14, 4), // genuinely saved 4
      ];
    cubit = InvestorRatingCubit(repository: repo);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('open screen: default 3 shown and seeded as pending for 3 / missing',
      () async {
    await cubit.fetchInvestorRatingDetails();
    final s = cubit.state;

    expect(s.effectiveRating('A'), 3.0);
    expect(s.effectiveRating('B'), 3.0);
    expect(s.effectiveRating('C'), 3.0);
    expect(s.effectiveRating('D'), 4.0);

    expect(s.draftRatings.keys.toSet(), {'A', 'B', 'C'});
    expect(s.hasUnsavedRating('A'), isTrue);
    expect(s.hasUnsavedRating('C'), isTrue);
    expect(s.hasUnsavedRating('D'), isFalse);
    expect(s.hasAnyUnsavedRatings, isTrue);
  });

  test('header Save without touching anything sends 3 for each default',
      () async {
    await cubit.fetchInvestorRatingDetails();
    await cubit.saveAllRatings();

    expect(repo.saveCalls.length, 3);
    expect(sentByUser(), {11: 3.0, 12: 3.0, 13: 3.0});
    // Saved 4 is never re-sent.
    expect(repo.saveCalls.any((c) => c.investorId == 14), isFalse);

    final s = cubit.state;
    expect(s.draftRatings, isEmpty);
    expect(s.hasAnyUnsavedRatings, isFalse);
    expect(s.isSaving, isFalse);
    expect(s.savingInvestorCodes, isEmpty);
    expect(s.bannerIsError, isFalse);
    expect(s.bannerMessage, isNotNull);
    expect(repo.addTopCalls, isEmpty);
  });

  test('changing one investor to 5 sends 5 for it and 3 for the others',
      () async {
    await cubit.fetchInvestorRatingDetails();
    cubit.setDraftRating('A', 5);
    await cubit.saveAllRatings();

    expect(sentByUser(), {11: 5.0, 12: 3.0, 13: 3.0});
    expect(cubit.state.effectiveRating('A'), 5.0);
  });

  test('changing another investor to 1 sends 1', () async {
    await cubit.fetchInvestorRatingDetails();
    cubit.setDraftRating('A', 5);
    cubit.setDraftRating('B', 1);
    await cubit.saveAllRatings();

    expect(sentByUser(), {11: 5.0, 12: 1.0, 13: 3.0});
    expect(cubit.state.effectiveRating('B'), 1.0);
  });

  test('refresh after saving shows the saved values', () async {
    await cubit.fetchInvestorRatingDetails();
    cubit.setDraftRating('A', 5);
    cubit.setDraftRating('B', 1);
    await cubit.saveAllRatings();

    // Backend now reports what was saved.
    repo.details = [
      _investor('A', 11, 5),
      _investor('B', 12, 1),
      _investor('C', 13, 3),
      _investor('D', 14, 4),
    ];
    await cubit.fetchInvestorRatingDetails();
    final s = cubit.state;

    expect(s.effectiveRating('A'), 5.0);
    expect(s.effectiveRating('B'), 1.0);
    expect(s.effectiveRating('C'), 3.0);
    expect(s.effectiveRating('D'), 4.0);
    // Only the (indistinguishable) default-3 investor is pending again.
    expect(s.draftRatings.keys.toSet(), {'C'});
  });

  test('failed save keeps the draft and the rest are still sent', () async {
    repo.failingUserIds.add(11);
    await cubit.fetchInvestorRatingDetails();
    await cubit.saveAllRatings();

    expect(repo.saveCalls.length, 3);
    final s = cubit.state;
    expect(s.draftRatings.keys.toSet(), {'A'});
    expect(s.hasUnsavedRating('A'), isTrue);
    expect(s.hasUnsavedRating('B'), isFalse);
    expect(s.savingInvestorCodes, isEmpty);
    expect(s.isSaving, isFalse);
    expect(s.bannerIsError, isTrue);
  });

  test('row-level save of an untouched default sends 3', () async {
    await cubit.fetchInvestorRatingDetails();
    await cubit.saveInvestorRating('A');

    expect(sentByUser(), {11: 3.0});
    expect(cubit.state.hasUnsavedRating('A'), isFalse);
    expect(cubit.state.hasUnsavedRating('B'), isTrue);
  });

  test('row-level save after a change still sends the new value', () async {
    await cubit.fetchInvestorRatingDetails();
    cubit.setDraftRating('B', 2.5);
    await cubit.saveInvestorRating('B');

    expect(sentByUser(), {12: 2.5});
  });

  test('header Save with a Top Rated selection saves ratings first, then adds',
      () async {
    await cubit.fetchInvestorRatingDetails();
    cubit.toggleInvestorSelected('A');
    cubit.setDraftRating('A', 4.5);
    await cubit.saveAllRatings();

    expect(sentByUser()[11], 4.5);
    expect(repo.addTopCalls, [
      [11],
    ]);
    expect(cubit.state.selectedInvestorCodes, isEmpty);
  });

  test('Top Rated add is blocked for an investor whose rating save failed',
      () async {
    repo.failingUserIds.add(11);
    await cubit.fetchInvestorRatingDetails();
    cubit.toggleInvestorSelected('A');
    await cubit.saveAllRatings();

    expect(repo.addTopCalls, isEmpty);
    expect(cubit.state.bannerIsError, isTrue);
    expect(cubit.state.hasUnsavedRating('A'), isTrue);
  });

  test('nothing pending and nothing selected keeps the select banner',
      () async {
    repo.details = [_investor('D', 14, 4)];
    await cubit.fetchInvestorRatingDetails();
    await cubit.saveAllRatings();

    expect(repo.saveCalls, isEmpty);
    expect(cubit.state.bannerIsError, isTrue);
    expect(cubit.state.bannerMessage, contains('Select investors'));
  });

  test(
      'failed rating save stays visible when the Top Rated add of another '
      'investor succeeds', () async {
    repo.failingUserIds.add(11); // A fails, not selected
    await cubit.fetchInvestorRatingDetails();
    cubit.toggleInvestorSelected('B');
    await cubit.saveAllRatings();

    expect(repo.addTopCalls, [
      [12],
    ]);
    expect(cubit.state.bannerIsError, isTrue);
    expect(cubit.state.bannerMessage, contains('could not be saved'));
    expect(cubit.state.hasUnsavedRating('A'), isTrue);
    expect(cubit.state.isSaving, isFalse);
  });

  test('edits are ignored while the header Save is running', () async {
    await cubit.fetchInvestorRatingDetails();
    repo.onSaveInFlight = (investorId) {
      if (investorId == 11) cubit.setDraftRating('B', 1);
    };
    await cubit.saveAllRatings();

    expect(sentByUser(), {11: 3.0, 12: 3.0, 13: 3.0});
  });

  test('editing works normally when not saving', () async {
    await cubit.fetchInvestorRatingDetails();
    cubit.setDraftRating('B', 1);
    expect(cubit.state.effectiveRating('B'), 1.0);
    await cubit.saveInvestorRating('B');
    expect(sentByUser(), {12: 1.0});
  });
}
