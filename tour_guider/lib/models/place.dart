import 'review.dart';

class Place {
  String id; // Unique identifier for the place
  String name;
  String description;
  String category;
  double? averageRating;
  List<Review>? reviews;
  Map<String, dynamic> operatingHours;
  Map<String, dynamic> address;
  List<String> contactInfo;
  List<String>? imageUrl; // URL to an image of the place

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.averageRating,
    this.reviews,
    required this.operatingHours,
    required this.address,
    required this.contactInfo,
    this.imageUrl,
  });

  // Factory method to create a Place from a map (e.g., JSON)
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      averageRating: json['averageRating'],
      reviews: json['reviews'] != null ? List<Review>.from(json['reviews'].map((x) => Review.fromJson(x))) : null,
      operatingHours: json['operatingHours'],
      address: json['address'],
      contactInfo: List<String>.from(json['contact']),
      imageUrl: json["photos"] != null ? json['photos'].map<String>((photo) => photo['path']).toList() : null,
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
      'reviews': reviews?.map((x) => x.toJson()).toList(),
      'operatingHours': operatingHours,
      'address': address,
      'contactInfo': contactInfo,
      'imageUrl': imageUrl?.map((url) => {'path': url}).toList(),
    };
  }

  String get formattedContactInfo {
    if (contactInfo.isNotEmpty) {
      return contactInfo.first;
    }
    return 'No contact info available';
  }

  String get location {
    return "${address['street']}\n${address['city']}, ${address['state']} ${address['zipCode']}\n${address['country']}";
  }

  String get formattedOperatingHours {
    return operatingHours.entries.map((entry) {
      String day = entry.key;
      String startTime = entry.value['openingTime'] ?? 'N/A';
      String endTime = entry.value['closingTime'] ?? 'N/A';
      return "$day: $startTime - $endTime";
    }).join('\n');
  }

  int get totalReviews => reviews?.length ?? 0;

}
