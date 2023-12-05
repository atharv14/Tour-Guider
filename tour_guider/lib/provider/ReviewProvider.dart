
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/review.dart';

class ReviewProvider with ChangeNotifier {
  List<Review> _reviews = [];

  List<Review> get reviews => _reviews;

  Review? detailedReview;

  String baseUrl = 'http://192.168.1.234:8080/api/v1/reviews';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Fetch a place by id from list of places - GET
  Future<List<Review>> fetchReviewsForPlace(String placeId) async {
    final url = Uri.parse('$baseUrl/place/$placeId');
    String? authToken = await _secureStorage.read(key: 'authToken');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $authToken',
        // 'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        List<dynamic> reviewJson = json.decode(response.body);
        _reviews = reviewJson.map((json) => Review.fromJson(json)).toList();
        notifyListeners();
        return _reviews;
      } else {
        debugPrint("Error getting response: ${response.body}");
        return []; // Return an empty list in case of error
      }
    } catch (e) {
      debugPrint("Failed to fetch reviews for the place: $e");
      return []; // Return an empty list in case of exception
    }
  }

  // Todo fetchReview - GET
  Future<void> fetchReviewDetails(String reviewId) async {
    final url = Uri.parse('$baseUrl/$reviewId');
    String? authToken = await _secureStorage.read(key: 'authToken');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $authToken',
        // 'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        detailedReview = Review.fromJson(json.decode(response.body));
        // isLoading = false;
        notifyListeners();  // Notify listeners to rebuild widgets that depend on this data
      } else {
        // Handle non-200 responses
        debugPrint('Failed to fetch review: ${response.body}');
      }
    } catch (e) {
      // Handle errors
      debugPrint('Error fetching review: $e');
    }
  }

  // Todo addReview - POST
  Future<void> addReview(String? placeId, Review review) async {
    final url = Uri.parse('$baseUrl/place/$placeId');
    String? authToken = await _secureStorage.read(key: 'authToken');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json'
        },
        body: json.encode(review.toJson()),
      );

      if (response.statusCode == 201) {
        _reviews.add(review);
        notifyListeners();
      } else {
        // Handle error response
        debugPrint('Failed to add the review: ${response.body}');
      }
    } catch (error) {
      // Handle any exceptions
      debugPrint('Error updating review: $error');
    }
  }

  //Todo updateReview - PUT
  Future<void> updateReview(String reviewId, Review updatedReview) async {
    final reviewIndex = _reviews.indexWhere((review) => review.id == reviewId);
    if (reviewIndex >= 0) {
      final url = Uri.parse('$baseUrl/$reviewId');
      String? authToken = await _secureStorage.read(key: 'authToken');

      try {
        final response = await http.put(
          url,
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json'
          },
          body: json.encode(updatedReview.toJson()),
        );

        if (response.statusCode == 202) {
          _reviews[reviewIndex] = updatedReview;
          notifyListeners();
        } else {
          // Handle non-200 responses
          debugPrint('Failed to update the review: ${response.body}');
        }
      } catch (error) {
        // Handle network error, throw exception or log it
        debugPrint('Error updating review: $error');
      }
    }
  }

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

  // void addReview(Review review) {
  //   _reviews.add(review);
  //   notifyListeners();
  // }
  //
  // void updateReview(String reviewId, Review updatedReview) {
  //   final index = _reviews.indexWhere((review) => review.id == reviewId);
  //   if (index != -1) {
  //     _reviews[index] = updatedReview;
  //     notifyListeners();
  //   }
  // }

// Additional methods for deleting, fetching, etc.
}
