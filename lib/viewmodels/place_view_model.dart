import 'package:flutter/foundation.dart';
import '../models/place.dart'; // Import your Place model

class PlaceViewModel extends ChangeNotifier {
  List<Place> _places = []; // Replace with actual data source (e.g., Firebase Firestore)

  List<Place> get places => _places;

  // Add method to populate places
  void addHardcodedPlaces() {
    _places = [
      Place(
        id: '1',
        name: 'Place 1',
        description: 'Description of Place 1',
        location: 'Location of Place 1',
      ),
      Place(
        id: '2',
        name: 'Place 2',
        description: 'Description of Place 2',
        location: 'Location of Place 2',
      ),
      Place(
        id: '3',
        name: 'Place 3',
        description: 'Description of Place 3',
        location: 'Location of Place 3',
      ),
      Place(
        id: '4',
        name: 'Place 4',
        description: 'Description of Place 4',
        location: 'Location of Place 4',
      ),
      Place(
        id: '5',
        name: 'Place 5',
        description: 'Description of Place 5',
        location: 'Location of Place 5',
      ),
      Place(
        id: '6',
        name: 'Place 6',
        description: 'Description of Place 6',
        location: 'Location of Place 6',
      ),
      Place(
        id: '7',
        name: 'Place 7',
        description: 'Description of Place 7',
        location: 'Location of Place 7',
      ),

      // Add more hardcoded places as needed
    ];
    notifyListeners(); // Notify listeners that data has changed
  }

  // Method to toggle favorite status for a place
  void toggleFavorite(String placeId) {
    final index = _places.indexWhere((place) => place.id == placeId);
    if (index != -1) {
      _places[index].isFavorite = !_places[index].isFavorite;
      notifyListeners(); // Notify listeners that data has changed
    }
  }

  // Method to get a list of favorite places
  List<Place> getFavoritePlaces() {
    return _places.where((place) => place.isFavorite).toList();
  }

  // Fetch places from the data source (e.g., Firestore)
  Future<void> fetchPlaces() async {
    // Fetch data and update _places
    // Notify listeners to update the UI
    notifyListeners();
  }
}
