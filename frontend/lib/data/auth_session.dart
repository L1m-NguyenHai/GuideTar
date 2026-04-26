class AuthSession {
  AuthSession._();

  static String? accessToken;
  static String? refreshToken;
  static Map<String, dynamic>? user;

  static bool get isLoggedIn => accessToken != null && accessToken!.isNotEmpty;

  static void setTokens({
    required String access,
    required String refresh,
    required Map<String, dynamic> userPayload,
  }) {
    accessToken = access;
    refreshToken = refresh;
    user = Map<String, dynamic>.from(userPayload);
  }

  static void clear() {
    accessToken = null;
    refreshToken = null;
    user = null;
  }
}
