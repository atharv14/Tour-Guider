import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../models/user.dart'; // Import User model class
import '../models/place.dart'; // Make sure this path matches your file structure
import '../models/review.dart'; // Make sure this path matches your file structure
import '../provider/UserProvider.dart'; // Import UserProvider
import 'add_edit_review_screen.dart';
import 'login_screen.dart'; // Import login screen
import 'place_list_view.dart'; //Import places view screen
import 'user_profile_screen.dart'; // Import User Profile screen
import 'review_detail_screen.dart'; // Import Review view Screen

class PlaceDetailScreen extends StatefulWidget {
  final Place place;
  final List<Review> reviews; // list of reviews for this place
  final List<Place> places;
  final Function(bool) onFavoriteChanged;

  const PlaceDetailScreen(
      {Key? key,
      required this.place,
      required this.reviews,
      required this.places,
      required this.onFavoriteChanged})
      : super(key: key);

  @override
  _PlaceDetailScreenState createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  late FToast fToast; // Declare FToast instance
  late List<Place> places;
  bool showFavoritesOnly = false;
  String selectedSortOption = 'New to Old'; // Default sort option

  @override
  void initState() {
    super.initState();
    places = widget.places;
    fToast = FToast();
    fToast.init(context); // Initialize FToast with context
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.name),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              // Go to Home
              // Go back to the PlacesViewScreen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => PlacesViewScreen(places: places)),
                ModalRoute.withName('/'),
              );
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
      body: Column(
        children: [
          // Top 40% of the screen for place details
          Expanded(
            flex: 40,
            child: Column(
              children: [
                // Image of the place (15% of the total screen)
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    // Image with horizontal scroll
                    SizedBox(
                      height: 100, // Adjust as needed
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.place.imageUrl
                            .length, // Assuming Place has a list of image URLs
                        itemBuilder: (context, imageIndex) {
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: Image.network(
                              widget.place
                                  .imageUrl[imageIndex], // Use each image URL
                              fit: BoxFit.cover,
                              width: 100, // Adjust as needed
                            ),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(widget.place.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border),
                      color:
                          widget.place.isFavorite ? Colors.red : Colors.black,
                      onPressed:
                          _toggleFavorite, // Updated to call the local method
                    ),
                  ],
                ),
                // Place name, category, and other details (remaining 25% of the top part)
                Expanded(
                  flex: 25,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Place name and category
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                widget.place.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(widget.place.category),
                              Text(widget.place.description),
                            ],
                          ),
                        ),
                        // Ratings, reviews, location, contact, and favorite button
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text('Rating: ${widget.place.averageRating}'),
                            Text('Reviews: ${widget.place.reviewCount}'),
                            Text('Location: ${widget.place.location}'),
                            Text('Contact: ${widget.place.contactInfo}'),
                            Text('Timings: ${widget.place.timings}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter section for sorting reviews
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Sort by: '),
                DropdownButton<String>(
                  value: selectedSortOption,
                  items: <String>['New to Old', 'Recent', 'Relevant']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSortOption = newValue!;
                    });
                    // Implement sorting logic here
                  },
                ),
              ],
            ),
          ),

          // reviews
          Expanded(
            flex: 60, // 60% of the screen for reviews
            child: ListView.builder(
              itemCount: widget.reviews.length,
              itemBuilder: (context, index) {
                final review = widget.reviews[index];
                // Assuming review has a list of image URLs named 'imageUrls'
                List<String> topThreeImages = review.images.take(3).toList();
                // Access user data using Provider
                final user = Provider.of<UserProvider>(context).user;
                return GestureDetector(
                  onTap: () {
                    // Navigate to ReviewDetailScreen with the current review
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ReviewDetailScreen(review: review),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // User user = _getUserFromReview(review);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserProfileScreen(),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      user!.profilePhotoUrl.isNotEmpty
                                          ? NetworkImage(user.profilePhotoUrl)
                                          : null,
                                  child: user.profilePhotoUrl.isEmpty
                                      ? Text(user.initials())
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  review.subject,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${review.rating} Stars',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.amber),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(review.content),
                          // if (topThreeImages.isNotEmpty)
                          SizedBox(
                            height: 100, // Adjust the size as needed
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: topThreeImages.length,
                              itemBuilder: (context, imageIndex) {
                                return Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black, // Color of the border
                                      width: 2, // Width of the border
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        8), // Apply border radius to make the corners rounded (optional)
                                  ),
                                  child: Image.network(
                                    topThreeImages[imageIndex],
                                    fit: BoxFit.cover,
                                    width: 100, // Adjust the size as needed
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle add review button press
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEditReviewScreen()),
              );
            },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _toggleFavorite() {
    setState(() {
      widget.place.isFavorite = !widget.place.isFavorite;
      widget.onFavoriteChanged(widget.place.isFavorite);
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
