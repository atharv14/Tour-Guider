// AddEditReviewScreen.dart
import 'package:flutter/material.dart';
import '../models/review.dart'; // Import your review model

class AddEditReviewScreen extends StatefulWidget {
  final Review? review; // Nullable for add, non-null for edit

  AddEditReviewScreen({this.review});

  @override
  _AddEditReviewScreenState createState() => _AddEditReviewScreenState();
}

class _AddEditReviewScreenState extends State<AddEditReviewScreen> {
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If editing an existing review, populate the text fields
    if (widget.review != null) {
      _subjectController.text = widget.review!.subject;
      _bodyController.text = widget.review!.content;
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.review != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Review' : 'Add Review'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Review Subject',
              ),
            ),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(
                labelText: 'Review Body',
              ),
              maxLines: 5,
            ),
            // Add other fields for rating and images as needed
            ElevatedButton(
              onPressed: () {
                if (isEditing) {
                  // Logic to update the review
                } else {
                  // Logic to add a new review
                }
              },
              child: Text(isEditing ? 'Update Review' : 'Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
