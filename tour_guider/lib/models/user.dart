class User {
  String firstName;
  String lastName;
  String userName;
  String email;
  String password;
  String bio;
  String profilePhotoUrl;
  String totalReviews;

  User({
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.email,
    required this.password,
    required this.bio,
    this.profilePhotoUrl = '',
    this.totalReviews = '0',
  });

  // Factory method to create a User from a map (e.g., JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['firstName'],
      lastName: json['lastName'],
      userName: json['userName'],
      email: json['email'],
      password: json['password'],
      bio: json['bio'],
      profilePhotoUrl: json['profilePhotoUrl'] ?? '',
      totalReviews: json['totalReviews'] ?? '0',
    );
  }

  // Method to convert User to a map (e.g., for JSON)
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
      'email': email,
      'password': password,
      'bio': bio,
      'profilePhotoUrl': profilePhotoUrl,
      'totalReviews': totalReviews,
    };
  }

  String initials() {
    return '${firstName[0]}${lastName[0]}';
  }

  String fullName() {
    return '$firstName $lastName';
  }

}
