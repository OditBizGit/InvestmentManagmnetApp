import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists auth token and session/user data via [SharedPreferences].
///
/// Auth and refresh tokens live in [FlutterSecureStorage] on mobile/desktop
/// and in [SharedPreferences] on web. They are mirrored in memory so the
/// getters stay synchronous.
class LocalStorage {
  LocalStorage._(this._prefs, this._secure);

  final SharedPreferences _prefs;
  final FlutterSecureStorage? _secure;

  String? _authToken;
  String? _refreshToken;

  /// Initializes storage, migrates legacy plaintext tokens and returns a
  /// ready [LocalStorage].
  ///
  /// [secureStorage] lets tests inject a fake; ignored on web.
  static Future<LocalStorage> init({FlutterSecureStorage? secureStorage}) async {
    final prefs = await SharedPreferences.getInstance();
    final secure =
        kIsWeb ? null : (secureStorage ?? const FlutterSecureStorage());
    final storage = LocalStorage._(prefs, secure);
    await storage._loadTokens();
    return storage;
  }

  Future<void> _loadTokens() async {
    _authToken = await _readToken(_authTokenKey);
    _refreshToken = await _readToken(_refreshTokenKey);
  }

  /// Reads a token; on secure platforms moves a legacy prefs token into
  /// secure storage and deletes the prefs copy.
  Future<String?> _readToken(String key) async {
    final secure = _secure;
    if (secure == null) return _prefs.getString(key);
    String? value;
    try {
      value = await secure.read(key: key);
      final legacy = _prefs.getString(key);
      if (legacy != null) {
        if (value == null && legacy.isNotEmpty) {
          await secure.write(key: key, value: legacy);
          value = legacy;
        }
        await _prefs.remove(key);
      }
    } catch (e) {
      // Keystore unavailable: fall back to no token (user logs in again).
      if (kDebugMode) debugPrint('Secure storage read failed for $key: $e');
    }
    return value;
  }

  Future<bool> _writeToken(String key, String token) async {
    final secure = _secure;
    if (secure == null) return _prefs.setString(key, token);
    try {
      await secure.write(key: key, value: token);
      await _prefs.remove(key);
      return true;
    } catch (e) {
      // Keystore failure: keep the token in memory (already set by caller)
      // so login does not throw; it will not survive an app restart.
      if (kDebugMode) debugPrint('Secure storage write failed for $key: $e');
      return false;
    }
  }

  Future<bool> _deleteToken(String key) async {
    final secure = _secure;
    if (secure == null) return _prefs.remove(key);
    try {
      await secure.delete(key: key);
    } catch (e) {
      if (kDebugMode) debugPrint('Secure storage delete failed for $key: $e');
    }
    return _prefs.remove(key);
  }

  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _fullNameKey = 'full_name';
  static const String _userRoleKey = 'user_role';
  static const String _userEmailKey = 'user_email';
  static const String _investorCodeKey = 'investor_code';
  static const String _profileImageKey = 'profile_image';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _isActiveKey = 'is_active';
  static const String _fundingTransactionHistoryKey =
      'funding_transaction_history';
  static const String _fundingInvestorsListKey = 'funding_investors_list_v2';

  // ── Auth token ────────────────────────────────────────────────────

  Future<bool> setAuthToken(String token) async {
    _authToken = token;
    return _writeToken(_authTokenKey, token);
  }

  String? getAuthToken() => _authToken;

  Future<bool> clearAuthToken() {
    _authToken = null;
    return _deleteToken(_authTokenKey);
  }

  // ── Refresh token ─────────────────────────────────────────────────

  Future<bool> setRefreshToken(String token) async {
    _refreshToken = token;
    return _writeToken(_refreshTokenKey, token);
  }

  String? getRefreshToken() => _refreshToken;

  // ── User / session ────────────────────────────────────────────────

  Future<bool> setUserId(String userId) =>
      _prefs.setString(_userIdKey, userId);

  String? getUserId() => _prefs.getString(_userIdKey);

  Future<bool> setUsername(String username) =>
      _prefs.setString(_usernameKey, username);

  String? getUsername() => _prefs.getString(_usernameKey);

  Future<bool> setFullName(String fullName) =>
      _prefs.setString(_fullNameKey, fullName);

  String? getFullName() => _prefs.getString(_fullNameKey);

