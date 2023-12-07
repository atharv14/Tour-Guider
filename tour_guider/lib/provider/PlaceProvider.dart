import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/place.dart';

class PlaceProvider with ChangeNotifier {
  List<Place> _places = [];
  List<Place> _filteredPlaces = [];
  final List<Place> _searchResults = []; // Add this line
  final Map<String, List<MemoryImage>> _placeImages = {};
  final Map<String, Set<String>> _downloadedImages = {};


  // List<Place> get allPlaces => _places;
  List<Place> get places => _filteredPlaces;
  List<Place> get searchResults => _searchResults; // Add this getter
  List<MemoryImage> getImagesForPlace(String placeId) {
    return _placeImages[placeId] ?? [];
  }

  String ipPort = 'http://192.168.1.234:8080';

  String baseUrl = 'http://192.168.1.234:8080/api/v1/places';
  final String favoritePlaceUrl = 'http://192.168.1.234:8080/api/v1/users/place';
  String photoFetchUrl = 'http://192.168.1.234:8080/api/v1/photos/fetch';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

// Add more methods as needed for updating and fetching places

  // Fetch and store images for a given place
  Future<void> downloadImagesForPlace(String placeId, List<String> imagePaths) async {
    if (_placeImages.containsKey(placeId) && _placeImages[placeId]!.isNotEmpty) {
      debugPrint("Images already downloaded, no need to download again");
      return; // Images already downloaded, no need to download again
    }

    _downloadedImages[placeId] ??= {};

    String? authToken = await _secureStorage.read(key: 'authToken');

    for (String path in imagePaths) {
      if (!_downloadedImages[placeId]!.contains(path)) {
        try {
          final url = Uri.parse('$photoFetchUrl?photoPath=$path');
          final response = await http.get(url, headers: {'Authorization': 'Bearer $authToken'});

          if (response.statusCode == 200) {
            _placeImages[placeId] ??= [];
            _placeImages[placeId]?.add(MemoryImage(response.bodyBytes));
            _downloadedImages[placeId]?.add(path); // Mark as downloaded
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



  // Fetch all places
  Future<void> fetchPlaces() async {
    final url = Uri.parse(baseUrl);
    String? authToken = await _secureStorage.read(key: 'authToken');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $authToken',
        // 'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        List<dynamic> placesJson = json.decode(response.body);
        _places = placesJson.map((json) => Place.fromJson(json)).toList();
        // notifyListeners();
        _filteredPlaces = _places;
        notifyListeners();
      } else {
        // Handle error
        debugPrint('Failed to fetch places: ${response.body}');
      }
    } catch (e) {
      // Handle exception
      debugPrint('Error fetching places: $e');
    }
    notifyListeners();
  }

  void filterFavoritePlaces(List<String> favoritePlaceIds) {
    _filteredPlaces = _places.where((place) => favoritePlaceIds.contains(place.id)).toList();
    notifyListeners();
  }

  Future<Place?> fetchPlaceById(String placeId) async {
    final url = Uri.parse('$baseUrl/$placeId');
    String? authToken = await _secureStorage.read(key: 'authToken');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $authToken',
        // 'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        return Place.fromJson(json.decode(response.body));
      } else {
        // Handle non-200 responses
        debugPrint('Failed to fetch place: ${response.body}');
        return null;
      }
    } catch (e) {
      // Handle network error, throw exception or log it
      debugPrint('Error fetching place: $e');
      return null;
    }
  }

  Future<void> searchPlaces(String query) async {
    try {
      final url = Uri.parse('$baseUrl/search?searchText=$query');
      String? authToken = await _secureStorage.read(key: 'authToken');

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $authToken',
        // 'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        List<dynamic> placesJson = json.decode(response.body);
        _places = placesJson.map((json) => Place.fromJson(json)).toList();
        _filteredPlaces = _places;
        notifyListeners();
      } else {
        // Handle non-200 responses
        debugPrint('Failed to fetch places: ${response.body}');
      }
    } catch (e) {
      // Handle network error
      debugPrint('Error fetching places: $e');
    }
    notifyListeners();
  }

  void filterPlacesByCategory(String category) {
    if (category == 'All') {
      _filteredPlaces = _places; // Show all places if 'All' category is selected
    } else {
      _filteredPlaces = _places.where((place) => place.category == category).toList();
    }
    notifyListeners();
  }


}
