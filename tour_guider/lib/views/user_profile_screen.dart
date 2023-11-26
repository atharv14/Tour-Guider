import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/UserProvider.dart';

class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

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
              backgroundImage: user!.profilePhotoUrl.isNotEmpty
                  ? NetworkImage(user.profilePhotoUrl)
                  : null,
              child:
                  user.profilePhotoUrl.isEmpty ? Text(user.initials()) : null,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}