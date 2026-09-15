import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:maribel_wellness_centre_application/core/utils/media_url.dart';
import 'package:maribel_wellness_centre_application/user/home/model/home_profile_model.dart';

class HomeRepository {
  HomeRepository({
    required LocalStorage localStorage,
  }) : _localStorage = localStorage;

  final LocalStorage _localStorage;

  Future<HomeProfileModel> getHomeProfile() async {
    final fullName = _localStorage.getFullName()?.trim();
    final username = _localStorage.getUsername()?.trim();
    final displayName = (fullName != null && fullName.isNotEmpty)
        ? fullName
        : (username != null && username.isNotEmpty ? username : 'Investor');

    final investorCode = _localStorage.getInvestorCode()?.trim();

    return HomeProfileModel(
      displayName: displayName,
      investorCode:
          (investorCode != null && investorCode.isNotEmpty) ? investorCode : null,
      profileImageUrl: resolveMediaUrl(_localStorage.getProfileImage()),
    );
  }
}
