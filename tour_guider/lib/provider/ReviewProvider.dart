
import 'package:flutter/material.dart';
import '../models/review.dart';

class ReviewProvider with ChangeNotifier {
  final List<Review> _reviews = [];

  List<Review> get reviews => _reviews;

  // String baseUrl = 'http://localhost:8080/api/v1/reviews/';

  //Todo addReview - POST
  // Future<void> addReview(Review review) async {
  //   final url = Uri.parse(baseUrl);
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Authorization': '',
  //         'Content-Type': 'application/json'
  //       },
  //       body: json.encode(review.toJson()),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       _reviews.add(review);
  //       notifyListeners();
  //     } else {
  //       // Handle error response
  //       debugPrint('Failed to add the review: ${response.body}');
  //     }
  //   } catch (error) {
  //     // Handle any exceptions
  //     debugPrint('Error updating review: $error');
  //   }
  // }

  //Todo updateReview - PUT
  // Future<void> updateReview(String reviewId, Review updatedReview) async {
  //   final reviewIndex = _reviews.indexWhere((review) => review.id == reviewId);
  //   if (reviewIndex >= 0) {
  //     final url = Uri.parse('$baseUrl$reviewId');
  //
  //     try {
  //       final response = await http.put(
  //         url,
  //         headers: {
  //           'Authorization': '',
  //           'Content-Type': 'application/json'
  //         },
  //         body: json.encode(updatedReview.toJson()),
  //       );
  //
  //       if (response.statusCode == 200) {
  //         _reviews[reviewIndex] = updatedReview;
  //         notifyListeners();
  //       } else {
  //         // Handle non-200 responses
  //         debugPrint('Failed to update the review: ${response.body}');
  //       }
  //     } catch (error) {
  //       // Handle network error, throw exception or log it
  //       debugPrint('Error updating review: $error');
  //     }
  //   }
  // }

  //Todo deleteReview - DELETE
  // Future<void> deleteReview(String reviewId) async {
  //   final url = Uri.parse('$baseUrl$reviewId');
  //
  //   try {
  //     final response = await http.delete(url);
  //
  //     if (response.statusCode == 200) {
  //       _reviews.removeWhere((review) => review.id == reviewId);
  //       notifyListeners();
  //     } else {
  //       // Handle non-200 responses
  //       debugPrint('Failed to delete the review: ${response.body}');
  //     }
  //   } catch (error) {
  //     // Handle network error, throw exception or log it
  //     debugPrint('Error deleting review: $error');
  //   }
  // }

  void addReview(Review review) {
    _reviews.add(review);
    notifyListeners();
  }

  void updateReview(String reviewId, Review updatedReview) {
    final index = _reviews.indexWhere((review) => review.id == reviewId);
    if (index != -1) {
      _reviews[index] = updatedReview;
      notifyListeners();
    }
  }

// Additional methods for deleting, fetching, etc.
}
