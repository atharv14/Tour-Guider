// import 'package:flutter/foundation.dart';
// import '../models/review.dart'; // Import your Place model
// import '../models/place.dart';
//
// class ReviewViewModel extends ChangeNotifier {
//   final List<Review> _reviews = [
//     Review(
//       id: '1',
//       place: Place(
//         id: '1',
//         name: 'Place 1',
//         description: 'Description of Place 1',
//         location: 'Location of Place 1',
//       ),
//       comments: 'Great place!',
//       ratings: 4.5,
//       reviewer: 'johndoe',
//     ),
//     Review(
//       id: '2',
//       place: Place(
//         id: '2',
//         name: 'Place 2',
//         description: 'Description of Place 2',
//         location: 'Location of Place 2',
//       ),
//       comments: 'Awesome experience!',
//       ratings: 5.0,
//       reviewer: 'janesmith',
//     ),
//     // Add more hardcoded reviews as needed
//   ];
//
//   List<Review> get reviews => _reviews;
//
//   // Add method to populate reviews
//   void addReview(Review review) {
//     _reviews.add(review);
//     notifyListeners();
//   }
//
// // Add methods for review-related operations (e.g., edit review, delete review)
// }