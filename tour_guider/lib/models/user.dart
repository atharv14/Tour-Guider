

import 'package:flutter/cupertino.dart';
import 'package:tour_guider/models/place.dart';

import 'review.dart';

class User {
  String id;
  String firstName;
  String lastName;
  String userName;
  String email;
  String? password;
  String bio;
  String? profilePhotoPath;
  List<Review>? reviews;
  List<Place>? savedPlaces;
  bool? isAdmin;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.email,
    required this.password,
    required this.bio,
    this.profilePhotoPath,
    this.reviews,
    this.savedPlaces,
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
    List<Review>? reviews,
    List<Place>? savedPlaces,
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
      reviews: reviews ?? this.reviews,
      savedPlaces: savedPlaces ?? this.savedPlaces,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  // Factory method to create a User from a map (e.g., JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    debugPrint('photo: ${json['photo']}'); // This should print a Map or null
    debugPrint('photo path: ${json['photo']?['path']}'); // This should print a String or null
    return User(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      userName: json['username'] ?? '', // Changed from 'userName' to 'username' to match your JSON
      email: json['email'] ?? '',
      password: json['password'], // Nullable, no need for a default value
      bio: json['bio'] ?? '',
      profilePhotoPath: json['photo'] != null ? json['photo']['path'] : null,
      reviews: json['reviews'] != null
          ? List<Review>.from(json['reviews'].map((x) => Review.fromJson(x)))
          : null,
      savedPlaces: json['savedPlaces'] != null
          ? List<Place>.from(json['savedPlaces'].map((x) => Place.fromJson(x)))
          : null,
      isAdmin: json['userRole'] == 'ADMIN',
    );
  }


  // Method to convert User to a map (e.g., for JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'username': userName,
      'email': email,
      'password': password,
      'bio': bio,
      'photo': profilePhotoPath,
      'reviews': reviews,
      'savedPlaces': savedPlaces,
      'userRole': isAdmin ,
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
    password =  null;
  }

  // Getter for totalReviews
  int? get totalReviews => reviews?.length;

}
