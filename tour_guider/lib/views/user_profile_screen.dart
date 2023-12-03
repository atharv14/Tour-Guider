import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/UserProvider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.fetchUserDetails();
    } catch (error) {
      // Handle any errors here
      debugPrint('Error loading user details: $error');
    }
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
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user!.profilePhotoPath.isNotEmpty
                  ? NetworkImage(user.profilePhotoPath)
                  : null,
              child:
                  user.profilePhotoPath.isEmpty ? Text(user.initials()) : null,
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
            Row(
              children: [
                const Text('Total Reviews: '),
                Text(user.totalReviews.toString()),
                Text('Saved Places Count: ${user?.savedPlaces.length ?? 0}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
