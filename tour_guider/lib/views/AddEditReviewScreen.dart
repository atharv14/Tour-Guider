// AddEditReviewScreen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import '../models/review.dart';
import '../provider/ReviewProvider.dart';
import '../provider/UserProvider.dart'; // Import review model

class AddEditReviewScreen extends StatefulWidget {
  final Review? review; // Nullable for add, non-null for edit
  final String? placeId;

  const AddEditReviewScreen({super.key, this.review, this.placeId});

  @override
  _AddEditReviewScreenState createState() => _AddEditReviewScreenState();
}

class _AddEditReviewScreenState extends State<AddEditReviewScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  double _rating = 0;
  List<File>? _images;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _images = widget.review?.photos?.map((path) => File(path)).toList() ?? [];
    // If editing an existing review, populate the text fields
    if (widget.review != null) {
      _subjectController.text = widget.review!.subject;
      _bodyController.text = widget.review!.content;
      _rating = widget.review!.rating;
      _images = widget.review!.photos != null
          ? widget.review!.photos!.map((path) => File(path)).toList()
          : [];
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images?.add(File(pickedFile.path));
      });
    }
  }

  // Function to validate required fields
  bool validateRequiredFields() {
    return _subjectController.text.isNotEmpty &&
        _rating > 0 &&
        _bodyController.text.isNotEmpty;
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.review == null ? 'Add Review' : 'Edit Review'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  // Align(
                  //   alignment: Alignment.topLeft,
                  //   child: CircleAvatar(
                  //     backgroundImage: userProvider.user?.profilePhotoPath?.isNotEmpty ?? false
                  //         ? NetworkImage(userProvider.user!.profilePhotoPath!)
                  //         : null,
                  //     child: userProvider.user?.profilePhotoPath?.isEmpty ?? true
                  //         ? Text(getInitials(userProvider.user?.firstName ?? ''))
                  //         : null,
                  //   ),
                  // ),
                  TextFormField(
                    controller: _subjectController,
                    decoration:
                        const InputDecoration(labelText: 'Review Subject'),
                    validator: (value) =>
                        value!.isEmpty ? 'Subject cannot be empty' : null,
                    maxLines: 1,
                  ),
                  TextFormField(
                    initialValue: _rating.toString(),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,1}')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _rating = double.tryParse(value) ?? 0;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Rating',
                      suffixText: 'Stars',
                    ),
                    validator: (value) =>
                        value == null || double.tryParse(value)! <= 0
                            ? 'Rating must be greater than 0'
                            : null,
                  ),
                  TextFormField(
                    controller: _bodyController,
                    decoration: const InputDecoration(labelText: 'Review Body'),
                    validator: (value) =>
                        value!.isEmpty ? 'Review cannot be empty' : null,
                    maxLines: 10,
                    maxLength: 500,
                  ),
                  const SizedBox(height: 10),
                  const Text('Add Images (optional):'),
                  _buildImageList(widget.review?.id??''),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Pick Image'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (userProvider.user == null) {
                        // Handle the null case
                        debugPrint("user is null");
                        return;
                      }
                      if (validateRequiredFields()) {
                        // Create or update review
                        Review newReview = Review(
                          id: widget.review?.id ??
                              '', // Provide a default value or generate a new ID
                          userId: userProvider.user!.id,
                          placeId: widget.review?.placeId ?? '', // place ID
                          rating: _rating,
                          subject: _subjectController.text,
                          content: _bodyController.text,
                          dateTime: widget.review?.dateTime ?? DateTime.now(),
                          photos: _images?.map((file) => file.path).toList(),
                        );

                        String reviewId = '';

                        if (widget.review == null) {
                          // add review
                          reviewId = await reviewProvider.addReview(
                              widget.placeId, newReview);
                          if (reviewId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Failed to add review')),
                            );
                            return;
                          }
                        } else {
                          // update review
                          await reviewProvider.updateReview(
                              widget.review!.id, newReview);
                          reviewId = widget.review!.id;
                        }

                        // Upload images if there are any
                        if (_images != null && _images!.isNotEmpty) {
                          await reviewProvider.uploadReviewImages(
                              _images!, reviewId);
                        }
                        // Show success message and navigate back
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Review ${widget.review == null ? "added" : "updated"} successfully')),
                        );
                        Navigator.pop(context);
                      } else {
                        // Show error if required fields are not filled
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Please fill all required fields")),
                        );
                      }
                    },
                    child: Text(
                        widget.review == null ? 'Add Review' : 'Submit Review'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}
