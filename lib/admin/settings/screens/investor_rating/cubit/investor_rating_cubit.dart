import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/model/investor_rating_details_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/model/top_investors_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/repository/investor_rating_repository.dart';

part 'investor_rating_state.dart';

class InvestorRatingCubit extends Cubit<InvestorRatingState> {
  InvestorRatingCubit({
    required this._repository,
  }) : super(_initialState());

  final InvestorRatingRepository _repository;

  static InvestorRatingState _initialState() {
    return const InvestorRatingState(
      investors: [],
      topInvestors: [],
      draftRatings: {},
      selectedInvestorCodes: {},
      savingInvestorCodes: {},
      removingTopInvestorUserIds: {},
      isLoading: false,
    );
  }

  Future<void> fetchInvestorRatingDetails() async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        isLoading: true,
        clearLoadError: true,
        clearBanner: true,
      ),
    );

    try {
      final response = await _repository.getInvestorRatingDetails();
      if (isClosed) return;

      if (!response.status) {
        emit(
          state.copyWith(
            isLoading: false,
            loadError: response.message.isNotEmpty
                ? response.message
                : 'Failed to load investor rating details',
          ),
        );
        return;
      }

      final investors = List<InvestorRatingDetailsModel>.from(response.data);

      emit(
        state.copyWith(
          investors: investors,
          draftRatings: const {},
          selectedInvestorCodes: const {},
          savingInvestorCodes: const {},
          removingTopInvestorUserIds: const {},
          isLoading: false,
          clearLoadError: true,
          clearBanner: true,
        ),
      );

      await fetchTopInvestors(silent: true);
    } on DioException catch (e) {
      if (isClosed) return;
      final message = _dioErrorMessage(e);
      emit(
        state.copyWith(
          isLoading: false,
          loadError: message.isNotEmpty
              ? message
              : 'Failed to load investor rating details',
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoading: false,
          loadError: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> fetchTopInvestors({bool silent = false}) async {
    if (state.isLoadingTopInvestors) return;

    if (!silent) {
      emit(
        state.copyWith(
          isLoadingTopInvestors: true,
          clearBanner: true,
        ),
      );
    }

    try {
      final response = await _repository.getTopInvestors();
      if (isClosed) return;

      if (!response.status) {
        if (!silent) {
          emit(
            state.copyWith(
              isLoadingTopInvestors: false,
              bannerMessage: response.message.isNotEmpty
                  ? response.message
                  : 'Failed to load top investors',
              bannerIsError: true,
            ),
          );
        }
        return;
      }

      emit(
        state.copyWith(
          topInvestors: response.data,
          isLoadingTopInvestors: false,
          selectedInvestorCodes: _selectionExcludingTops(
            state.selectedInvestorCodes,
            response.data,
          ),
        ),
      );
    } on DioException catch (e) {
      if (isClosed) return;
      if (!silent) {
        final message = _dioErrorMessage(e);
        emit(
          state.copyWith(
            isLoadingTopInvestors: false,
            bannerMessage: message.isNotEmpty
                ? message
                : 'Failed to load top investors',
            bannerIsError: true,
          ),
        );
      }
    } catch (e) {
      if (isClosed) return;
      if (!silent) {
        emit(
          state.copyWith(
            isLoadingTopInvestors: false,
            bannerMessage: e.toString().replaceFirst('Exception: ', ''),
            bannerIsError: true,
          ),
        );
      }
    }
  }

  Future<void> removeTopInvestor(int userId) async {
    if (userId <= 0) return;
    if (state.isRemovingTopInvestor(userId)) return;
    if (state.isSaving) return;

    TopInvestorModel? topInvestor;
    for (final investor in state.topInvestors) {
      if (investor.userId == userId) {
        topInvestor = investor;
        break;
      }
    }

    if (topInvestor == null) {
      emit(
        state.copyWith(
          bannerMessage: 'This investor is not in Top Rated.',
          bannerIsError: true,
        ),
      );
      return;
    }

    final name = topInvestor.fullName.trim().isNotEmpty
        ? topInvestor.fullName.trim()
        : 'Investor';

    final removing = Set<int>.from(state.removingTopInvestorUserIds)
      ..add(userId);
    emit(
      state.copyWith(
        removingTopInvestorUserIds: removing,
        clearBanner: true,
      ),
    );

    try {
      final response = await _repository.removeTopInvestor(
        investorIds: [userId],
      );
      if (isClosed) return;

      if (!response.status) {
        _clearRemovingTopInvestor(userId);
        emit(
          state.copyWith(
            bannerMessage: response.message.isNotEmpty
                ? response.message
                : 'Failed to remove $name from Top Rated.',
            bannerIsError: true,
          ),
        );
        return;
      }

      _clearRemovingTopInvestor(userId);
      emit(
        state.copyWith(
          bannerMessage: response.message.isNotEmpty
              ? response.message
              : '$name removed from Top Rated.',
          bannerIsError: false,
        ),
      );

      await fetchTopInvestors(silent: true);
    } on DioException catch (e) {
      if (isClosed) return;
      _clearRemovingTopInvestor(userId);
      final message = _dioErrorMessage(e);
      emit(
        state.copyWith(
          bannerMessage: message.isNotEmpty
              ? message
              : 'Failed to remove $name from Top Rated.',
          bannerIsError: true,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      _clearRemovingTopInvestor(userId);
      emit(
        state.copyWith(
          bannerMessage: e.toString().replaceFirst('Exception: ', ''),
          bannerIsError: true,
        ),
      );
    }
  }

  Future<void> saveAllRatings() async {
    if (state.isSaving) return;
    if (state.isRemovingTopInvestorAny) return;

    if (state.selectedInvestorCodes.isEmpty) {
      emit(
        state.copyWith(
          bannerMessage:
              'Select investors using the checkboxes to add as Top Rated.',
          bannerIsError: true,
        ),
      );
      return;
    }

    final newSelectionCodes = state.selectedInvestorCodes
        .where((code) => !state.isInTopRated(code))
        .toList();

    if (newSelectionCodes.isEmpty) {
      emit(
        state.copyWith(
          bannerMessage: 'Selected investors are already in Top Rated.',
          bannerIsError: true,
        ),
      );
      return;
    }

    if (state.topInvestors.length + newSelectionCodes.length >
        InvestorRatingState.maxTopRated) {
      emit(
        state.copyWith(
          bannerMessage:
              'You can only have ${InvestorRatingState.maxTopRated} Top Rated investors. '
              'Remove some selections or clear existing top investors first.',
          bannerIsError: true,
        ),
      );
      return;
    }

    for (final code in newSelectionCodes) {
      if (state.hasUnsavedRating(code)) {
        emit(
          state.copyWith(
            bannerMessage:
                'Save star ratings before adding ${_nameFor(code)} to Top Rated.',
            bannerIsError: true,
          ),
        );
        return;
      }

      final rating = state.effectiveRating(code);
      if (rating == null || rating < 1 || rating > 5) {
        emit(
          state.copyWith(
            bannerMessage:
                'Assign and save a star rating (1–5) for ${_nameFor(code)} first.',
            bannerIsError: true,
          ),
        );
        return;
      }
    }

    final newIds = <int>[];
    for (final code in newSelectionCodes) {
      final investor = state.investorByCode(code);
      if (investor == null) continue;
      if (_topInvestorUserIds.contains(investor.userId)) continue;
      newIds.add(investor.userId);
    }

    if (newIds.isEmpty) {
      emit(
        state.copyWith(
          bannerMessage: 'Selected investors are already in Top Rated.',
          bannerIsError: true,
        ),
      );
      return;
    }

    final investorIds = newIds;

    emit(
      state.copyWith(
        isSaving: true,
        clearBanner: true,
      ),
    );

    try {
      final response = await _repository.addTopInvestor(
        investorIds: investorIds,
      );
      if (isClosed) return;

      if (!response.status) {
        emit(
          state.copyWith(
            isSaving: false,
            bannerMessage: response.message.isNotEmpty
                ? response.message
                : 'Failed to add top investors',
            bannerIsError: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          isSaving: false,
          selectedInvestorCodes: const {},
          bannerMessage: response.message.isNotEmpty
              ? response.message
              : 'Top investors updated successfully.',
          bannerIsError: false,
        ),
      );

      await fetchTopInvestors(silent: true);
    } on DioException catch (e) {
      if (isClosed) return;
      final message = _dioErrorMessage(e);
      emit(
        state.copyWith(
          isSaving: false,
          bannerMessage: message.isNotEmpty
              ? message
              : 'Failed to add top investors',
          bannerIsError: true,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isSaving: false,
          bannerMessage: e.toString().replaceFirst('Exception: ', ''),
          bannerIsError: true,
        ),
      );
    }
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
    if (state.isInTopRated(investorCode)) return;

    final next = Set<String>.from(state.selectedInvestorCodes);
    if (next.contains(investorCode)) {
      next.remove(investorCode);
    } else {
      if (state.topInvestors.length + next.length >=
          InvestorRatingState.maxTopRated) {
        emit(
          state.copyWith(
            bannerMessage:
                'Top Rated is limited to ${InvestorRatingState.maxTopRated} investors.',
            bannerIsError: true,
          ),
        );
        return;
      }
      next.add(investorCode);
    }
    emit(
      state.copyWith(
        selectedInvestorCodes: next,
        clearBanner: true,
      ),
    );
  }

  Future<void> saveInvestorRating(String investorCode) async {
    final investor = state.investorByCode(investorCode);
    if (investor == null) return;

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

    if (state.isSavingInvestor(investorCode)) return;

    final refreshTopInvestors = state.isInTopRated(investorCode);

    final saving = Set<String>.from(state.savingInvestorCodes)
      ..add(investorCode);
    emit(
      state.copyWith(
        savingInvestorCodes: saving,
        clearBanner: true,
      ),
    );

    try {
      final response = await _repository.updateInvestorRating(
        investorId: investor.userId,
        rating: rating,
      );
      if (isClosed) return;

      if (!response.status) {
        _clearSavingInvestor(investorCode);
        emit(
          state.copyWith(
            bannerMessage: response.message.isNotEmpty
                ? response.message
                : 'Failed to save rating for ${_nameFor(investorCode)}.',
            bannerIsError: true,
          ),
        );
        return;
      }

      final savedRating = response.data?.rating ?? rating;
      _applySavedRating(investorCode, savedRating);
      _clearSavingInvestor(investorCode);

      emit(
        state.copyWith(
          bannerMessage: response.message.isNotEmpty
              ? response.message
              : 'Rating saved for ${_nameFor(investorCode)}.',
          bannerIsError: false,
        ),
      );

      if (refreshTopInvestors) {
        await fetchTopInvestors(silent: true);
      }
    } on DioException catch (e) {
      if (isClosed) return;
      _clearSavingInvestor(investorCode);
      final message = _dioErrorMessage(e);
      emit(
        state.copyWith(
          bannerMessage: message.isNotEmpty
              ? message
              : 'Failed to save rating for ${_nameFor(investorCode)}.',
          bannerIsError: true,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      _clearSavingInvestor(investorCode);
      emit(
        state.copyWith(
          bannerMessage: e.toString().replaceFirst('Exception: ', ''),
          bannerIsError: true,
        ),
      );
    }
  }

  void dismissBanner() {
    emit(state.copyWith(clearBanner: true));
  }

  void _applySavedRating(String investorCode, int savedRating) {
    final updatedInvestors = state.investors.map((investor) {
      if (investor.investorCode != investorCode) return investor;
      return investor.copyWith(rating: savedRating);
    }).toList();

    final nextDraft = Map<String, int>.from(state.draftRatings)
      ..remove(investorCode);

    emit(
      state.copyWith(
        investors: updatedInvestors,
        draftRatings: nextDraft,
      ),
    );
  }

  void _clearSavingInvestor(String investorCode) {
    if (!state.savingInvestorCodes.contains(investorCode)) return;
    final saving = Set<String>.from(state.savingInvestorCodes)
      ..remove(investorCode);
    emit(state.copyWith(savingInvestorCodes: saving));
  }

  void _clearRemovingTopInvestor(int userId) {
    if (!state.removingTopInvestorUserIds.contains(userId)) return;
    final removing = Set<int>.from(state.removingTopInvestorUserIds)
      ..remove(userId);
    emit(state.copyWith(removingTopInvestorUserIds: removing));
  }

  String _dioErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final message = data['message'] ?? data['Message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    return e.message ?? '';
  }

  String _nameFor(String investorCode) {
    return state.investorByCode(investorCode)?.investorName ?? investorCode;
  }

  Set<int> get _topInvestorUserIds =>
      state.topInvestors.map((investor) => investor.userId).toSet();

  Set<String> _selectionExcludingTops(
    Set<String> codes,
    List<TopInvestorModel> tops,
  ) {
    return codes.where((code) {
      final details = state.investorByCode(code);
      for (final top in tops) {
        if (top.investorCode == code) return false;
        if (details != null && top.userId == details.userId) return false;
      }
      return true;
    }).toSet();
  }
}
