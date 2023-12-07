// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/UserProvider.dart';
import 'changePasswordScreen.dart';

class UserProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const UserProfileScreen({super.key, this.onBack});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _fetchUserPhoto();
  }

  // ${_loggedInUser!.profilePhotoPath!}
  Future<void> _fetchUserPhoto() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final photoPath = userProvider.user?.profilePhotoPath;
    if (photoPath != null) {
      await userProvider.downloadImage(photoPath);
    }
  }

  // UserProfileScreen.dart
  Future<void> _loadUserDetails() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.fetchUserDetails(); // Fetch logged-in user details
    } catch (error) {
      debugPrint('Error loading user details: $error');
    }
  }

  @override
  void dispose() {
    widget.onBack?.call(); // Invoke the callback
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    // await userProvider.fetchUserDetails();

    if (user == null) {
      // User data is not available, handle accordingly
      return Scaffold(
        appBar: AppBar(title: const Text('User Profile')),
        body: const Center(child: Text("User data not available")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings screen or show settings options
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Pass the  user object
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Selector<UserProvider, ImageProvider?>(
              selector: (_, provider) => provider.profileImage,
              builder: (_, profileImage, __) {
                return CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImage,
                  child: profileImage == null ? Text(user.initials()) : null,
                );
              },
            ),

            const SizedBox(height: 20),
            Text(user.fullName(), style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: user.email,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              initialValue: user.userName,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              initialValue: user.bio,
              readOnly: true,
              maxLines: null,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
            const SizedBox(height: 20),
            Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text('Total Reviews: ${user.totalReviews?.toString() ?? '0'}', style: const TextStyle(fontSize: 15),),
                const SizedBox(height: 10),
                Text('Saved Places Count: ${user.savedPlaces?.length ?? 0}', style: const TextStyle(fontSize: 15),),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
