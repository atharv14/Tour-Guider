import 'package:flutter/material.dart';
import 'registration_screen.dart'; // Import registration screen
import 'place_list_view.dart'; //Import places view screen
import '../models/place.dart'; // Import Place model class

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {

  late List<Place> places;

  @override
  void initState() {
    super.initState();
    // Create a list of JSON maps
    List<Map<String, dynamic>> placeJson = [
      {
        'id': 'place1',
        'name': 'Place 1',
        'description': 'Description 1.',
        'category': 'Attraction',
        'averageRating': 4.2,
        'reviewCount': 150,
        'timings': '9 AM - 5 PM',
        'location': '123 attractive Drive',
        'contactInfo': '123-456-7890',
        'imageUrl': 'https://example.com/image_of_place.jpg',
        'isFavorite': false,
      },
    ];
    places = placeJson.map((json) => Place.fromJson(json)).toList(); // Initialize places in initState
  }

  Future<void> _navigateAndDisplayPlaces(BuildContext context) async {
    // Navigate to the PlacesViewScreen and wait for the result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacesViewScreen(places: places),
      ),
    );

    // Update the list of places with the result if not null
    if (result != null) {
      setState(() {
        places = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const TextField(
              decoration: InputDecoration(
                labelText: 'Username',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Login'),
              onPressed: () => _navigateAndDisplayPlaces(context),
            ),
            TextButton(
              child: const Text('Don\'t have an account? Register here!'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
