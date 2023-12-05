import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'registration_screen.dart'; // Import registration screen
import 'place_list_view.dart'; //Import places view screen
// import '../models/place.dart'; // Import Place model clas
import '../provider/UserProvider.dart'; // Import UserProvider

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  // final User? user;
  // const LoginScreen({super.key, this.user});
  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {

  // late List<Place> places;
  // final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final userNameController = TextEditingController();

  @override
  void dispose() {
    // Dispose of the controllers
    // emailController.dispose();
    passwordController.dispose();
    userNameController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = userNameController.text;
    final password = passwordController.text;

    // Implement login logic using UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool isSuccess = await userProvider.login(email, password);

    if (isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PlacesViewScreen()),
      );
    } else {
      // Show error message
      _showSnackBar("Failed to login", Colors.redAccent);
    }
  }

  @override
  Widget build(BuildContext context) {

    // Access user data using Provider
    final user = Provider.of<UserProvider>(context).user;

    // If there's a user, fill in the email field
    // emailController.text = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: userNameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
              validator: (value) => value!.isEmpty ? 'Username is required' : null,
            ),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
              validator: (value) => value!.isEmpty ? 'Password is required' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            TextButton(
              child: const Text('Don\'t have an account? Register here!'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  void _showSnackBar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: const Duration(seconds: 5),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
