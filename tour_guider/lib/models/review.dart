class Review {
  String id;
  double rating;
  String subject;
  String content;
  DateTime dateTime;
  String userId;
  String placeId;
  List<String>? photos;

  Review({
    required this.id,
    required this.rating,
    required this.subject,
    required this.content,
    required this.dateTime,
    required this.userId,
    required this.placeId,
    this.photos,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      rating: (json['ratings']).toDouble(),
      subject: json['subject'] ?? '',
      content: json['content'] ?? '',
      dateTime: json['dateTime'] != null ? DateTime.parse(json['dateTime']) : DateTime.now(),
      userId: json['userId'] ?? '',
      placeId: json['placeId'] ?? '',
      photos: json["photos"] != null
          ? List<String>.from(
          json['photos'].map((photo) => photo['path'] as String)
      )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ratings': rating,
      'subject': subject,
      'content': content,
      'dateTime': dateTime.toIso8601String(),
      'userId': userId,
      'placeId': placeId,
      'photos': photos?.map((path) => {'path': path}).toList(),
    };
  }
}
