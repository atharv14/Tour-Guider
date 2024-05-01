import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import '../models/place.dart';
import '../provider/PlaceProvider.dart';
import '../provider/UserProvider.dart'; // Import UserProvider
import 'LoginScreen.dart'; // Import login screen
// Import Individual place view screen
import 'PlaceCreationScreen.dart';
import 'PlaceDetailScreen.dart';
import 'UserProfileScreen.dart'; // Import User Profile screen

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
    // final placeProvider = Provider.of<PlaceProvider>(context, listen: false);
    // // Fetch places when the screen is loaded
    // placeProvider.fetchPlaces();
    _loadDataForCurrentUser();

    fToast = FToast();
    fToast.init(context); // Initialize FToast with context
  }

  // void _onSearch(String query) {
  //   if (query.isNotEmpty) {
  //     displayMode = DisplayMode.search;
  //     // Execute search logic and update places list
  //   } else {
  //     displayMode = DisplayMode.all;
  //     // Reset to show all places
  //   }
  // }
  //
  // void _onChipSelected(String category) {
  //   if (category == 'All') {
  //     displayMode = DisplayMode.all;
  //     // Logic to show all places
  //   } else {
  //     displayMode = DisplayMode.filtered;
  //     // Logic to filter places by category
  //   }
  // }

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
    final placeProvider = Provider.of<PlaceProvider>(context, listen: false);
    placeProvider.fetchPlaces();
  }

  @override
  Widget build(BuildContext context) {
    // final placeProvider = Provider.of<PlaceProvider>(context);
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
              onTap: () => _handleLogout(context),
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
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaceCreationScreen(),
                  ),
                );
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
        onSubmitted: (value) =>
            _executeSearch(), // Optional: trigger search on keyboard submit
      ),
    );
  }

  void _executeSearch() {
    String query = _searchController.text;
    final placeProvider = Provider.of<PlaceProvider>(context, listen: false);
    if (query.isNotEmpty) {
      placeProvider.searchPlaces(query);
    }
    placeProvider.fetchPlaces();
  }

  Widget _buildFilterChips() {
    final placeProvider = Provider.of<PlaceProvider>(context, listen: false);
    return Wrap(
      spacing: 8.0,
      children: <String>[
        'All',
        'Favorites',
        'RESTAURANT',
        'ATTRACTION',
        'SHOPPING',
        'OTHER'
      ].map((category) => _buildCategoryChip(category, placeProvider)).toList(),
    );
  }

  Widget _buildCategoryChip(String category, PlaceProvider placeProvider) {
    return ActionChip(
      label: Text(category),
      backgroundColor:
          selectedCategory == category ? Colors.blue : Colors.grey[200],
      onPressed: () {
        if (category == 'All') {
          displayMode = DisplayMode.all;
          placeProvider.fetchPlaces(); // Fetch all places
        } else if (category == 'Favorites') {
          displayMode = DisplayMode.filtered;
          placeProvider.filterFavoritePlaces(
              Provider.of<UserProvider>(context, listen: false)
                  .favoritePlaceIds);
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

  void showImageDialog(BuildContext context, ImageProvider image) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: PhotoView(
          imageProvider: image,
          backgroundDecoration: const BoxDecoration(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(String placeId) {
    final images =
        Provider.of<PlaceProvider>(context).getImagesForPlace(placeId);
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => showImageDialog(context, images[index]),
            child: Image(
              image: images[index],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceCard(Place place, List<Place> savedPlaces) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (place.imageUrl != null && place.imageUrl!.isNotEmpty) {
      Provider.of<PlaceProvider>(context, listen: false)
          .downloadImagesForPlace(place.id, place.imageUrl!);
    }
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
                _buildImageCarousel(place.id),
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
                          userProvider.fetchUserDetails();
                        },
                        tooltip: 'Add or Remove From Favorite',
                      );
                    },
                  ),
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
                            : 'No Ratings',
                      ),
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

  void _handleLogout(BuildContext context) {
    _showToast('Successfully Logged out.', Colors.redAccent);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _showToast(String message, Color color) {
    // Wrap the showToast call inside a Builder to get the correct context
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    });
  }
}
