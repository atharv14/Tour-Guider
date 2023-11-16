// models/Restaurant.dart
import 'place.dart';

class Restaurant extends Place {
  final bool reservationRequired;
  final double priceForTwo;
  final List<String> cuisines;
  final String restaurantType;

  Restaurant({
    required String id,
    required String name,
    required String description,
    required String location,
    bool isFavorite = false,
    required OperatingHours operatingHours,
    required this.reservationRequired,
    required this.priceForTwo,
    required this.cuisines,
    required this.restaurantType,
  }) : super(
    id: id,
    name: name,
    description: description,
    location: location,
    isFavorite: isFavorite,
    category: PlaceCategory.Restaurant,
    operatingHours: operatingHours,
  );
}