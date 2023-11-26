// models/Restaurant.dart
import 'place.dart';

class Restaurant extends Place {
  final bool reservationRequired;
  final double priceForTwo;
  final List<String> cuisines;
  final String restaurantType;

  Restaurant({
    required super.id,
    required super.name,
    required super.description,
    required super.location,
    super.isFavorite,
    required OperatingHours operatingHours,
    required this.reservationRequired,
    required this.priceForTwo,
    required this.cuisines,
    required this.restaurantType,
  }) : super(
    category: PlaceCategory.Restaurant,
    operatingHours: operatingHours,
  );
}