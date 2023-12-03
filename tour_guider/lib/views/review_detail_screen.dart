import 'package:flutter/material.dart';
import '../models/review.dart';
import 'add_edit_review_screen.dart';
import 'user_profile_screen.dart';

class ReviewDetailScreen extends StatelessWidget {
  final Review review;

  const ReviewDetailScreen({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    // final userProvider = Provider.of<UserProvider>(context);
    // final user = userProvider.user;
    const userOwnsReview = true;
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Review'),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ... Review content here
              if (userOwnsReview)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddEditReviewScreen(review: review),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserProfileScreen()),
                    );
                  },
                child: CircleAvatar(
                  // Display user initials if no image is provided
                  backgroundImage: review.userProfilePhoto.isNotEmpty
                      ? NetworkImage(review.userProfilePhoto)
                      : null,
                  radius: 30,
                  // Display user initials if no image is provided
                  child: review.userProfilePhoto.isEmpty
                      ? Text(review.getUserInitials())
                      : null,
                ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    review.subject,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${review.rating} Stars',
                  style: const TextStyle(fontSize: 20, color: Colors.amber),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              review.content,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            // Display images if available
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
    );
  }

  Widget _buildImageList(List<String> imageUrls) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              imageUrls[index],
              fit: BoxFit.cover,
              width: 100,
              height: 100,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image); // Placeholder for a broken image
              },
            ),
          );
        },
      ),
    );
  }
}
