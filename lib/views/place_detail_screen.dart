import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/place.dart'; // Make sure this path matches your file structure
import '../models/review.dart'; // Make sure this path matches your file structure
import 'login_screen.dart'; // Import login screen

class PlaceDetailScreen extends StatefulWidget {
  final Place place;
  final List<Review> reviews; // Your list of reviews for this place

  PlaceDetailScreen({required this.place, required this.reviews});

  @override
  _PlaceDetailScreenState createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {

  late FToast fToast;// Declare FToast instance

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context); // Initialize FToast with context
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              // Go to Home
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to user details
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Handle logout
              _showToast();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Top 40% of the screen for place details
          Expanded(
            flex: 4,
            child: Column(
              children: [
              // Image of the place (15% of the total screen)
              Expanded(
              flex: 15,
              child: Image.network(
                widget.place.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
                // Place name, category, and other details (remaining 25% of the top part)
                Expanded(
                  flex: 25,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Place name and category
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                widget.place.name,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(widget.place.category),
                              Text(widget.place.description),
                            ],
                          ),
                        ),
                        // Ratings, reviews, location, contact, and favorite button
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Rating: ${widget.place.averageRating}'),
                            Text('Reviews: ${widget.place.reviewCount}'),
                            Text('Location: ${widget.place.location}'),
                            Text('Contact: ${widget.place.contactInfo}'),
                            Text('Timings: ${widget.place.timings}'),
                            IconButton(
                              icon: Icon(
                                widget.place.isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: widget.place.isFavorite ? Colors.red : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  widget.place.isFavorite = !widget.place.isFavorite;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3, // 60% of the screen for reviews
            child: ListView.builder(
              itemCount: widget.reviews.length,
              itemBuilder: (context, index) {
                final review = widget.reviews[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(review.userProfilePhoto), // Replace with the actual URL
                              radius: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                review.subject,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '${review.rating} Stars',
                              style: TextStyle(fontSize: 16, color: Colors.amber),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(review.content),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle add review button press
        },
        child: Icon(Icons.add),
      ),
    );
  }
  void _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.redAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(width: 12.0),
          Text("Successfully Logged out."),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 5),
    );

    // To use the custom toast position if needed
    // ...
  }
}
