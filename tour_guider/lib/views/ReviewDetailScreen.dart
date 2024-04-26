import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import '../models/review.dart';
import '../models/user.dart';
import '../provider/ReviewProvider.dart';
import '../provider/UserProvider.dart';
import 'AddEditReviewScreen.dart';
import 'UserProfileScreen.dart';

class ReviewDetailScreen extends StatefulWidget {
  final Review review;

  const ReviewDetailScreen({super.key, required this.review});

  @override
  _ReviewDetailScreenState createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  // late Review detailedReview;
  late Future<User?> _userFuture;
  late Future<void> _reviewDetailsFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUserDetails();
    _reviewDetailsFuture = fetchReviewDetails();
    _fetchLoggedInUser();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    if (widget.review.photos != null && widget.review.photos!.isNotEmpty) {
      final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
      await reviewProvider.downloadReviewImages(widget.review.id, widget.review.photos!);
    }
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

  Future<void> refreshReviewDetails() async {
    setState(() {
      _reviewDetailsFuture = fetchReviewDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context);
    final Review? detailedReview = reviewProvider.detailedReview;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // final loggedInUserId =   // ID of the logged-in user

    final bool userOwnsReview = (detailedReview != null) &&
        (userProvider.user?.id == detailedReview.userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Review'),
        actions: <Widget>[
          if (userOwnsReview) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (context) => AddEditReviewScreen(
                        review: detailedReview,
                      ),
                    ))
                    .then((_) => refreshReviewDetails());
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                // Confirm deletion with the user before proceeding
                final confirmDelete = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Delete Review'),
                      content: const Text('Are you sure you want to delete this review?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Review not deleted.')),
                            );
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child: const Text('Delete'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Review deleted successfully.')),
                            );
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                ) ?? false;

                if (!mounted) return;

                if (confirmDelete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Review deleted successfully!')),
                  );
                  // Delete the review
                  await reviewProvider.deleteReview(detailedReview.id);
                  // Navigate back or refresh as needed
                  Navigator.of(context).pop(); // Go back to the previous screen
                }
              },
            ),
          ]
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

              final reviewAuthor = userSnapshot.data;
              if (reviewAuthor == null) {
                return const Center(child: Text('User not found'));
              }
              userProvider.downloadImageIfNeeded(
                  reviewAuthor.id, reviewAuthor.profilePhotoPath ?? '');

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
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              userProvider.getUserImage(reviewAuthor.id),
                          child: (reviewAuthor.profilePhotoPath == null ||
                                  reviewAuthor.profilePhotoPath!.isEmpty)
                              ? Text(
                                  reviewAuthor.initials(),
                                  style: const TextStyle(color: Colors.white),
                                )
                              : null,
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
                      const SizedBox(height: 20),
                      _buildImageList(detailedReview.id ?? ''),
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


  Widget _buildImageList(String reviewId) {
    final reviewProvider = Provider.of<ReviewProvider>(context);
    var images = reviewProvider.getReviewImages(reviewId);

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
}
