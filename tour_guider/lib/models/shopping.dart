import 'place.dart';
import 'review.dart';

class Shopping extends Place {
  late final List<String> associatedBrands;

  Shopping({
    required String id,
    required String name,
    required String description,
    required String category,
    double? averageRating,
    List<Review>? reviews,
    required Map<String, dynamic> address,
    required List<String> contactInfo,
    List<String>? imageUrl,
    required Map<String, dynamic> operatingHours,
    required this.associatedBrands,
  }) : super(
    id: id,
    name: name,
    description: description,
    category: category,
    averageRating: averageRating,
    reviews: reviews,
    address: address,
    contactInfo: contactInfo,
    imageUrl: imageUrl,
    operatingHours: operatingHours,
  );
// JSON conversion methods if needed
  factory Shopping.fromJson(Map<String, dynamic> json) {
    return Shopping(
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
      associatedBrands: List<String>.from(json['associatedBrands']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'associatedBrands': associatedBrands,
    });
    return data;
  }

  // Getter
  List<String> get getAssociatedBrands => List.unmodifiable(associatedBrands);

}
