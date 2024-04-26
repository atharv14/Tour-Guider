import 'review.dart';
import 'place.dart';

class Attraction extends Place {
  late final bool parkingAvailable;
  late final double entryFee;
  late final String theme;
  late final bool kidFriendly;

  Attraction({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    super.averageRating,
    super.reviews,
    required super.address,
    required super.contactInfo,
    super.imageUrl,
    required super.operatingHours,
    required this.kidFriendly,
    required this.parkingAvailable,
    required this.theme,
    required this.entryFee,
  });

  factory Attraction.fromJson(Map<String, dynamic> json) {    // : super.fromJson(json)
    return Attraction(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      averageRating: json['averageRatings'],
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((e) => Review.fromJson(e))
          .toList(),
      address: json['address'],
      contactInfo: List<String>.from(json['contact']),
      imageUrl: json["photos"] != null
          ? List<String>.from(
          json['photos'].map((photo) => photo['path'] as String))
          : null,
      operatingHours: json['operatingHours'],
      kidFriendly: json['kidFriendly'] ?? false,
      parkingAvailable: json['parkingAvailable'] ?? false,
      theme: json['theme'] ?? '',
      entryFee: double.tryParse(json['entryFee'].toString()) ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'kidFriendly': kidFriendly,
      'parkingAvailable': parkingAvailable,
      'theme': theme,
      'entryFee': entryFee,
    });
    return data;
  }

  // Getters
  bool get isKidFriendly => kidFriendly;
  bool get isParkingAvailable => parkingAvailable;
  String get getTheme => theme;
  double get getEntryFee => entryFee;
}
