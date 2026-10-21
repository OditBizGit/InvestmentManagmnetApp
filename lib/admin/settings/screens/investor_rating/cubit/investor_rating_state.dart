part of 'investor_rating_cubit.dart';

@immutable
class InvestorRatingState {
  const InvestorRatingState({
    required this.investors,
    required this.draftRatings,
    required this.topRatedInvestorCodes,
    required this.selectedInvestorCodes,
    this.isLoading = false,
    this.isSaving = false,
    this.bannerMessage,
    this.bannerIsError = false,
  });

  final List<InvestorRatingRecord> investors;
  final Map<String, int> draftRatings;
  final List<String> topRatedInvestorCodes;
  final Set<String> selectedInvestorCodes;
  final bool isLoading;
  final bool isSaving;
  final String? bannerMessage;
  final bool bannerIsError;

  static const int maxTopRated = 5;

  int get topRatedCount => topRatedInvestorCodes.length;

  bool get topRatedFull => topRatedCount >= maxTopRated;

  String get topRatedCounterLabel =>
      '$topRatedCount of $maxTopRated investors selected';

  InvestorRatingState copyWith({
    List<InvestorRatingRecord>? investors,
    Map<String, int>? draftRatings,
    List<String>? topRatedInvestorCodes,
    Set<String>? selectedInvestorCodes,
    bool? isLoading,
    bool? isSaving,
    String? bannerMessage,
    bool? bannerIsError,
    bool clearBanner = false,
  }) {
    return InvestorRatingState(
      investors: investors ?? this.investors,
      draftRatings: draftRatings ?? this.draftRatings,
      topRatedInvestorCodes:
          topRatedInvestorCodes ?? this.topRatedInvestorCodes,
      selectedInvestorCodes:
          selectedInvestorCodes ?? this.selectedInvestorCodes,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      bannerMessage:
          clearBanner ? null : (bannerMessage ?? this.bannerMessage),
      bannerIsError: bannerIsError ?? this.bannerIsError,
    );
  }

  InvestorRatingRecord? investorByCode(String code) {
    for (final investor in investors) {
      if (investor.investorCode == code) return investor;
    }
    return null;
  }

  int? effectiveRating(String investorCode) {
    if (draftRatings.containsKey(investorCode)) {
      return draftRatings[investorCode];
    }
    return investorByCode(investorCode)?.adminRating;
  }

  bool isInTopRated(String investorCode) {
    return topRatedInvestorCodes.contains(investorCode);
  }

  bool hasUnsavedRating(String investorCode) {
    if (!draftRatings.containsKey(investorCode)) return false;
    final saved = investorByCode(investorCode)?.adminRating;
    return draftRatings[investorCode] != saved;
  }

  bool get hasAnyUnsavedRatings {
    for (final code in draftRatings.keys) {
      if (hasUnsavedRating(code)) return true;
    }
    return false;
  }
}
