import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/review.dart';

class ReviewProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  List<Review> _reviews = [];
  Review? detailedReview;
  final Map<String, List<MemoryImage>> _reviewImages = {};

  final Map<String, Set<String>> _downloadedImages = {};

  List<Review> get reviews => _reviews;
  List<MemoryImage> getReviewImages(String reviewId) {
    return _reviewImages[reviewId] ?? [];
  }

  String ipPort = 'http://192.168.1.234:8080';

  String baseUrl = 'http://192.168.1.234:8080/api/v1/reviews';
  String photoBaseUrl = 'http://192.168.1.234:8080/api/v1/photos/upload/review';
  String photoUrl = 'http://192.168.1.234:8080/api/v1/photos/fetch';


  Future<void> downloadReviewImages(String reviewId, List<String> imagePaths) async {
    if (_reviewImages.containsKey(reviewId) && _reviewImages[reviewId]!.isNotEmpty) {
      debugPrint("Images already downloaded, no need to download again");
      return; // Images already downloaded, no need to download again
    }

    _downloadedImages[reviewId] ??= {};

    String? authToken = await _secureStorage.read(key: 'authToken');

    for (String path in imagePaths) {
      if (!_downloadedImages[reviewId]!.contains(path)) {
        try {
          final url = Uri.parse('$photoUrl?photoPath=$path');
          final response = await http.get(url, headers: {'Authorization': 'Bearer $authToken'});

          if (response.statusCode == 200) {
            _reviewImages[reviewId] ??= [];
            _reviewImages[reviewId]?.add(MemoryImage(response.bodyBytes));
            _downloadedImages[reviewId]?.add(path); // Mark as downloaded
          } else {
            debugPrint("Failed to fetch photo: ${response.body}");
          }
        } catch (e) {
          debugPrint("Exception in fetching photo: $e");
        }
      }
    }
    notifyListeners();
  }

  // Method to upload multiple review images
  Future<void> uploadReviewImages(List<File> images, String reviewId) async {
    var request = http.MultipartRequest(
        "POST",
        Uri.parse("$photoBaseUrl/$reviewId")
    );

    // Read authToken from secure storage and add it to request header
    String? authToken = await _secureStorage.read(key: 'authToken');
    request.headers['Authorization'] = 'Bearer $authToken';

    // Add files to the request
    for (File image in images) {
      var picture = await http.MultipartFile.fromPath('files', image.path);
      request.files.add(picture);
    }

    try {
      // Send the request
      var response = await request.send();

      // Handle the response
      if (response.statusCode != 200) {
        var responseBody = await response.stream.bytesToString();
        debugPrint("Error uploading review images: $responseBody");
      } else {
        // Optionally, update any local state or notify listeners
        notifyListeners(); // If needed to refresh UI or update local data
      }
    } catch (e) {
      debugPrint("Exception in review images upload: $e");
    }
  }

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
        notifyListeners(); // Notify listeners to rebuild widgets that depend on this data
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
  Future<void> deleteReview(String reviewId) async {
    final url = Uri.parse('$baseUrl/$reviewId');
    String? authToken =
        await _secureStorage.read(key: 'authToken'); // Get the auth token

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $authToken', // Send authorization token
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        _reviews.removeWhere((review) => review.id == reviewId);
        notifyListeners();
      } else {
        // Handle non-200 responses
        debugPrint('Failed to delete the review: ${response.body}');
      }
    } catch (error) {
      // Handle network error, throw exception or log it
      debugPrint('Error deleting review: $error');
    }
  }

// Additional methods for deleting, fetching, etc.
}
