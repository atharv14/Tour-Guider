import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:tour_guider/views/ReviewDetailScreen.dart';
import '../models/attraction.dart';
import '../models/restaurant.dart';
import '../models/shopping.dart';
import '../models/user.dart'; // user model
import '../models/place.dart'; // place model
import '../models/review.dart'; // review model
import '../provider/PlaceProvider.dart'; // Import PlaceProvider
import '../provider/UserProvider.dart'; // Import UserProvider
import '../provider/ReviewProvider.dart'; // Import ReviewProvider
import 'AddEditReviewScreen.dart'; // Import Add or Edit Review screen
import 'LoginScreen.dart'; // Import login screen
import 'PlacesViewScreen.dart'; //Import places view screen
import 'UserProfileScreen.dart'; // Import User Profile screen
import 'place_update_screen.dart'; // Import place update screen

class PlaceDetailScreen extends StatefulWidget {
  final String placeId;
  final VoidCallback onBack;

  const PlaceDetailScreen({
    super.key,
    required this.placeId,
    required this.onBack,
  });

  @override
  _PlaceDetailScreenState createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  late FToast fToast; // Declare FToast instance
  late Future<Place?> _placeFuture;
  late Future<List<Review>> _reviewsFuture;

  // bool showFavoritesOnly = false;
  String selectedSortOption = 'New to Old'; // Default sort option

  @override
  void initState() {
    super.initState();
    debugPrint("Init stated called");
    fToast = FToast();
    fToast.init(context); // Initialize FToast with context
    setupData();
  }

