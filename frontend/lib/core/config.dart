class Config {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.0.148:5000',
  );

  static const String websocketUrl = String.fromEnvironment(
    'WEBSOCKET_URL',
    defaultValue: 'ws://192.168.0.148:5000',
  );

  static String? authToken;
  static String? refreshToken;

  static bool get isProduction {
    return const String.fromEnvironment('FLUTTER_ENV') == 'production';
  }

  static void setAuthToken(String token) {
    authToken = token;
  }

  static void setRefreshToken(String token) {
    refreshToken = token;
  }

  static void clearTokens() {
    authToken = null;
    refreshToken = null;
  }
}
