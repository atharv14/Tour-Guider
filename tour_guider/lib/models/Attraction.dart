// models/Attraction.dart
import 'place.dart';

class Attraction extends Place {
  final bool parkingAvailable;
  final double entryFee;
  final String theme;
  final bool kidFriendly;

  Attraction({
    required super.id,
    required super.name,
    required super.description,
    required super.location,
    super.isFavorite,
    required OperatingHours operatingHours,
    required this.parkingAvailable,
    required this.entryFee,
    required this.theme,
    required this.kidFriendly,
  }) : super(
    category: PlaceCategory.Attraction,
    operatingHours: operatingHours,
  );
}