import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
// Import Place model class
// Import Review model class
import '../models/place.dart';
import '../provider/PlaceProvider.dart';
import '../provider/UserProvider.dart'; // Import UserProvider
import 'login_screen.dart'; // Import login screen
// Import Individual place view screen
import 'place_detail_screen.dart';
import 'user_profile_screen.dart'; // Import User Profile screen

class PlacesViewScreen extends StatefulWidget {

  const PlacesViewScreen({super.key});

  @override
  _PlacesViewScreenState createState() => _PlacesViewScreenState();
}

class _PlacesViewScreenState extends State<PlacesViewScreen> {
  late FToast fToast;
  bool showFavoritesOnly = false; //Declare FToast instance
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();

    // Fetch places when the screen is loaded
    final placeProvider = Provider.of<PlaceProvider>(context, listen: false);
    placeProvider.fetchPlaces();

    fToast = FToast();
    fToast.init(context); // Initialize FToast with context
  }

  @override
  Widget build(BuildContext context) {

    final places = Provider.of<PlaceProvider>(context).places;
    final userProvider = Provider.of<UserProvider>(context);
    final isAdmin = true;

    // Add a debug print statement to check the isAdmin flag
    debugPrint('isAdmin: $isAdmin');

    return Scaffold(
        appBar: AppBar(
          title: const Text('Places'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                // Go to Home
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
                    // Pass the  user object
                    builder: (context) => const UserProfileScreen(),
                  ),
                );
              },
              tooltip: 'User Profile',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _handleLogout(context),
              tooltip: 'Logout',
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
                      builder: (context) => const UserProfileScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () => _handleLogout(context),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildFilterChips(userProvider.user?.savedPlaces ?? []),
            // Wrap(
            //   spacing: 8.0, // Gap between chips
            //   children: <Widget>[
            //     ActionChip(
            //       label: const Text('Favorites'),
            //       onPressed: () {
            //         setState(() {
            //           showFavoritesOnly = !showFavoritesOnly;
            //         });
            //       },
            //       backgroundColor:
            //           showFavoritesOnly ? Colors.blue : Colors.grey[200],
            //     ),
            //     ActionChip(
            //       label: const Text('Restaurants'),
            //       onPressed: () {
            //         setState(() {
            //           showFavoritesOnly = !showFavoritesOnly;
            //         });
            //       },
            //       backgroundColor:
            //           showFavoritesOnly ? Colors.blue : Colors.grey[200],
            //     ),
            //     ActionChip(
            //       label: const Text('Attraction'),
            //       onPressed: () {
            //         setState(() {
            //           showFavoritesOnly = !showFavoritesOnly;
            //         });
            //       },
            //       backgroundColor:
            //           showFavoritesOnly ? Colors.blue : Colors.grey[200],
            //     ),
            //     ActionChip(
            //       label: const Text('Shopping'),
            //       onPressed: () {
            //         setState(() {
            //           showFavoritesOnly = !showFavoritesOnly;
            //         });
            //       },
            //       backgroundColor:
            //           showFavoritesOnly ? Colors.blue : Colors.grey[200],
            //     ),
            //     // Add more filters as needed
            //   ],
            // ),
            Expanded(
              child: ListView.builder(
                itemCount: places.length,
                itemBuilder: (context, index) {
                  return _buildPlaceCard(places[index]);
                },
              ),
            ),
            // Expanded(
            //   child: ListView.builder(
            //     itemCount: showFavoritesOnly
            //         ? places.where((p) => p.isFavorite).length
            //         : places.length,
            //     itemBuilder: (context, index) {
            //       // Here we filter the places list based on the showFavoritesOnly flag.
            //       final place = showFavoritesOnly
            //           ? places.where((p) => p.isFavorite).toList()[index]
            //           : places[index];
            //       return Card(
            //         child: InkWell(
            //           // Wrap with InkWell for onTap functionality
            //           onTap: () {
            //             // Convert the JSON array to a list of Review objects
            //             List<Review> reviews = reviewsJson
            //                 .map((json) => Review.fromJson(json))
            //                 .toList();
            //             // Navigate to PlaceDetailScreen
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                 builder: (context) => PlaceDetailScreen(
            //                   place: place,
            //                   reviews: reviews,
            //                   onFavoriteChanged: (isFavorite) {
            //                     _updateFavoriteStatus(place.id, isFavorite);
            //                   },
            //                   places: places,
            //                 ),
            //               ),
            //             );
            //           },
            //           // Card decoration and styling
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Stack(
            //                 alignment: Alignment.topRight,
            //                 children: [
            //                   // Image with horizontal scroll
            //                   SizedBox(
            //                     height: 100, // Adjust as needed
            //                     child: ListView.builder(
            //                       scrollDirection: Axis.horizontal,
            //                       itemCount: place.imageUrl
            //                           .length, // Assuming Place has a list of image URLs
            //                       itemBuilder: (context, imageIndex) {
            //                         return Padding(
            //                           padding: const EdgeInsets.all(8),
            //                           child: Image.network(
            //                             place.imageUrl[
            //                                 imageIndex], // Use each image URL
            //                             fit: BoxFit.cover,
            //                             width: 100, // Adjust as needed
            //                             errorBuilder: (context, error, stackTrace) {
            //                               // Return an error widget here if the image fails to load
            //                               return const Icon(Icons.broken_image); // Placeholder for a broken image
            //                             },
            //                           ),
            //                         );
            //                       },
            //                     ),
            //                   ),
            //                   IconButton(
            //                     icon: Icon(place.isFavorite
            //                         ? Icons.favorite
            //                         : Icons.favorite_border),
            //                     color: place.isFavorite
            //                         ? Colors.red
            //                         : Colors.black,
            //                     onPressed: () {
            //
            //                     },
            //                     tooltip: 'Add to Favorite',
            //                   ),
            //                 ],
            //               ),
            //               Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Row(
            //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                   children: [
            //                     Expanded(
            //                       child: Column(
            //                         crossAxisAlignment:
            //                             CrossAxisAlignment.start,
            //                         children: [
            //                           Text(
            //                             place.name,
            //                             style: const TextStyle(
            //                                 fontWeight: FontWeight.bold),
            //                           ),
            //                           Text(place.description),
            //                         ],
            //                       ),
            //                     ),
            //                     // Column for Rating stars and number of reviews
            //                     Column(
            //                       crossAxisAlignment: CrossAxisAlignment.end,
            //                       children: [
            //                         _buildRatingStars(place.averageRating),
            //                         const SizedBox(height: 4),
            //                         Text(
            //                             place.averageRating.toStringAsFixed(1)),
            //                         Text('${place.reviewCount} Reviews'),
            //                       ],
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
        floatingActionButton: isAdmin
            ? FloatingActionButton(
                onPressed: () {
                  //ToDo Handle adding new Places

                },
                tooltip: 'Add New Place',
                child: const Icon(Icons.add),
              )
            : null,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'Search',
          suffixIcon: Icon(Icons.search),
        ),
        onChanged: (value) {
          Provider.of<PlaceProvider>(context, listen: false).searchPlaces(value);
        },
      ),
    );
  }

  Widget _buildFilterChips(List<String> favoritePlaceIds) {
    return Wrap(
      spacing: 8.0,
      children: <Widget>[
        _buildCategoryChip('Favorites', favoritePlaceIds),
        _buildCategoryChip('Restaurants', favoritePlaceIds),
        _buildCategoryChip('Attraction', favoritePlaceIds),
        _buildCategoryChip('Shopping', favoritePlaceIds),
      ],
    );
  }
  Widget _buildCategoryChip(String category, List<String> favoritePlaceIds) {
    return ActionChip(
      label: Text(category),
      onPressed: () {
        if (category == 'Favorites') {
          Provider.of<PlaceProvider>(context, listen: false).filterFavoritePlaces(favoritePlaceIds);
        } else {
          Provider.of<PlaceProvider>(context, listen: false).filterPlacesByCategory(category);
        }
        setState(() => selectedCategory = category);
      },
      backgroundColor: selectedCategory == category ? Colors.blue : Colors.grey[200],
    );
  }

  Widget _buildPlaceCard(Place place) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isFavorite = userProvider.user?.savedPlaces.contains(place.id) ?? false;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailScreen(
              place: place,
              onFavoriteChanged: (isFavorite) {
                _updateFavoriteStatus(place.id, isFavorite);
              },
            ),
          ),
        );
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: place.imageUrl.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.network(
                          place.imageUrl[index],
                          fit: BoxFit.cover,
                          width: 100,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image);
                          },
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.black,
                  ),
                  onPressed: () async {
                    // Favorite button logic
                    bool success = await userProvider.savePlaceForUser(place.id);
                    if (success) {
                      // Optionally, update UI or local state to reflect the new favorite status
                      await userProvider.updateFavoriteStatus(place.id, !isFavorite);
                      setState(() {});
                    } else {
                      // Handle failure (e.g., show a message)
                      debugPrint("Adding to save place FAILED");
                    }
                  },
                  tooltip: 'Add to Favorite',
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
                        Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(place.description),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildRatingStars(place.averageRating),
                      const SizedBox(height: 4),
                      Text(place.averageRating.toStringAsFixed(1)),
                      Text('${place.totalReviews} Reviews'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _updateFavoriteStatus(String placeId, bool isFavorite) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (isFavorite) {
      // Add placeId to user's savedPlaces and update backend
    } else {
      // Remove placeId from user's savedPlaces and update backend
    }
    // Update local state
    userProvider.updateFavoriteStatus(placeId, isFavorite);
  }


  // void _fetchAndDisplayFavorites() {
  //   // Assuming you have a method in PlaceProvider to fetch favorite places
  //   final placeProvider = Provider.of<PlaceProvider>(context, listen: false);
  //   // Call the method to fetch favorite places
  //   // You may need to pass user-specific data, such as user ID or favorite place IDs
  //   placeProvider.fetchFavoritePlaces(/* user.favoritePlaceIds */);
  //
  //   setState(() {
  //     selectedCategory = 'Favorites';
  //   });
  // }
  //
  // void _filterPlacesByCategory(String category) {
  //   final placeProvider = Provider.of<PlaceProvider>(context, listen: false);
  //   placeProvider.filterPlacesByCategory(category);
  //
  //   setState(() {
  //     selectedCategory = category;
  //   });
  // }

  // Widget _buildPlaceCard(Place place) {
  //   return Card(
  //     child: ListTile(
  //       title: Text(place.name),
  //       subtitle: Text(place.description),
  //       trailing: IconButton(
  //         icon: Icon(
  //           place.isFavorite ? Icons.favorite : Icons.favorite_border,
  //           color: place.isFavorite ? Colors.red : null,
  //         ),
  //         onPressed: () {
  //           // Handle favorite logic
  //         },
  //       ),
  //       onTap: () {
  //         // Navigate to PlaceDetailScreen
  //       },
  //     ),
  //   );
  // }

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

  @override
  void dispose() {
    super.dispose();
  }

  void _handleLogout(BuildContext context) {
    _showToast('Successfully Logged out.');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _showToast(String message) {
    fToast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.redAccent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check),
            const SizedBox(width: 12.0),
            Text(message),
          ],
        ),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 5),
    );
  }
}
