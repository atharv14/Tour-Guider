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
      rating: (json['ratings'] as int).toDouble(), // Assuming 'ratings' is an integer
      subject: json['subject'],
      content: json['content'],
      dateTime: DateTime.parse(json['dateTime']),
      userId: json['userId'],
      placeId: json['placeId'],
      photos: json["photos"] != null
          ? json['photos'].map<String>((photo) {
            return photo['path'];
          }).toList() : null,
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
