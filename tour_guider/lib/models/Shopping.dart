// models/Shopping.dart
import 'place.dart';

class Shopping extends Place {
  List<String> associatedBrands;

  Shopping({
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
    required this.associatedBrands,
  });
// JSON conversion methods if needed
}
