import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'provider/UserProvider.dart'; // Import the UserProvider
import 'provider/PlaceProvider.dart'; // Import the PlaceProvider
import 'provider/ReviewProvider.dart'; // Import the ReviewProvider
import 'views/login_screen.dart'; // Import login screen
import 'views/registration_screen.dart'; // Import registration screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => PlaceProvider()),
        ChangeNotifierProvider(create: (context) => ReviewProvider()),
      ],
      child: MaterialApp(
        title: 'Tour-Guider',
        // builder is used here for FToast
        builder: (context, child) {
          // Initialize FToast here
          FToast().init(context);
          // Return the child, which is MaterialApp
          return child!;
        }, // Include the FToast builder here
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        home: const LoginScreen(), // Set the initial route to login screen
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegistrationScreen(),
        },
      ),
    );
  }
}
