// services/authentication_service.dart
class AuthenticationService {
  final Map<String, String> _validCredentials = {
    'user123': 'password', // Username 'user123' with password 'password'
    'johndoe': 'password', // Username 'johndoe' with password 'password'
    'janesmith': 'password', // Username 'janesmith' with password 'password'
  };

  Future<bool> login(String username, String password) async {
    // Simulate a delay to mimic an authentication request
    await Future.delayed(const Duration(seconds: 2));

    final validPassword = _validCredentials[username];

    if (validPassword != null && password == validPassword) {
      return true; // Authentication success
    } else {
      return false; // Authentication failed
    }
  }
}
