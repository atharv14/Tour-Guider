// models/user.dart
class User {
   String id;
   String firstname;
   String lastname;
   String username;
   String email;

  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.email,
  });

  // Setter for username
  set setUsername(String newUsername) {
    username = newUsername;
  }

  // Setter for email
  set setEmail(String newEmail) {
    email = newEmail;
  }
}