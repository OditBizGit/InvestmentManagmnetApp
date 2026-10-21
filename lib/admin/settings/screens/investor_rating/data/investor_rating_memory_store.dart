import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/model/investor_rating_record.dart';

/// In-memory persistence for investor ratings until API integration.
class InvestorRatingMemoryStore {
  InvestorRatingMemoryStore._();

  static List<InvestorRatingRecord>? investors;
  static List<String>? topRatedInvestorCodes;
}
