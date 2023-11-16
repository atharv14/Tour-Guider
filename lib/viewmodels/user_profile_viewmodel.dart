import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProfileViewModel extends ChangeNotifier {
  User _user = User(id: '', firstname: '', lastname: '', username: '', email: '');

  User get user => _user;

  // Initialize the UserProfileViewModel with a user object
  UserProfileViewModel(User initialUser) {
    _user = initialUser;
  }

  // Method to update the user's name
  void updateUserName(String newUsername) {
    _user.username = newUsername;
    notifyListeners();
  }

  // Method to update the user's email
  void updateEmail(String newEmail) {
    _user.email = newEmail;
    notifyListeners();
  }
}
