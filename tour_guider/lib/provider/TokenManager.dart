// Token Manager Singleton
class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;

  String? _authToken;

  TokenManager._internal();

  set authToken(String? value) => _authToken = value;
  String? get authToken => _authToken;
}