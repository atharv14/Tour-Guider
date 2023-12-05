import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/review.dart';
import '../models/user.dart';
import '../provider/ReviewProvider.dart';
import '../provider/UserProvider.dart';
import 'add_edit_review_screen.dart';
import 'user_profile_screen.dart';

class ReviewDetailScreen extends StatefulWidget {
  final Review review;

  const ReviewDetailScreen({super.key, required this.review});

  @override
  _ReviewDetailScreenState createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  // late Review detailedReview;
  bool isLoading = true;
  late Future<User?> _userFuture;
  late Future<void> _reviewDetailsFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUserDetails();
    _reviewDetailsFuture = fetchReviewDetails();
    // final userProvider = Provider.of<UserProvider>(context, listen: false);
    // if (_userFuture == null) {
    //   _userFuture = userProvider.fetchUserById(widget.review.userId);
    // }
    _fetchLoggedInUser();
  }

  // UserProfileScreen.dart
  Future<void> _fetchLoggedInUser() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.fetchUserDetails(); // Fetch logged-in user details
    } catch (error) {
      debugPrint('Error loading user details: $error');
    }
  }

  Future<User?> _loadUserDetails() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      return await userProvider.fetchUserById(widget.review.userId);
    } catch (error) {
      debugPrint('Error fetching user details: $error');
      return null; // Return null or handle the error as appropriate
    }
  }

  Future<void> fetchReviewDetails() async {
    try {
      await Provider.of<ReviewProvider>(context, listen: false)
          .fetchReviewDetails(widget.review.id);
    } catch (error) {
      debugPrint('Error fetching review details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context);
    final Review? detailedReview = reviewProvider.detailedReview;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // final loggedInUserId =   // ID of the logged-in user


    final bool userOwnsReview = (detailedReview != null) && (userProvider.user?.id == detailedReview.userId);
    // if (isLoading || detailedReview == null) {
    //   return Scaffold(
    //     appBar: AppBar(
    //       title: const Text('Loading Review...'),
    //     ),
    //     body: const Center(child: CircularProgressIndicator()),
    //   );
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Review'),
        actions: <Widget>[
          if (userOwnsReview)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      AddEditReviewScreen(review: detailedReview),
                ));
              },
            ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _reviewDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // At this point, we can assume the review details are loaded
          return FutureBuilder<User?>(
            future: _userFuture,
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (userSnapshot.hasError) {
                return Center(child: Text('Error: ${userSnapshot.error}'));
              }

              final user = userSnapshot.data;
              // Check if the user exists and the review belongs to the user
              // final bool userOwnsReview = user?.id == detailedReview.userId;
              // Now we can build the UI with user and review details
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Navigate to UserProfileScreen with the user ID

                            // Todo: go to userProfile and accept userId parameter
                            // if (user != null) {
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => UserProfileScreen(userId: user.id)), // Pass the user's ID
                            //   );
                            // }
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                Colors.grey, // Default background color
                            backgroundImage:
                                user?.profilePhotoPath?.isNotEmpty == true
                                    ? NetworkImage(user!.profilePhotoPath!)
                                    : null,
                            child: user?.profilePhotoPath == null ||
                                    user!.profilePhotoPath!.isEmpty
                                ? Text(
                                    user!.initials(),
                                    style: const TextStyle(color: Colors.white),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            detailedReview!.subject,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          '${detailedReview.rating} Stars',
                          style: const TextStyle(
                              fontSize: 20, color: Colors.amber),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      detailedReview.content,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    // Display images if available
                    if (detailedReview.photos?.isNotEmpty == true) ...[
                      const SizedBox(height: 100),
                      SizedBox(
                        height: 100, // Fixed height for image carousel/slider
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: detailedReview.photos!.map((imageUrl) {
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
              );
            },
          );
        },
      ),
    );
  }

  // Widget _buildImageList(List<String> imageUrls) {
  //   return SizedBox(
  //     height: 100,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: imageUrls.length,
  //       itemBuilder: (context, index) {
  //         return Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Image.network(
  //             imageUrls[index],
  //             fit: BoxFit.cover,
  //             width: 100,
  //             height: 100,
  //             errorBuilder: (context, error, stackTrace) {
  //               return const Icon(
  //                   Icons.broken_image); // Placeholder for a broken image
  //             },
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
}
