import 'package:flutter/material.dart';
import 'registration_screen.dart'; // Import registration screen
import 'place_list_view.dart'; //Import places view screen
import '../models/place.dart'; // Import Place model class

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Create a list of JSON maps
    List<Map<String, dynamic>> placeJson = [
      {
        'id': 'place1',
        'name': 'Place 1',
        'description': 'Description/category 1.',
        'category': 'Attraction',
        'averageRating': 4.2,
        'reviewCount': 150,
        'timings': '9 AM - 5 PM',
        'location': '123 attractive Drive',
        'contactInfo': '123-456-7890',
        'imageUrl': 'https://example.com/image_of_place.jpg',
        'isFavorite': false,
      },
      // Place(
      //     name: 'Place 2',
      //     description: 'Description 2',
      //     averageRating: 4.8,
      //     reviewCount: 400,
      //     imageUrl: 'https://example.com/image2.jpg',
      //     isFavorite: false),
      // Place(
      //     name: 'Place 3',
      //     description: 'Description 3',
      //     averageRating: 4.5,
      //     reviewCount: 1000,
      //     imageUrl: 'https://example.com/image3.jpg',
      //     isFavorite: true)
    ];

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
              onPressed: () {
                // Implement login logic
                List<Place> places = placeJson.map((json) => Place.fromJson(json)).toList();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PlacesViewScreen(places: places)
                  ),
                );
              },
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
