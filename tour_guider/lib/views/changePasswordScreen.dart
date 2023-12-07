import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/UserProvider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();


  Future<void> _submitChangePassword() async {

    String currentPassword = _currentPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmNewPassword = _confirmNewPasswordController.text;

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmNewPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    if (newPassword != confirmNewPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New passwords do not match",
          style: TextStyle(color: Colors.black),
        ),
          backgroundColor: Colors.greenAccent,
        ),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool success = await userProvider.changePassword(
      currentPassword,
      newPassword,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password successfully changed')),
      );
      Navigator.of(context).pop(); // Navigate back on success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to change password",
          style: TextStyle(color: Colors.white),
        ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _currentPasswordController,
              decoration: const InputDecoration(labelText: 'Current Password'),
              obscureText: true,
            ),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmNewPasswordController,
              decoration: const InputDecoration(labelText: 'Re-enter New Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _submitChangePassword,
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }
}
