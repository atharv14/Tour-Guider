import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/place.dart';

class PlaceProvider with ChangeNotifier {
  List<Place> _places = [];
  List<Place> _filteredPlaces = [];
  List<Place> _searchResults = []; // Add this line


  // List<Place> get allPlaces => _places;
  List<Place> get places => _filteredPlaces;
  List<Place> get searchResults => _searchResults; // Add this getter


  String baseUrl = 'http://192.168.1.234:8080/api/v1/places';
  final String favoritePlaceUrl =
      'http://192.168.1.234:8080/api/v1/users/place';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  void addPlace(Place place) {
    _places.add(place);
    notifyListeners();
  }

  void removePlace(String placeId) {
    _places.removeWhere((place) => place.id == placeId);
    notifyListeners();
  }

// Add more methods as needed for updating and fetching places

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
        _searchResults = _places;
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
