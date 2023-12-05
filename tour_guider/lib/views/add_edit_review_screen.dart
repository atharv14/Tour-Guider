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
    // If editing an existing review, populate the text fields
    if (widget.review != null) {
      _subjectController.text = widget.review!.subject;
      _bodyController.text = widget.review!.content;
      _rating = widget.review!.rating;
      if (widget.review?.photos != null) {
        _images = widget.review!.photos!.map((path) => File(path)).toList();
      } else {
        _images = null; // Set to null if photos is null
      }
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
        _images?.add(File(pickedFile.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    // Function to get initials from user's name
    String getInitials(String name) => name.isNotEmpty
        ? name.trim().split(' ').map((l) => l[0]).take(2).join()
        : 'X';

    // Function to validate required fields
    bool validateRequiredFields() {
      return _subjectController.text.isNotEmpty &&
          _rating > 0 &&
          _bodyController.text.isNotEmpty;
    }

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
                  Align(
                    alignment: Alignment.topLeft,
                    // child: CircleAvatar(
                    //   backgroundImage: userProvider.user?.profilePhotoPath?.isNotEmpty ?? false
                    //       ? NetworkImage(userProvider.user!.profilePhotoPath!)
                    //       : null,
                    //   child: userProvider.user?.profilePhotoPath?.isEmpty ?? true
                    //       ? Text(getInitials(userProvider.user?.firstName ?? ''))
                    //       : null,
                    // ),
                  ),
                  TextFormField(
                    controller: _subjectController,
                    decoration: const InputDecoration(labelText: 'Review Subject'),
                    validator: (value) => value!.isEmpty ? 'Subject cannot be empty' : null,
                    maxLines: 1,
                  ),
                  TextFormField(
                    initialValue: _rating.toString(),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
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
                    validator: (value) => value == null || double.tryParse(value)! <= 0 ? 'Rating must be greater than 0' : null,
                  ),
                  TextFormField(
                    controller: _bodyController,
                    decoration: const InputDecoration(labelText: 'Review Body'),
                    validator: (value) => value!.isEmpty ? 'Review cannot be empty' : null,
                    maxLines: 10,
                    maxLength: 500,
                  ),
                  SizedBox(height: 10),
                  Text('Add Images (optional):'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _images != null ? _images!.map((file) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(file, width: 100, height: 100),
                        );
                      }).toList()
                      : [const Text('No images')],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Pick Image'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (userProvider.user == null) {
                        // Handle the null case
                        print("${userProvider.user} is null");
                        return;
                      }
                      if (validateRequiredFields()) {
                        // Create or update review
                        Review newReview = Review(
                          id: widget.review?.id ?? '', // Provide a default value or generate a new ID
                          userId: userProvider.user!.id,
                          placeId: widget.review?.placeId ?? '', // You need to provide the place ID here
                          rating: _rating,
                          subject: _subjectController.text,
                          content: _bodyController.text,
                          dateTime: widget.review?.dateTime ?? DateTime.now(),
                          photos: _images?.map((file) => file.path).toList(),
                        );

                        if (widget.review == null) {
                          reviewProvider.addReview(widget.placeId, newReview);
                        } else {
                          reviewProvider.updateReview(widget.review!.id, newReview);
                        }

                        Navigator.pop(context);
                      } else {
                        // Show error if required fields are not filled
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please fill all required fields"),
                          ),
                        );
                      }
                    },
                    child: Text(widget.review == null ? 'Add Review' : 'Submit Review'),
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
