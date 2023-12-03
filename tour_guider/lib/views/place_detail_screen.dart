import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
//
import '../models/place.dart'; //
import '../models/review.dart'; //
import '../provider/UserProvider.dart'; // Import UserProvider
import '../provider/ReviewProvider.dart'; // Import ReviewProvider
import 'add_edit_review_screen.dart';
import 'login_screen.dart'; // Import login screen
import 'place_list_view.dart'; //Import places view screen
import 'user_profile_screen.dart'; // Import User Profile screen
import 'review_detail_screen.dart'; // Import Review view Screen

class PlaceDetailScreen extends StatefulWidget {
  final Place place;
  final Function(bool) onFavoriteChanged;

  const PlaceDetailScreen(
      {super.key,
      required this.place,
      required this.onFavoriteChanged});

  @override
  _PlaceDetailScreenState createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  late FToast fToast; // Declare FToast instance
  late List<Place> places;
  bool showFavoritesOnly = false;
  String selectedSortOption = 'New to Old';

  var isAdmin = true; // Default sort option

  @override
  void initState() {
    super.initState();
    // places = widget.places;
    fToast = FToast();
    fToast.init(context); // Initialize FToast with context
    // Future.microtask(() =>
    //     Provider.of<ReviewProvider>(context, listen: false)
    //         .fetchReviewsForPlace(widget.place.id));
  }

  @override
  Widget build(BuildContext context) {
    // Access ReviewProvider to get the list of reviews
    List<Review> reviews = Provider.of<ReviewProvider>(context).reviews;
    // Access user data using Provider
    final userProvider = Provider.of<UserProvider>(context);
    final bool isFavorite = userProvider.user?.savedPlaces.contains(widget.place.id) ?? false;
    // final bool isAdmin = user?.isAdmin ?? true;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBackPressed, // Call this when back button is pressed
        ),
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
                    builder: (context) => const PlacesViewScreen()),
                ModalRoute.withName('/'),
              );
            },
            tooltip: 'Home',
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to user details
              // Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfileScreen(),
                ),
              );
            },
            tooltip: 'User Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Handle logout
              _showToast();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            tooltip: 'Logout',
          ),
          if (isAdmin)
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  //ToDo Handle Place Settings

                },
                tooltip: 'Edit the place',
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
                              errorBuilder: (context, error, stackTrace) {
                                // Return an error widget here if the image fails to load
                                return const Icon(Icons
                                    .broken_image); // Placeholder for a broken image
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.black,
                      ),
                      onPressed: () async {
                        bool success = await userProvider.savePlaceForUser(widget.place.id);
                        if (success) {
                          await userProvider.updateFavoriteStatus(widget.place.id, !isFavorite);
                          setState(() {});
                        } else {
                          // Handle failure (e.g., show a message)
                        }
                      }, // Updated to call the local method
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
                            Text('Reviews: ${widget.place.totalReviews}'),
                            Text('Location: ${widget.place.location}'),
                            Text('Contact: ${widget.place.contactInfo}'),
                            Text('Operating Hours: ${widget.place.operatingHours}'),
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
          // Expanded(
          //   flex: 60, // 60% of the screen for reviews
          //   child: ListView.builder(
          //     itemCount: widget.reviews.length,
          //     itemBuilder: (context, index) {
          //       final review = widget.reviews[index];
          //       // Assuming review has a list of image URLs named 'imageUrls'
          //       List<String> topThreeImages = review.images.take(3).toList();
          //       // Debugging the image URL
          //       print('Image URL: ${topThreeImages[index]}');
          //       // Access user data using Provider
          //       final user = Provider.of<UserProvider>(context).user;
          //       return GestureDetector(
          //         onTap: () {
          //           // Navigate to ReviewDetailScreen with the current review
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (context) =>
          //                   ReviewDetailScreen(review: review),
          //             ),
          //           );
          //         },
          //         child: _buildReviewCard(context, review),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle add review button press
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditReviewScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, Review review) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigate to UserProfileScreen with the user ID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserProfileScreen()),
                    );
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey, // Default background color
                    backgroundImage: review.userProfilePhoto.isNotEmpty
                        ? NetworkImage(review.userProfilePhoto)
                        : null,
                    child: review.userProfilePhoto.isEmpty
                        ? Text(
                            review.getUserInitials(),
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.subject,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (review.images.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 100, // Fixed height for image carousel/slider
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: review.images.map((imageUrl) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Image.network(
                                  imageUrl,
                                  width: 100, // Fixed width for each image
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons
                                        .broken_image); // Placeholder for a broken image
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Rating in the top right corner
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    review.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            // Review content
            const SizedBox(height: 10),
            Text(review.content),
          ],
        ),
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

  // void _toggleFavorite() {
  //   setState(() {
  //     widget.place.isFavorite = !widget.place.isFavorite;
  //     widget.onFavoriteChanged(widget.place.isFavorite);
  //   });
  // }

  @override
  void dispose() {
    // Navigator.pop(context, places); // Return the updated places list
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

  void _onBackPressed() {
    Navigator.pop(context, places); // Return the updated places list
  }
}
