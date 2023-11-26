// models/Shopping.dart
import 'place.dart';

class Shopping extends Place {
  final List<String> brands;

  Shopping({
    required super.id,
    required super.name,
    required super.description,
    required super.location,
    super.isFavorite,
    required OperatingHours operatingHours,
    required this.brands,
  }) : super(
    category: PlaceCategory.Shopping,
    operatingHours: operatingHours,
  );
}