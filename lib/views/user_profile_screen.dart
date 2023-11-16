import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_profile_viewmodel.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize text controllers with current user data
    final userProfileViewModel = Provider.of<UserProfileViewModel>(context, listen: false);
    _usernameController.text = userProfileViewModel.user.firstname;
    _emailController.text = userProfileViewModel.user.email;
  }

  @override
  Widget build(BuildContext context) {
    final userProfileViewModel = Provider.of<UserProfileViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Username:',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: _usernameController,
              onChanged: (newName) {
                userProfileViewModel.updateUserName(newName);
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Email:',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: _emailController,
              onChanged: (newEmail) {
                userProfileViewModel.updateEmail(newEmail);
              },
            ),
          ],
        ),
      ),
    );
  }
}
