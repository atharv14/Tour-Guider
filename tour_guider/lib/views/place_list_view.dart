import 'dart:async';

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
  const PlacesViewScreen({Key? key}) : super(key: key);

  @override
  _PlacesViewScreenState createState() => _PlacesViewScreenState();
}

enum DisplayMode { all, filtered, search }

class _PlacesViewScreenState extends State<PlacesViewScreen> {
  Timer? _debounce;
  late FToast fToast;
  final TextEditingController _searchController = TextEditingController();
  DisplayMode displayMode = DisplayMode.all;

  // bool showFavoritesOnly = false; //Declare FToast instance
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    final placeProvider = Provider.of<PlaceProvider>(context, listen: false);
    // Fetch places when the screen is loaded
    placeProvider.fetchPlaces();
    _loadDataForCurrentUser();

    fToast = FToast();
    fToast.init(context); // Initialize FToast with context
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      displayMode = DisplayMode.search;
      // Execute search logic and update places list
    } else {
      displayMode = DisplayMode.all;
      // Reset to show all places
    }
  }

  void _onChipSelected(String category) {
    if (category == 'All') {
      displayMode = DisplayMode.all;
      // Logic to show all places
    } else {
      displayMode = DisplayMode.filtered;
      // Logic to filter places by category
    }
  }

  Future<void> _loadDataForCurrentUser() async {
    final placeProvider = Provider.of<PlaceProvider>(context, listen: false);
    // Reset the selected category to 'All'
    setState(() {
      selectedCategory = '';
    });
    // Fetch all places for the current user
    await placeProvider.fetchPlaces();
  }

  void refreshUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.fetchUserDetails(); // Re-fetch user details
    // Optionally, you might want to refresh places as well
    final placeProvider = Provider.of<PlaceProvider>(context, listen: false);
    placeProvider.fetchPlaces();
  }

  @override
  Widget build(BuildContext context) {
    final placeProvider = Provider.of<PlaceProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isAdmin = Provider.of<UserProvider>(context).user?.isAdmin ?? false;
    // final isAdmin = false;

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
              final placeProvider =
                  Provider.of<PlaceProvider>(context, listen: false);
              placeProvider.fetchPlaces();
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
                  builder: (context) =>
                      UserProfileScreen(onBack: refreshUserData),
                ),
              );
            },
            tooltip: 'User Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(),
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
                final placeProvider =
                    Provider.of<PlaceProvider>(context, listen: false);
                placeProvider.fetchPlaces();
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
                    builder: (context) =>
                        UserProfileScreen(onBack: refreshUserData),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _handleLogout(),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          // Use Consumer to listen for changes in PlaceProvider
          Expanded(
            child: Consumer<PlaceProvider>(
              builder: (context, placeProvider, child) {
                List<Place> placesToShow;

                // Determine which list of places to show based on the display mode
                switch (displayMode) {
                  case DisplayMode.all:
                    placesToShow = placeProvider.places;
                    break;
                  case DisplayMode.filtered:
                  // Logic to get filtered places based on selected category
                  placesToShow = placeProvider.places;
                    break;
                  case DisplayMode.search:
                  // Logic to get search results
                    placesToShow = placeProvider.searchResults;
                    break;
                  default:
                    placesToShow = placeProvider.places;
                }

                // Build ListView with the appropriate list of places
                return ListView.builder(
                  itemCount: placeProvider.places.length,
                  itemBuilder: (context, index) {
                    final place = placesToShow[index];
                    final savedPlaces = userProvider.user?.savedPlaces ?? [];
                    return _buildPlaceCard(place, savedPlaces);
                  },
                );
              },
            ),
          ),

          // Expanded(
          //   child: ListView.builder(
          //     itemCount: placeProvider.places.length,
          //     itemBuilder: (context, index) {
          //       final place = placeProvider.places[index];
          //       return _buildPlaceCard(
          //           place, userProvider.user?.savedPlaces ?? []);
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
        controller: _searchController, // Use the TextEditingController
        decoration: InputDecoration(
          labelText: 'Search',
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: _executeSearch, // Add the search execution function here
          ),
        ),
        onSubmitted: (value) => _executeSearch(), // Optional: trigger search on keyboard submit
      ),
    );
  }

  void _executeSearch() {
    String query = _searchController.text;
    if (query.isNotEmpty) {
      Provider.of<PlaceProvider>(context, listen: false).searchPlaces(query);
    }
  }

  Widget _buildFilterChips() {
    final placeProvider = Provider.of<PlaceProvider>(context, listen: false);
    return Wrap(
      spacing: 8.0,
      children: <String>['All', 'Favorites', 'RESTAURANT', 'ATTRACTION', 'SHOPPING', 'OTHER']
          .map((category) => _buildCategoryChip(category, placeProvider)).toList(),
    );
  }

  Widget _buildCategoryChip(String category, PlaceProvider placeProvider) {
    return ActionChip(
      label: Text(category),
      backgroundColor: selectedCategory == category ? Colors.blue : Colors.grey[200],
      onPressed: () {
        if (category == 'All') {
          displayMode = DisplayMode.all;
          placeProvider.fetchPlaces(); // Fetch all places
        } else if (category == 'Favorites') {
          displayMode = DisplayMode.filtered;
          placeProvider.filterFavoritePlaces(
              Provider.of<UserProvider>(context, listen: false).favoritePlaceIds);
        } else {
          displayMode = DisplayMode.filtered;
          placeProvider.filterPlacesByCategory(category);
        }
        setState(() => selectedCategory = category);
      },
    );
  }

  void refreshPlaces() {
    final placeProvider = Provider.of<PlaceProvider>(context, listen: false);
    placeProvider.fetchPlaces(); // Re-fetch all places
  }

  Widget _buildPlaceCard(Place place, List<Place> savedPlaces) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // var isFavorite = savedPlaces.any((savedPlace) => savedPlace.id == place.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailScreen(
              placeId: place.id,
              onBack: refreshPlaces,
            ),
          ),
        ).then((_) {
          // This callback is executed when PlaceDetailScreen is popped from the navigation stack.
          // It ensures that the UI is updated to reflect any changes made in the PlaceDetailScreen.
          setState(() {});
        });
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
                    itemCount: place.imageUrl?.length,
                    itemBuilder: (context, index) {
                      // Check if imageUrl is not null before accessing it
                      final image = place.imageUrl?[index];
                      if (image != null) {
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.network(
                            image,
                            fit: BoxFit.cover,
                            width: 100, // Adjust as needed
                            errorBuilder: (context, error, stackTrace) {
                              // Return an error widget here if the image fails to load
                              return const Icon(Icons
                                  .broken_image); // Placeholder for a broken image
                            },
                          ),
                        );
                      } else {
                        // Handle the case where imageUrl is null
                        return const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons
                              .image_not_supported), // Placeholder for no image
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Selector<UserProvider, bool>(
                    selector: (_, userProvider) =>
                        userProvider.isFavoritePlace(place.id),
                    builder: (context, isFavorite, child) {
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          userProvider.toggleFavoriteStatus(place).then((_) {
                            // No need to call setState() if using provider correctly.
                            setState(() {});
                          });
                        },
                        tooltip: 'Add or Remove From Favorite',
                      );
                    },
                  ),

                  // child: IconButton(
                  //   icon: Icon(
                  //     isFavorite ? Icons.favorite : Icons.favorite_border,
                  //     color: isFavorite ? Colors.red : Colors.white,
                  //   ),
                  //   onPressed: () async {
                  //     bool success = await userProvider.toggleFavoriteStatus(place);
                  //     if (success) {
                  //       // If you have a setState call, use it to update the UI
                  //       setState(() {
                  //         isFavorite = !isFavorite;
                  //         _showToast("Place saved successfully!", Colors.greenAccent);
                  //       });
                  //     } else {
                  //       // Handle failure
                  //       debugPrint("Failed to update favorite status");
                  //
                  //     }
                  //   },
                  //   tooltip: 'Add to Favorite',
                  // ),
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
                        Text(place.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Category: ${place.category}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(place.description),
                        Text('Location: ${place.location}'),
                        Text('Contact: ${place.formattedContactInfo}'),
                        // Text('Timings: ${place.operatingHours}'),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildRatingStars(place.averageRating),
                      const SizedBox(height: 4),
                      Text(
                        place.averageRating != null && place.averageRating! > 0
                            ? place.averageRating!.toStringAsFixed(1)
                            : 'N/A',
                      ),
                      Text('${place.totalReviews} Reviews'),
                      // Wrap the timings Text widget in an Expanded to prevent overflow
                      // Expanded(
                      //   child: Text(
                      //     'Timings: ${place.operatingHours}',
                      //     textAlign: TextAlign.right,
                      //     overflow: TextOverflow
                      //         .ellipsis, // Add an ellipsis when the text overflows
                      //   ),
                      // ),
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

  Widget _buildRatingStars(double? rating) {
    if (rating == null) {
      // Return a widget or an empty container if rating is null
      // return const Text('No rating');
      // Or, return an empty container for showing nothing
      return Container();
    }
    List<Widget> stars = [];
    int? fullStars = rating.floor();
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
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _handleLogout() {
    _showToast('Successfully Logged out.', Colors.redAccent);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _showToast(String message, Color color) {
    // Wrap the showToast call inside a Builder to get the correct context
    Builder(
      builder: (BuildContext context) {
        fToast.showToast(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: color,
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
        return Container(); // This container is just a placeholder
      },
    );
  }
}
