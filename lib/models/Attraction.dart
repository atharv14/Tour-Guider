// models/Attraction.dart
import 'place.dart';

class Attraction extends Place {
  final bool parkingAvailable;
  final double entryFee;
  final String theme;
  final bool kidFriendly;

  Attraction({
    required String id,
    required String name,
    required String description,
    required String location,
    bool isFavorite = false,
    required OperatingHours operatingHours,
    required this.parkingAvailable,
    required this.entryFee,
    required this.theme,
    required this.kidFriendly,
  }) : super(
    id: id,
    name: name,
    description: description,
    location: location,
    isFavorite: isFavorite,
    category: PlaceCategory.Attraction,
    operatingHours: operatingHours,
  );
}