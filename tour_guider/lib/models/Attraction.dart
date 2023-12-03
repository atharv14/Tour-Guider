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
    required super.category,
    required super.averageRating,
    required super.reviews,
    required super.address,
    required super.contactInfo,
    required super.imageUrl,
    required super.operatingHours,
    required this.kidFriendly,
    required this.parkingAvailable,
    required this.theme,
    required this.entryFee,

  });
// JSON conversion methods if needed
}
