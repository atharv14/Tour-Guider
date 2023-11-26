class Review {
  String id; // Unique identifier for the review
  String userId; // ID of the user who wrote the review
  String userName; // Name of the user for display purposes
  String subject; // Subject or title of the review
  String content; // Main content text of the review
  double rating; // Numerical rating, e.g., out of 5 stars
  DateTime date; // The date the review was posted
  String userProfilePhoto;
  List<String> images; // List of image URLs

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.subject,
    required this.content,
    required this.rating,
    required this.date,
    this.userProfilePhoto = '',
    List<String>? images, // Initialize with an empty list by default
  }) : this.images = images ?? [];

  // Factory method to create a Review from a map (e.g., JSON)
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      subject: json['subject'],
      content: json['content'],
      rating: json['rating'].toDouble(),
      date: DateTime.parse(json['date']),
      userProfilePhoto: json['userProfilePhoto'] ?? '',
      images: (json['images'] as List?)?.map((item) => item as String).toList() ?? [],
    );
  }

  // Method to convert Review to a map (e.g., for JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'subject': subject,
      'content': content,
      'rating': rating,
      'date': date.toIso8601String(),
      'userProfilePhoto': userProfilePhoto,
      'images': images
    };
  }

  String getUserInitials() {
    return userName.isNotEmpty ? userName.substring(0, 1) : '';
  }

}
