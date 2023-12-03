import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/place.dart'; // Import Place model class
import '../models/review.dart'; // Import Review model class
import 'login_screen.dart'; // Import login screen
import 'place_detail_screen.dart'; // Import Individual place view screen

class PlacesViewScreen extends StatefulWidget {
  final List<Place> places;

  PlacesViewScreen({required this.places});

  @override
  _PlacesViewScreenState createState() => _PlacesViewScreenState();
}

class _PlacesViewScreenState extends State<PlacesViewScreen> {

  late List<Place> places;
  late FToast fToast;
  bool showFavoritesOnly = false;//Declare FToast instance

  @override
  void initState() {
    super.initState();
    places = widget.places;
    fToast = FToast();
    fToast.init(context); // Initialize FToast with context
  }

  @override
  Widget build(BuildContext context) {

    List<Map<String, dynamic>> reviewsJson = [
      {
        'id': 'review1',
        'userId': 'user1',
        'userName': 'User One',
        'subject': 'Review Subject',
        'content': 'This place is great! I had an excellent time and the staff were wonderful.',
        'rating': 5.0,
        'date': '2021-07-16T19:20:30+00:00',
      },
      // ... other reviews
    ];
    print('Number of places: ${widget.places.length}'); // Add this line
    return Scaffold(
      appBar: AppBar(
        title: Text('Places'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              // Go to Home
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to user details
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Handle logout
              _showToast();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        // Add Drawer items here (home, user details, logout)
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Navigate to Home
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('User Details'),
              onTap: () {
                // Navigate to User Details
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Handle Logout
                _showToast();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // Implement search logic
              },
            ),
          ),
          Wrap(
            spacing: 8.0, // Gap between chips
            children: <Widget>[
              ActionChip(
                  label: Text('Favorites'),
              onPressed: () {
                setState(() {
                  showFavoritesOnly = !showFavoritesOnly;
                });
              },
              backgroundColor: showFavoritesOnly ? Colors.blue : Colors.grey[200],
              ),
              Chip(
                label: Text('Filter 1'),
                onDeleted: () {
                  // Filter logic for Filter 1
                },
              ),
              Chip(
                label: Text('Filter 2'),
                onDeleted: () {
                  // Filter logic for Filter 2
                },
              ),
              Chip(
                label: Text('Filter 3'),
                onDeleted: () {
                  // Filter logic for Filter 2
                },
              ),
              // Add more filters as needed
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: showFavoritesOnly ? widget.places.where((p) => p.isFavorite).length : places.length,
              itemBuilder: (context, index) {
                // Here we filter the places list based on the showFavoritesOnly flag.
                final place = showFavoritesOnly ? places.where((p) => p.isFavorite).toList()[index] : places[index];
                return Card(
                  // Card decoration and styling
                  child: ListTile(
                    onTap: () {
                      // Convert the JSON array to a list of Review objects
                      List<Review> reviews = reviewsJson.map((json) => Review.fromJson(json)).toList();
                      // Navigate to PlaceDetailScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaceDetailScreen(place: place, reviews: reviews), // You will need to pass the actual reviews here
                        ),
                      );
                    },
                    leading: Image.network(
                        place.imageUrl,
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50
                    ),
                    title: Text(place.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(place.description),
                        Row(
                          children: <Widget>[
                            Icon(Icons.star, color: Colors.amber, size: 15),
                            Text(' ${place.averageRating} (${place.reviewCount} reviews)'),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(place.isFavorite ? Icons.favorite : Icons.favorite_border),
                      color: place.isFavorite ? Colors.red : null,
                      onPressed: () => _toggleFavorite(place.id),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(String placeId) {
    setState(() {
      final placeIndex = places.indexWhere((place) => place.id == placeId);
      if (placeIndex != -1) {
        places[placeIndex].isFavorite = !places[placeIndex].isFavorite;
      }
    });
  }

  @override
  void dispose() {
    Navigator.pop(context, places); // Return the updated places list
    super.dispose();
  }

  void _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.redAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(width: 12.0),
          Text("Successfully Logged out."),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 5),
    );

    // To use the custom toast position if needed
    // ...
  }
}