  void setupData() {
    final placeProvider = Provider.of<PlaceProvider>(context, listen: false);
    _placeFuture = placeProvider.fetchPlaceById(widget.placeId);
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    _reviewsFuture = reviewProvider.fetchReviewsForPlace(widget.placeId);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isAdmin = userProvider.user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.onBack(); // Notify PlacesViewScreen to re-fetch places
            Navigator.pop(context); // Navigate back
          },
        ),
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
              _handleLogout(context);
            },
            tooltip: 'Logout',
          ),
          if (isAdmin) // Check if admin
            FutureBuilder<Place?>(
              future: _placeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const IconButton(
                    icon: Icon(Icons.hourglass_empty),
                    onPressed: null,
                  );
                } else if (snapshot.hasError) {
                  return const IconButton(
                    icon: Icon(Icons.error),
                    onPressed: null,
                  );
                } else if (snapshot.hasData) {
                  return IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UpdatePlaceScreen(place: snapshot.data!),
                        ),
                      ).then((_) {
                        // Refresh the place details after updates
                        setupData();
                      }, onError: (e) {
                        debugPrint('Error on setupData: $e');
                      });
                    },
                    tooltip: 'Edit the place',
                  );
                } else {
                  return const IconButton(
                    icon: Icon(Icons.place),
                    onPressed: null,
                  );
                }
              },
            ),
        ],
      ),
      body: FutureBuilder<Place?>(
        future: _placeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData) {
            return const Text('Place not found');
          }

          final place = snapshot.data!;

          final bool isFavorite =
              userProvider.user?.savedPlaces?.contains(place.id) ?? false;

          debugPrint("Place before building Place details: $place");

          return Column(
            children: [
              // Top 40% of the screen for place detail screen
              Expanded(
                  child: _buildPlaceDetails(place, isFavorite, userProvider)),
              // Filter section for sorting reviews
              // Container(
              //   padding: const EdgeInsets.all(10),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.end,
              //     children: [
              //       const Text('Sort by: '),
              //       DropdownButton<String>(
              //         value: selectedSortOption,
              //         items: <String>['New to Old', 'Recent', 'Relevant']
              //             .map<DropdownMenuItem<String>>((String value) {
              //           return DropdownMenuItem<String>(
              //             value: value,
              //             child: Text(value),
              //           );
              //         }).toList(),
              //         onChanged: (String? newValue) {
              //           setState(() {
              //             selectedSortOption = newValue!;
              //           });
              //           // Implement sorting logic here
              //         },
              //       ),
              //     ],
              //   ),
              // ),

              // Bottom 60% of the screen for review section
              Expanded(
                child: _buildReviewsSection(widget.placeId),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to AddEditReviewScreen with 'null' indicating a new review
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditReviewScreen(
                review: null,
                placeId: widget.placeId,
              ),
            ),
          ).then((_) {
            // Refresh the place reviews details after updates
            _refreshReviews();
          });
        },
        tooltip: 'Add new Review',
        child: const Text('Write a Review'),
      ),
    );
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
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => showImageDialog(context, images[index]),
            child: Image(
              image: images[index], //width: 100, height: 100,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildCategorySpecificDetails(Place place) {
    List<Widget> details = [];
    debugPrint(
        "Place: $place \nProcessing place of category: ${place.category}");
    if (place is Attraction) {
      debugPrint("It's an attraction.");
      details.add(buildBoldText('Theme: ', place.theme));
      details.add(buildBoldText('Entry Fee: ', "\$${place.entryFee}"));
      details.add(
          buildBoldText('Kid Friendly: ', place.kidFriendly ? 'Yes' : 'No'));
      details.add(buildBoldText(
          'Parking Available: ', place.parkingAvailable ? 'Yes' : 'No'));
    } else if (place is Restaurant) {
      debugPrint("It's a restaurant.");
      details.add(buildBoldText('Cuisines: ', place.cuisines.join(', ')));
      details.add(buildBoldText('Price for Two: ', '\$${place.priceForTwo}'));
      details.add(buildBoldText('Type of Restaurant: ', place.type));
      details.add(buildBoldText('Reservations Required: ',
          place.reservationsRequired ? 'Yes' : 'No'));
    } else if (place is Shopping) {
      debugPrint("It's a shopping.");
      details.add(buildBoldText(
          'Associated Brands: ', place.associatedBrands.join(', ')));
    }
    return details;
  }

  Widget buildBoldText(String label, String value) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          TextSpan(
            text: value,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceDetails(place, bool isFavorite, UserProvider userProvider) {
    List<Widget> categoryDetails = _buildCategorySpecificDetails(place);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (place.imageUrl != null && place.imageUrl!.isNotEmpty) {
      Provider.of<PlaceProvider>(context, listen: false)
          .downloadImagesForPlace(place.id, place.imageUrl!);
    }
    return Column(
      children: [
        Expanded(
          flex: 15,
          // Image of the place (15% of the total screen)
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              // Image with horizontal scroll
              _buildImageCarousel(place.id),
              // Favorite icon button
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
                        userProvider.toggleFavoriteStatus(place);
                        userProvider.fetchUserDetails();
                      },
                      tooltip: 'Add or Remove From Favorite',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Place name, category, and other details (remaining 25% of the top part)
        Expanded(
          flex: 35,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(place.category,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(place.description),
                        ),
                      ),
                      buildBoldText('Location: ', '${place.location}'),
                      buildBoldText(
                          'Contact: ', '${place.formattedContactInfo}'),
                      ...categoryDetails
                          .map((detail) => Expanded(child: detail)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildRatingStars(place.averageRating),
                    const SizedBox(height: 4),
                    Text(
                      place.averageRating != null
                          ? place.averageRating!.toStringAsFixed(1)
                          : 'No Ratings',
                    ),
                    Text('${place.totalReviews} Reviews'),
                    // Wrap the timings Text widget in an Expanded to prevent overflow
                    Expanded(
                      child: Text(
                        'Timings: \n${place.formattedOperatingHours}',
                        textAlign: TextAlign.right,
                        overflow: TextOverflow
                            .ellipsis, // Add an ellipsis when the text overflows
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(String placeId) {
    // final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    return Column(
      children: [
        Expanded(
          flex: 50, // 60% of the screen for reviews
          child: FutureBuilder<List<Review>>(
            future: _reviewsFuture,
            builder: (context, snapshot) {
              // if (snapshot.connectionState == ConnectionState.waiting) {
              //   return const Center(child: CircularProgressIndicator());
              // }

              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const Center(child: Text('No reviews found'));
              }

              final reviews = snapshot.data!;
              return ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  return _buildReviewCard(context, reviews[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _refreshReviews() {
    setState(() {
      _reviewsFuture = Provider.of<ReviewProvider>(context, listen: false)
          .fetchReviewsForPlace(widget.placeId);
    });
  }

  Widget _buildReviewCard(BuildContext context, Review review) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Fetch user details once when creating the review card
    // final Future<User?> _reviewAuthorFuture = userProvider.fetchUserById(review.userId);

    return FutureBuilder<User?>(
      future: userProvider.fetchUserById(review.userId),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userSnapshot.hasError || !userSnapshot.hasData) {
          return const Center(child: Text('Error fetching user'));
        }

        final reviewAuthor = userSnapshot.data!;
        // userProvider.downloadImageIfNeeded(
        //     reviewAuthor.id, reviewAuthor.profilePhotoPath ?? '');

        return GestureDetector(
          onTap: () {
            // Navigate to ReviewDetailScreen with the current review
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewDetailScreen(review: review),
              ),
            ).then((_) {
              _refreshReviews();
            });
          },
          child: Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Profile photo and subject column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey,
                                backgroundImage:
                                    userProvider.getUserImage(reviewAuthor.id),
                                child: (reviewAuthor.profilePhotoPath == null ||
                                        reviewAuthor.profilePhotoPath!.isEmpty)
                                    ? Text(
                                        reviewAuthor.initials(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                review.subject,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Ratings column
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildRatingStars(review.rating),
                            Text(
                              review.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Review content
                    Text(
                      review.content,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                )),
          ),
        );
      },
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

  void _handleLogout(BuildContext context) {
    _showToast('Successfully Logged out.', Colors.redAccent);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) =>
          false, // This predicate ensures all previous routes are removed
    );
  }

  @override
  void dispose() {
    // Navigator.pop(context, places); // Return the updated places list
    super.dispose();
  }

  void _showToast(String message, Color color) {
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
