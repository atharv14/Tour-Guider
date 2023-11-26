import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../models/place.dart'; // Import Place model class
import '../models/review.dart'; // Import Review model class
import '../provider/UserProvider.dart'; // Import UserProvider
import 'login_screen.dart'; // Import login screen
import 'place_detail_screen.dart'; // Import Individual place view screen
import 'user_profile_screen.dart'; // Import User Profile screen

class PlacesViewScreen extends StatefulWidget {
  final List<Place> places;

  const PlacesViewScreen({super.key, required this.places});

  @override
  _PlacesViewScreenState createState() => _PlacesViewScreenState();
}

class _PlacesViewScreenState extends State<PlacesViewScreen> {
  late List<Place> places;
  late FToast fToast;
  bool showFavoritesOnly = false; //Declare FToast instance

  @override
  void initState() {
    super.initState();
    places = widget.places;
    fToast = FToast();
    fToast.init(context); // Initialize FToast with context
  }

  @override
  Widget build(BuildContext context) {
    // Access user data using Provider
    final user = Provider.of<UserProvider>(context).user;

    List<Map<String, dynamic>> reviewsJson = [
      {
        'id': 'review1',
        'userId': 'user1',
        'userName': 'User One',
        'subject': 'Review Subject',
        'content':
            'This place is great! I had an excellent time and the staff were wonderful.',
        'rating': 5.0,
        'date': '2021-07-16T19:20:30+00:00',
      },
      // ... other reviews
    ];
    //print('Number of places: ${widget.places.length}'); // Add this line
    return Scaffold(
      appBar: AppBar(
        title: const Text('Places'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              // Go to Home
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to user details
              // Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Pass the mock user object
                  builder: (context) => UserProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
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
            const DrawerHeader(
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
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                // Navigate to Home
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('User Details'),
              onTap: () {
                // Navigate to User Details
                // Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Pass the mock user object
                    builder: (context) => UserProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
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
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
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
                label: const Text('Favorites'),
                onPressed: () {
                  setState(() {
                    showFavoritesOnly = !showFavoritesOnly;
                  });
                },
                backgroundColor:
                    showFavoritesOnly ? Colors.blue : Colors.grey[200],
              ),
              Chip(
                label: const Text('Filter 1'),
                onDeleted: () {
                  // Filter logic for Filter 1
                },
              ),
              Chip(
                label: const Text('Filter 2'),
                onDeleted: () {
                  // Filter logic for Filter 2
                },
              ),
              Chip(
                label: const Text('Filter 3'),
                onDeleted: () {
                  // Filter logic for Filter 2
                },
              ),
              // Add more filters as needed
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: showFavoritesOnly
                  ? widget.places.where((p) => p.isFavorite).length
                  : places.length,
              itemBuilder: (context, index) {
                // Here we filter the places list based on the showFavoritesOnly flag.
                final place = showFavoritesOnly
                    ? places.where((p) => p.isFavorite).toList()[index]
                    : places[index];
                return Card(
                  child: InkWell(
                    // Wrap with InkWell for onTap functionality
                    onTap: () {
                      // Convert the JSON array to a list of Review objects
                      List<Review> reviews = reviewsJson
                          .map((json) => Review.fromJson(json))
                          .toList();
                      // Navigate to PlaceDetailScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PlaceDetailScreen(
                                  place: place,
                                  reviews: reviews,
                                  onFavoriteChanged: (isFavorite) {
                                    _updateFavoriteStatus(place.id, isFavorite);
                                  },
                                places: places,
                              ),
                        ),
                      );
                    },
                    // Card decoration and styling
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            // Image with horizontal scroll
                            SizedBox(
                              height: 100, // Adjust as needed
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: place.imageUrl
                                    .length, // Assuming Place has a list of image URLs
                                itemBuilder: (context, imageIndex) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Image.network(
                                      place.imageUrl[
                                          imageIndex], // Use each image URL
                                      fit: BoxFit.cover,
                                      width: 100, // Adjust as needed
                                    ),
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(place.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border),
                              color:
                                  place.isFavorite ? Colors.red : Colors.black,
                              onPressed: () => _toggleFavorite(place.id),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      place.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(place.description),
                                  ],
                                ),
                              ),
                              // Column for Rating stars and number of reviews
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildRatingStars(place.averageRating),
                                  const SizedBox(height: 4),
                                  Text(
                                      place.averageRating.toStringAsFixed(1)),
                                  Text('${place.reviewCount} Reviews'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildRatingStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber));
    }

    if (hasHalfStar) {
      stars.add(const Icon(Icons.star_half, color: Colors.amber));
    }

    while (stars.length < 5) {
      stars.add(const Icon(Icons.star_border, color: Colors.amber));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  void _updateFavoriteStatus(String placeId, bool isFavorite) {
    setState(() {
      final placeIndex = places.indexWhere((place) => place.id == placeId);
      if (placeIndex != -1) {
        places[placeIndex].isFavorite = isFavorite;
      }
    });
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
      child: const Row(
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
      toastDuration: const Duration(seconds: 5),
    );

    // To use the custom toast position if needed
    // ...
  }
}
