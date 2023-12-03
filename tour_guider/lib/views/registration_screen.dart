import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/user.dart'; // Import User Model
import '../provider/UserProvider.dart';
import 'login_screen.dart'; // Import your login screen

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // TextEditingControllers to capture input data
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () => _showPicker(context),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null ? const Icon(Icons.camera_alt) : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'First name is required' : null,
              ),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                ),
                validator: (value) => value!.isEmpty ? 'Last name is required' : null,
              ),
              TextFormField(
                controller: userNameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
                validator: (value) => value!.isEmpty ? 'Username is required' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) {
                    _showSnackBar('Email is required', Colors.redAccent);
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    _showSnackBar('Please enter a valid email address', Colors.redAccent);
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Password is required' : null,
              ),
              TextFormField(
                controller: bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                ),
                maxLength: 500, // Limit of 500 characters for bio
                //maxLines: 10, // Allow multiple lines for bio
                validator: (value) => value!.isEmpty ? 'Bio is required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Register'),
                onPressed: () => _registerUser(userProvider),
              ),
              TextButton(
                child: const Text('Already have an account? Login here!'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
              ),
            ],
        ),
      ),
    );
  }
  bool _validateInputs() {
    return firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        userNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        bioController.text.isNotEmpty;
  }

  void _registerUser(userProvider) async {
    // final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!_validateInputs()) {
      _showSnackBar("Please fill in all fields", Colors.redAccent);
      return;
    }

    // Create a new User instance using the input data
    User newUser = User(
      id: '', // This will be set by the backend
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      userName: userNameController.text,
      email: emailController.text,
      password: passwordController.text,
      bio: bioController.text,
      profilePhotoPath: '', // This will be updated after image upload
      isAdmin: false, // Assuming a normal user is being registered, not an admin
    );

    bool registrationSuccess = false;

    // Check if an image has been picked
    if (_image != null) {
      try {
        // Register user using the provider
        registrationSuccess = await userProvider.register(newUser, _image);

        debugPrint("Registered");
        // Show success message and navigate to the Login Screen
        _showSnackBar("Registration Successful!", Colors.greenAccent);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } catch (e) {
        debugPrint("Registration Failed: $e");
        // Show error message if registration or image upload fails
        _showSnackBar("Failed to register. Error: $e", Colors.redAccent);
      }
    } else {
      // Show error message if no image is selected
      _showSnackBar("Please select an image", Colors.redAccent);
    }
    if (registrationSuccess) {
      debugPrint("Registered");
      _showSnackBar("Registration Successful!", Colors.greenAccent);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else if (_image != null) {
      // This else-if branch is for the case where an image is selected but registration failed
      _showSnackBar("Failed to register", Colors.redAccent);
      debugPrint("Registration Failed but image is selected");
    }
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    firstNameController.dispose();
    lastNameController.dispose();
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: const Duration(seconds: 5),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        _showSnackBar("Profile photo not uploaded.", Colors.red);
      }
    });
  }

  void _showPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile Photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
