// models/Shopping.dart
import 'place.dart';

class Shopping extends Place {
  final List<String> brands;

  Shopping({
    required String id,
    required String name,
    required String description,
    required String location,
    bool isFavorite = false,
    required OperatingHours operatingHours,
    required this.brands,
  }) : super(
    id: id,
    name: name,
    description: description,
    location: location,
    isFavorite: isFavorite,
    category: PlaceCategory.Shopping,
    operatingHours: operatingHours,
  );
}