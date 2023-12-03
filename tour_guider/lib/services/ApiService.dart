import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart'; // import User model

class ApiService {
  final String baseUrl = 'http://localhost:8080/api/v1/';

  Future<User> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signin'),
      headers: <String, String>{
        'Authorization': '',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to login user');
    }
  }
}
