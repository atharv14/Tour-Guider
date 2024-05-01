import 'place.dart';
import 'review.dart';

class Shopping extends Place {
  List<String> associatedBrands;

  Shopping({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    super.averageRating,
    super.reviews,
    required super.address,
    required super.contactInfo,
    super.imageUrl,
    required super.operatingHours,
    required this.associatedBrands,
  });
// JSON conversion methods if needed
  factory Shopping.fromJson(Map<String, dynamic> json) {
    return Shopping(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      averageRating: json['averageRatings'],
      reviews: json['reviews'] != null
          ? List<Review>.from(
          json['reviews'].map((x) => Review.fromJson(x)))
          : null,
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
