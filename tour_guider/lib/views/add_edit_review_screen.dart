// AddEditReviewScreen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/review.dart';
import '../provider/ReviewProvider.dart';
import '../provider/UserProvider.dart'; // Import your review model
import 'package:http/http.dart' as http;

class AddEditReviewScreen extends StatefulWidget {
  final Review? review; // Nullable for add, non-null for edit

  const AddEditReviewScreen({super.key, this.review});

  @override
  _AddEditReviewScreenState createState() => _AddEditReviewScreenState();
}

class _AddEditReviewScreenState extends State<AddEditReviewScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  double _rating = 0;
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();


  @override
  void initState() {
    super.initState();
    // If editing an existing review, populate the text fields
    if (widget.review != null) {
      _subjectController.text = widget.review!.subject;
      _bodyController.text = widget.review!.content;
      _rating = widget.review!.rating;
      _images = List.from(widget.review!.images);
    }
  }

  uploadImage(String title, File file) async {
    var request = http.MultipartRequest("POST", Uri.parse("../assets/"));

    request.fields['title'] = title;
    request.headers['Authorization'] = "JWT";

    var picture = http.MultipartFile.fromBytes('image', (await rootBundle.load('assets/place 1.jpeg')).buffer.asUint8List());

    request.files.add(picture);

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var result = String.fromCharCodes(responseData);
    debugPrint(result);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
        // After adding the image, you can call uploadImage to upload it immediately
        // or store the file to upload when the user submits the form
      });
    }
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: userProvider.user?.profilePhotoPath.isNotEmpty ?? false
                            ? NetworkImage(userProvider.user!.profilePhotoPath)
                            : null,
                        child: userProvider.user?.profilePhotoPath.isEmpty ?? true
                            ? Text(userProvider.user?.initials() ?? 'A')
                            : null,
                      ),
                      SizedBox(
                        width: 70,
                        child: TextFormField(
                          initialValue: _rating.toString(),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _rating = double.tryParse(value) ?? _rating;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Rating',
                            suffixText: 'Stars',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(labelText: 'Review Subject'),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            TextFormField(
              controller: _bodyController,
              decoration: const InputDecoration(labelText: 'Review Body'),
              maxLines: 10,
            ),
            //ToDo Image list builder
            // Add a button for picking an image
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),

            // Display the picked images
            Wrap(
              children: _images.map((file) {
                return Image.file(file);
              }).toList(),
            ),

            // TextButton(
            //   onPressed: (){
            //     uploadImage('image', File('assets/'));
            //   },
            //   child: const Text(
            //     'Upload Images',
            //   textAlign: TextAlign.center,
            //   ),
            // ),

            ElevatedButton(
              onPressed: () {
                Review newReview = Review(
                  id: widget.review?.id ?? DateTime.now().toString(),
                  userId: 'userId',
                  userName: userProvider.user!.userName,
                  subject: _subjectController.text,
                  content: _bodyController.text,
                  rating: _rating,
                  date: widget.review?.date ?? DateTime.now(),
                  images: ['${widget.review?.images}',''],
                  userProfilePhoto: userProvider.user!.profilePhotoPath,
                );
                if (widget.review == null) {
                  reviewProvider.addReview(newReview);
                } else {
                  reviewProvider.updateReview(widget.review!.id, newReview);
                }

                Navigator.pop(context);
              },
              child: Text(widget.review == null ? 'Add Review' : 'Submit Review'),
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
