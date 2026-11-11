part of 'investor_rating_cubit.dart';

@immutable
class InvestorRatingState {
  const InvestorRatingState({
    required this.investors,
    required this.topInvestors,
    required this.draftRatings,
    required this.selectedInvestorCodes,
    required this.savingInvestorCodes,
    required this.removingTopInvestorUserIds,
    this.topInvestorAddingEnabled,
    this.isLoading = false,
    this.isSaving = false,
    this.isLoadingTopInvestors = false,
    this.isUpdatingTopInvestorButton = false,
    this.isLoadingTopInvestorButton = false,
    this.loadError,
    this.bannerMessage,
    this.bannerIsError = false,
  });

  final List<InvestorRatingDetailsModel> investors;
  final List<TopInvestorModel> topInvestors;
  final Map<String, double> draftRatings;
  final Set<String> selectedInvestorCodes;
  final Set<String> savingInvestorCodes;
  final Set<int> removingTopInvestorUserIds;
  /// Saved "Investor adding" visibility from the backend; `null` until the
  /// `GetAllSettings` response has been received (no assumed default).
  final bool? topInvestorAddingEnabled;
  final bool isLoading;
  final bool isSaving;
  final bool isLoadingTopInvestors;
  final bool isUpdatingTopInvestorButton;
  final bool isLoadingTopInvestorButton;
  final String? loadError;
  final String? bannerMessage;
  final bool bannerIsError;

  static const int maxTopRated = 5;

  int get topRatedCount => topInvestors.length;

  bool get topRatedFull => topRatedCount >= maxTopRated;

  String get topRatedCounterLabel =>
      '$topRatedCount of $maxTopRated investors on dashboard';

  InvestorRatingState copyWith({
    List<InvestorRatingDetailsModel>? investors,
    List<TopInvestorModel>? topInvestors,
    Map<String, double>? draftRatings,
    Set<String>? selectedInvestorCodes,
    Set<String>? savingInvestorCodes,
    Set<int>? removingTopInvestorUserIds,
    bool? topInvestorAddingEnabled,
    bool? isLoading,
    bool? isSaving,
    bool? isLoadingTopInvestors,
    bool? isUpdatingTopInvestorButton,
    bool? isLoadingTopInvestorButton,
    String? loadError,
    String? bannerMessage,
    bool? bannerIsError,
    bool clearBanner = false,
    bool clearLoadError = false,
  }) {
    return InvestorRatingState(
      investors: investors ?? this.investors,
      topInvestors: topInvestors ?? this.topInvestors,
      draftRatings: draftRatings ?? this.draftRatings,
      selectedInvestorCodes:
          selectedInvestorCodes ?? this.selectedInvestorCodes,
      savingInvestorCodes: savingInvestorCodes ?? this.savingInvestorCodes,
      removingTopInvestorUserIds:
          removingTopInvestorUserIds ?? this.removingTopInvestorUserIds,
      topInvestorAddingEnabled:
          topInvestorAddingEnabled ?? this.topInvestorAddingEnabled,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isLoadingTopInvestors:
          isLoadingTopInvestors ?? this.isLoadingTopInvestors,
      isUpdatingTopInvestorButton: isUpdatingTopInvestorButton ??
          this.isUpdatingTopInvestorButton,
      isLoadingTopInvestorButton:
          isLoadingTopInvestorButton ?? this.isLoadingTopInvestorButton,
      loadError: clearLoadError ? null : (loadError ?? this.loadError),
      bannerMessage:
          clearBanner ? null : (bannerMessage ?? this.bannerMessage),
      bannerIsError: bannerIsError ?? this.bannerIsError,
    );
  }

  InvestorRatingDetailsModel? investorByCode(String code) {
    for (final investor in investors) {
      if (investor.investorCode == code) return investor;
    }
    return null;
  }

  double? effectiveRating(String investorCode) {
    if (draftRatings.containsKey(investorCode)) {
      return draftRatings[investorCode];
    }
    return investorByCode(investorCode)?.savedStarRating;
  }

  bool isInTopRated(String investorCode) {
    final details = investorByCode(investorCode);
    for (final investor in topInvestors) {
      if (investor.investorCode == investorCode) return true;
      if (details != null && investor.userId == details.userId) return true;
    }
    return false;
  }

  bool isSavingInvestor(String investorCode) {
    return savingInvestorCodes.contains(investorCode);
  }

  bool isRemovingTopInvestor(int userId) {
    return removingTopInvestorUserIds.contains(userId);
  }

  bool get isRemovingTopInvestorAny => removingTopInvestorUserIds.isNotEmpty;

  bool hasUnsavedRating(String investorCode) {
    if (!draftRatings.containsKey(investorCode)) return false;
    final saved = investorByCode(investorCode)?.savedStarRating;
    return draftRatings[investorCode] != saved;
  }

  bool get hasAnyUnsavedRatings {
    for (final code in draftRatings.keys) {
      if (hasUnsavedRating(code)) return true;
    }
    return false;
  }
}