  Future<bool> setUserRole(String role) =>
      _prefs.setString(_userRoleKey, role);

  String? getUserRole() => _prefs.getString(_userRoleKey);

  Future<bool> setUserEmail(String email) =>
      _prefs.setString(_userEmailKey, email);

  String? getUserEmail() => _prefs.getString(_userEmailKey);

  Future<bool> setInvestorCode(String investorCode) =>
      _prefs.setString(_investorCodeKey, investorCode);

  String? getInvestorCode() => _prefs.getString(_investorCodeKey);

  Future<bool> setProfileImage(String profileImage) =>
      _prefs.setString(_profileImageKey, profileImage);

  String? getProfileImage() => _prefs.getString(_profileImageKey);

  Future<bool> setIsLoggedIn(bool value) =>
      _prefs.setBool(_isLoggedInKey, value);

  bool getIsLoggedIn() => _prefs.getBool(_isLoggedInKey) ?? false;

  Future<bool> setIsActive(bool value) =>
      _prefs.setBool(_isActiveKey, value);

  /// Returns the persisted account-active flag.
  ///
  /// Defaults to `true` when the key is missing so older sessions are not
  /// treated as blocked until an API response confirms otherwise.
  bool getIsActive() => _prefs.getBool(_isActiveKey) ?? true;

  /// `null` when [isActive] has never been written for this session.
  bool? getIsActiveOrNull() =>
      _prefs.containsKey(_isActiveKey) ? _prefs.getBool(_isActiveKey) : null;

  // ── Funding / payments cache ──────────────────────────────────────

  Future<bool> setFundingTransactionHistoryJson(String json) =>
      _prefs.setString(_fundingTransactionHistoryKey, json);

  String? getFundingTransactionHistoryJson() =>
      _prefs.getString(_fundingTransactionHistoryKey);

  Future<bool> clearFundingTransactionHistory() =>
      _prefs.remove(_fundingTransactionHistoryKey);

  Future<bool> setFundingInvestorsListJson(String json) =>
      _prefs.setString(_fundingInvestorsListKey, json);

  String? getFundingInvestorsListJson() =>
      _prefs.getString(_fundingInvestorsListKey);

  Future<bool> clearFundingInvestorsList() =>
      _prefs.remove(_fundingInvestorsListKey);

  /// True when a non-empty auth token is saved (survives app restart).
  bool hasValidSession() {
    final token = getAuthToken();
    return token != null && token.isNotEmpty && getIsLoggedIn();
  }

  /// Saves the common session fields returned after a successful login.
  ///
  /// Clears any previous session first so the new auth token fully replaces
  /// the old one and cannot leak into the next request.
  Future<void> saveSession({
    required String authToken,
    String? refreshToken,
    String? userId,
    String? username,
    String? fullName,
    String? userRole,
    String? userEmail,
    String? investorCode,
    String? profileImage,
    bool? isActive,
  }) async {
    await clearSession();
    await setAuthToken(authToken);
    if (refreshToken != null) await setRefreshToken(refreshToken);
    if (userId != null) await setUserId(userId);
    if (username != null) await setUsername(username);
    if (fullName != null) await setFullName(fullName);
    if (userRole != null) await setUserRole(userRole);
    if (userEmail != null) await setUserEmail(userEmail);
    if (investorCode != null && investorCode.isNotEmpty) {
      await setInvestorCode(investorCode);
    }
    if (profileImage != null && profileImage.isNotEmpty) {
      await setProfileImage(profileImage);
    }
    if (isActive != null) await setIsActive(isActive);
    await setIsLoggedIn(true);
  }

  /// Completely removes the auth token and all session-specific data.
  Future<void> clearSession() async {
    _authToken = null;
    _refreshToken = null;
    await Future.wait([
      _deleteToken(_authTokenKey),
      _deleteToken(_refreshTokenKey),
      _prefs.remove(_userIdKey),
      _prefs.remove(_usernameKey),
      _prefs.remove(_fullNameKey),
      _prefs.remove(_userRoleKey),
      _prefs.remove(_userEmailKey),
      _prefs.remove(_investorCodeKey),
      _prefs.remove(_profileImageKey),
      _prefs.remove(_isLoggedInKey),
      _prefs.remove(_isActiveKey),
      _prefs.remove(_fundingTransactionHistoryKey),
    ]);
  }
}
