import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:maribel_wellness_centre_application/core/utils/media_url.dart';
import 'package:maribel_wellness_centre_application/user/home/model/home_profile_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/repository/profile_repository.dart';

class HomeRepository {
  HomeRepository({
    required LocalStorage localStorage,
    required ProfileRepository profileRepository,
  })  : _localStorage = localStorage,
        _profileRepository = profileRepository;

  final LocalStorage _localStorage;
  final ProfileRepository _profileRepository;

  Future<HomeProfileModel> getHomeProfile() async {
    final localProfile = _profileFromLocalStorage();

    final userId = _localStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      return localProfile;
    }

    final response = await _profileRepository.getInvestorDetails(userId);
    final details = response.data;
    if (details == null) {
      return localProfile;
    }

    final fullName = details.fullName.trim();
    final username = details.username.trim();
    final displayName = fullName.isNotEmpty
        ? fullName
        : (username.isNotEmpty ? username : localProfile.displayName);

    final investorCode = details.investorCode?.trim();

    return HomeProfileModel(
      displayName: displayName,
      investorCode: (investorCode != null && investorCode.isNotEmpty)
          ? investorCode
          : localProfile.investorCode,
      profileImageUrl:
          details.profileImageUrl ?? localProfile.profileImageUrl,
      totalCollection: details.totalPaidAmount,
      totalCommitment: details.investmentAmount,
    );
  }

  HomeProfileModel _profileFromLocalStorage() {
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
