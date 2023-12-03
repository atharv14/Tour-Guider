
import 'place.dart';

class User {
  String id;
  String firstName;
  String lastName;
  String userName;
  String email;
  String? password;
  String bio;
  String profilePhotoPath;
  // Todo: len function on reviews
  String totalReviews;
  List<String> savedPlaces;
  bool isAdmin;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.email,
    required this.password,
    required this.bio,
    this.profilePhotoPath = '',
    this.totalReviews = '',
    this.savedPlaces = const [],
    this.isAdmin = false,
  });

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? userName,
    String? email,
    String? password,
    String? bio,
    String? profilePhotoPath,
    String? totalReviews,
    List<String>? savedPlaces,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      password: password ?? this.password,
      bio: bio ?? this.bio,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      totalReviews: totalReviews ?? this.totalReviews,
      savedPlaces: savedPlaces ?? this.savedPlaces,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  // Factory method to create a User from a map (e.g., JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      userName: json['userName'],
      email: json['email'],
      password: json['password'],
      bio: json['bio'],
      profilePhotoPath: json['photo']?['path'] ?? '',
      totalReviews: json['totalReviews'] ?? '',
      savedPlaces: List<String>.from(json['savedPlaces'] ?? []),
      isAdmin: json['userRole'] == 'ADMIN',
    );
  }

  // Method to convert User to a map (e.g., for JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
      'email': email,
      'password': password,
      'bio': bio,
      'photo': {'path': profilePhotoPath},
      'totalReviews': totalReviews,
      'savedPlaces': savedPlaces,
      'userRole': isAdmin ? 'ADMIN' : 'USER',
    };
  }

  String initials() {
    return '${firstName[0]}${lastName[0]}';
  }

  String fullName() {
    return '$firstName $lastName';
  }

  // Clear the password after use
  void clearPassword() {
    password = null;
  }

}
