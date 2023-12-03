import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/place.dart';

class PlaceProvider with ChangeNotifier {
  List<Place> _places = [];
  List<Place> _filteredPlaces = [];
  List<Place> _favoritePlaces = [];

  List<Place> get places => _filteredPlaces;

  String baseUrl = 'http://192.168.1.230:8080/api/v1/places';
  final String favoritePlaceUrl =
      'http://192.168.1.230:8080/api/v1/users/place';

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
        notifyListeners();
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

  void filterPlacesByCategory(String category) {
    if (category == 'All') {
      _filteredPlaces = _places;
    } else {
      _filteredPlaces =
          _places.where((place) => place.category == category).toList();
    }
    notifyListeners();
  }

  // Future<void> fetchFavoritePlaces(List<String> favoritePlaceIds) async {
  //   String? authToken = await _secureStorage.read(key: 'authToken');
  //   if (authToken == null) return;
  //
  //   _favoritePlaces = [];
  //   for (var placeId in favoritePlaceIds) {
  //     try {
  //       final response = await http.get(
  //         Uri.parse('$favoritePlaceUrl/$placeId'),
  //         headers: {'Authorization': 'Bearer $authToken'},
  //       );
  //       if (response.statusCode == 200) {
  //         Map<String, dynamic> placeJson = json.decode(response.body);
  //         _favoritePlaces.add(Place.fromJson(placeJson));
  //       }
  //     } catch (error) {
  //       debugPrint('Error fetching favorite place: $error');
  //     }
  //   }
  //   notifyListeners();
  // }

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

  void filterFavoritePlaces(List<String> favoritePlaceIds) {
    _filteredPlaces =
        _places.where((place) => favoritePlaceIds.contains(place.id)).toList();
    notifyListeners();
  }
}
