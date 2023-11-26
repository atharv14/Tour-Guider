import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/UserProvider.dart';
import '../models/review.dart';

class ReviewDetailScreen extends StatelessWidget {
  final Review review;

  const ReviewDetailScreen({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // final userProvider = Provider.of<UserProvider>(context);
    // final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Review'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Implement edit functionality

            },
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
                CircleAvatar(
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
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    review.subject,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
            if (review.images.isNotEmpty)
              Column(
                children: review.images.map((url) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.network(url),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

