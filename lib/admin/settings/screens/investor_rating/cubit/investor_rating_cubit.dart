import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/data/dummy_investor_ratings.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/data/investor_rating_memory_store.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/model/investor_rating_record.dart';

part 'investor_rating_state.dart';

class InvestorRatingCubit extends Cubit<InvestorRatingState> {
  InvestorRatingCubit() : super(_initialState()) {
    _bootstrap();
  }

  static InvestorRatingState _initialState() {
    return const InvestorRatingState(
      investors: [],
      draftRatings: {},
      topRatedInvestorCodes: [],
      selectedInvestorCodes: {},
      isLoading: true,
    );
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (isClosed) return;

    final investors = List<InvestorRatingRecord>.from(
      InvestorRatingMemoryStore.investors ?? dummyInvestorRatings,
    );
    final topRated = List<String>.from(
      InvestorRatingMemoryStore.topRatedInvestorCodes ??
          _defaultTopRatedCodes(investors),
    );

    emit(
      state.copyWith(
        investors: investors,
        topRatedInvestorCodes: topRated,
        isLoading: false,
        clearBanner: true,
      ),
    );
  }

  static List<String> _defaultTopRatedCodes(
    List<InvestorRatingRecord> investors,
  ) {
    final rated = investors
        .where((item) => item.adminRating != null)
        .toList()
      ..sort((a, b) => b.adminRating!.compareTo(a.adminRating!));
    return rated
        .take(InvestorRatingState.maxTopRated)
        .map((item) => item.investorCode)
        .toList();
  }

  void setDraftRating(String investorCode, int rating) {
    final clamped = rating.clamp(1, 5);
    final nextDraft = Map<String, int>.from(state.draftRatings)
      ..[investorCode] = clamped;
    emit(
      state.copyWith(
        draftRatings: nextDraft,
        clearBanner: true,
      ),
    );
  }

  void toggleInvestorSelected(String investorCode) {
    final next = Set<String>.from(state.selectedInvestorCodes);
    if (next.contains(investorCode)) {
      next.remove(investorCode);
    } else {
      next.add(investorCode);
    }
    emit(
      state.copyWith(
        selectedInvestorCodes: next,
        clearBanner: true,
      ),
    );
  }

  void clearInvestorSelection(String investorCode) {
    if (!state.selectedInvestorCodes.contains(investorCode)) return;
    final next = Set<String>.from(state.selectedInvestorCodes)
      ..remove(investorCode);
    emit(state.copyWith(selectedInvestorCodes: next));
  }

  String? _validateRatingForTopRated(String investorCode) {
    final rating = state.effectiveRating(investorCode);
    if (rating == null || rating < 1 || rating > 5) {
      return 'Assign a star rating (1–5) before adding to Top Rated.';
    }
    return null;
  }

  void addToTopRated(String investorCode) {
    if (state.isInTopRated(investorCode)) {
      emit(
        state.copyWith(
          bannerMessage: 'This investor is already in Top Rated.',
          bannerIsError: true,
        ),
      );
      return;
    }

    if (state.topRatedFull) {
      emit(
        state.copyWith(
          bannerMessage:
              'Top Rated is full (${InvestorRatingState.maxTopRated}). Remove an investor first.',
          bannerIsError: true,
        ),
      );
      return;
    }

    final ratingError = _validateRatingForTopRated(investorCode);
    if (ratingError != null) {
      emit(
        state.copyWith(
          bannerMessage: ratingError,
          bannerIsError: true,
        ),
      );
      return;
    }

    final nextTop = List<String>.from(state.topRatedInvestorCodes)
      ..add(investorCode);
    emit(
      state.copyWith(
        topRatedInvestorCodes: nextTop,
        bannerMessage: 'Added to Top Rated list (not saved yet).',
        bannerIsError: false,
      ),
    );
  }

  void removeFromTopRated(String investorCode) {
    if (!state.isInTopRated(investorCode)) return;

    final nextTop = List<String>.from(state.topRatedInvestorCodes)
      ..remove(investorCode);
    emit(
      state.copyWith(
        topRatedInvestorCodes: nextTop,
        bannerMessage: 'Removed from Top Rated (rating kept).',
        bannerIsError: false,
      ),
    );
  }

  void saveInvestorRating(String investorCode) {
    final rating = state.effectiveRating(investorCode);
    if (rating == null || rating < 1 || rating > 5) {
      emit(
        state.copyWith(
          bannerMessage: 'Choose a rating between 1 and 5 stars to save.',
          bannerIsError: true,
        ),
      );
      return;
    }

    final updatedInvestors = state.investors.map((investor) {
      if (investor.investorCode != investorCode) return investor;
      return investor.copyWith(adminRating: rating);
    }).toList();

    final nextDraft = Map<String, int>.from(state.draftRatings)
      ..remove(investorCode);

    _persist(updatedInvestors, state.topRatedInvestorCodes);

    emit(
      state.copyWith(
        investors: updatedInvestors,
        draftRatings: nextDraft,
        bannerMessage: 'Rating saved for ${_nameFor(investorCode)}.',
        bannerIsError: false,
      ),
    );
  }

  Future<void> saveAllRatings() async {
    if (state.isSaving) return;

    for (final code in state.topRatedInvestorCodes) {
      final rating = state.effectiveRating(code);
      if (rating == null || rating < 1 || rating > 5) {
        emit(
          state.copyWith(
            bannerMessage:
                'Every Top Rated investor needs a star rating (1–5) before saving.',
            bannerIsError: true,
          ),
        );
        return;
      }
    }

    emit(state.copyWith(isSaving: true, clearBanner: true));

    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (isClosed) return;

    final updatedInvestors = state.investors.map((investor) {
      final draft = state.draftRatings[investor.investorCode];
      if (draft != null) {
        return investor.copyWith(adminRating: draft);
      }
      return investor;
    }).toList();

    final topRated = List<String>.from(state.topRatedInvestorCodes);
    _persist(updatedInvestors, topRated);

    emit(
      state.copyWith(
        investors: updatedInvestors,
        draftRatings: const {},
        topRatedInvestorCodes: topRated,
        isSaving: false,
        bannerMessage: 'Ratings and Top Rated list saved successfully.',
        bannerIsError: false,
      ),
    );
  }

  void dismissBanner() {
    emit(state.copyWith(clearBanner: true));
  }

  void _persist(
    List<InvestorRatingRecord> investors,
    List<String> topRatedCodes,
  ) {
    InvestorRatingMemoryStore.investors =
        List<InvestorRatingRecord>.from(investors);
    InvestorRatingMemoryStore.topRatedInvestorCodes =
        List<String>.from(topRatedCodes);
  }

  String _nameFor(String investorCode) {
    return state.investorByCode(investorCode)?.fullName ?? investorCode;
  }
}
