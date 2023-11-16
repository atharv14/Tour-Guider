import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'views/login_screen.dart'; // Import login screen
import 'views/registration_screen.dart'; // Import registration screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tour Guide App',
      builder: FToastBuilder(), // Include the FToast builder here
      navigatorKey: navigatorKey, // Set the navigator key
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), // Set the initial route to login screen
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
      },
    );
  }
}
