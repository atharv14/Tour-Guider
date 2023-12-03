// models/Restaurant.dart
import 'place.dart';

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
    required super.averageRating,
    required super.reviews,
    required super.address,
    required super.contactInfo,
    required super.imageUrl,
    required super.operatingHours,
    required this.cuisines,
    required this.priceForTwo,
    required this.reservationsRequired,
    required this.type,
  });
// JSON conversion methods if needed
}
