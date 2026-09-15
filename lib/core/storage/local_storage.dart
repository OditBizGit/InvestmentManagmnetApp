import 'package:shared_preferences/shared_preferences.dart';

/// Persists auth token and session/user data via [SharedPreferences].
class LocalStorage {
  LocalStorage._(this._prefs);

  final SharedPreferences _prefs;

  /// Initializes [SharedPreferences] and returns a ready [LocalStorage].
  static Future<LocalStorage> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage._(prefs);
  }

  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _fullNameKey = 'full_name';
  static const String _userRoleKey = 'user_role';
  static const String _userEmailKey = 'user_email';
  static const String _isLoggedInKey = 'is_logged_in';

  // ── Auth token ────────────────────────────────────────────────────

  Future<bool> setAuthToken(String token) =>
      _prefs.setString(_authTokenKey, token);

  String? getAuthToken() => _prefs.getString(_authTokenKey);

  Future<bool> clearAuthToken() => _prefs.remove(_authTokenKey);

  // ── Refresh token ─────────────────────────────────────────────────

  Future<bool> setRefreshToken(String token) =>
      _prefs.setString(_refreshTokenKey, token);

  String? getRefreshToken() => _prefs.getString(_refreshTokenKey);

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

  Future<bool> setIsLoggedIn(bool value) =>
      _prefs.setBool(_isLoggedInKey, value);

  bool getIsLoggedIn() => _prefs.getBool(_isLoggedInKey) ?? false;

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
  }) async {
    await clearSession();
    await setAuthToken(authToken);
    if (refreshToken != null) await setRefreshToken(refreshToken);
    if (userId != null) await setUserId(userId);
    if (username != null) await setUsername(username);
    if (fullName != null) await setFullName(fullName);
    if (userRole != null) await setUserRole(userRole);
    if (userEmail != null) await setUserEmail(userEmail);
    await setIsLoggedIn(true);
  }

  /// Completely removes the auth token and all session-specific data.
  Future<void> clearSession() async {
    await Future.wait([
      _prefs.remove(_authTokenKey),
      _prefs.remove(_refreshTokenKey),
      _prefs.remove(_userIdKey),
      _prefs.remove(_usernameKey),
      _prefs.remove(_fullNameKey),
      _prefs.remove(_userRoleKey),
      _prefs.remove(_userEmailKey),
      _prefs.remove(_isLoggedInKey),
    ]);
  }
}
