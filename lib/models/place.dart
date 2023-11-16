class Place {
  String id; // Unique identifier for the place
  String name;
  String description;
  String category;
  double averageRating;
  int reviewCount;
  String timings;
  String location; // You could use a more complex type for location
  String contactInfo;
  String imageUrl; // URL to an image of the place
  bool isFavorite;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.averageRating,
    required this.reviewCount,
    required this.timings,
    required this.location,
    required this.contactInfo,
    required this.imageUrl,
    this.isFavorite = false,
  });

  // Factory method to create a Place from a map (e.g., JSON)
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      averageRating: json['averageRating'].toDouble(),
      reviewCount: json['reviewCount'],
      timings: json['timings'],
      location: json['location'],
      contactInfo: json['contactInfo'],
      imageUrl: json['imageUrl'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // Method to convert Place to a map (e.g., for JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'timings': timings,
      'location': location,
      'contactInfo': contactInfo,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
    };
  }
}
