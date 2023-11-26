import 'package:flutter/foundation.dart';
import '../models/user.dart'; // Import your Place model

class UserViewModel extends ChangeNotifier {
  final List<User> _users = [
    User(
      id: '1',
      firstname: 'John',
      lastname: 'Doe',
      username: 'johndoe',
      email: 'john@example.com',
    ),
    User(
      id: '2',
      firstname: 'Jane',
      lastname: 'Smith',
      username: 'janesmith',
      email: 'jane@example.com',
    ),
    // Add more hardcoded users as needed
  ];

  List<User> get users => _users;

  // Add method to populate users
  void addUser(User user) {
    _users.add(user);
    notifyListeners();
  }

// Add methods for user-related operations (e.g., update user profile, change password)
}