import 'place.dart';
import 'review.dart';

class Restaurant extends Place {
  List<String> cuisines;
  double priceForTwo;
  bool reservationsRequired;
  String type;

  Restaurant({
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
    required this.cuisines,
    required this.priceForTwo,
    required this.reservationsRequired,
    required this.type,
  });
// JSON conversion methods if needed
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
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
      cuisines: List<String>.from(json['cuisines']),
      priceForTwo: json['priceForTwo'].toDouble(),
      reservationsRequired: json['reservationsRequired'],
      type: json['type'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'cuisines': cuisines,
      'priceForTwo': priceForTwo,
      'reservationsRequired': reservationsRequired,
      'type': type,
    });
    return data;
  }

  // Getters:
  List<String> get getCuisines => List.unmodifiable(cuisines);
  double get getPriceForTwo => priceForTwo;
  bool get areReservationsRequired => reservationsRequired;
  String get getType => type;
}
