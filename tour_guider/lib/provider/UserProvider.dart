import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  List<User> _allUsers = [];
  // 192.168.1.230
  String authUrl = 'http://192.168.1.230:8080/api/v1/auth';
  String photoUrl = 'http://192.168.1.230:8080/api/v1';
  String baseUrl = 'http://192.168.1.230:8080/api/v1/users';
  final String userDetailUrl = 'http://192.168.1.230:8080/api/v1/users/loggedInUser';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();


  // String AuthToken = '';

  User? get user => _user;
  List<User> get allUsers => List.unmodifiable(_allUsers);

  void setUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }

  // Fetch logged in user
  Future<void> fetchUserDetails() async {
    try {
      final url = Uri.parse(userDetailUrl);
      String? authToken = await _secureStorage.read(key: 'authToken');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $authToken'
        }
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> userJson = json.decode(response.body);
        _user = User.fromJson(userJson);
      } else {
        // Handle non-200 responses
        debugPrint("Failed to fetch logged in user: ${response.body}");
      }
    } catch (error) {
      // Handle network error
      debugPrint("Exception in retrieving user details: $error");
    }
    notifyListeners();
  }

  //Todo
  // Fetch all users
  Future<void> fetchAllUsers() async {
    final url = Uri.parse(baseUrl);
    String? authToken = await _secureStorage.read(key: 'authToken');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          // 'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> usersJson = json.decode(response.body);
        _allUsers = usersJson.map((json) => User.fromJson(json)).toList();
        notifyListeners();
      } else {
        // Handle non-200 responses
        debugPrint('Failed to fetch users: ${response.body}');
      }
    } catch (error) {
      // Handle network error, throw exception or log it
      debugPrint('Error fetching users: $error');
    }
  }

  //Todo
  // Save places for the current user
  Future<bool> savePlaceForUser(String placeId) async {
    String? authToken = await _secureStorage.read(key: 'authToken');
    if (authToken == null) {
      debugPrint('authToken is null: $authToken');
      return false;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$placeId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 204) {
        // You can update the user's saved places in the local state if needed
        return true;
      } else {
        // Handle non-200 responses
        debugPrint('Failed to save place: ${response.body}');
        return false;
      }
    } catch (error) {
      // Handle network error, throw exception or log it
      debugPrint('Error saving place: $error');
      return false;
    }
  }

  Future<bool> updateFavoriteStatus(String placeId, bool isFavorite) async {
    if (_user == null) return false;

    if (isFavorite) {
      if (!_user!.savedPlaces.contains(placeId)) {
        _user!.savedPlaces.add(placeId);
      }
    } else {
      _user!.savedPlaces.remove(placeId);
    }

    notifyListeners();
    return true;
  }

  // Todo
  // Fetch a user by ID
  Future<void> fetchUserById(String userId) async {
    final url = Uri.parse('$baseUrl/$userId');
    String? authToken = await _secureStorage.read(key: 'authToken');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $authToken', // Uncomment and replace token-based auth
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final userJson = json.decode(response.body);
        _user = User.fromJson(
            userJson); // Assuming User.fromJson is a constructor that initializes a User object from a JSON map
        notifyListeners();
      } else {
        // Handle non-200 responses
        debugPrint('Failed to fetch user: ${response.body}');
      }
    } catch (error) {
      // Handle network error, throw exception or log it
      debugPrint('Error fetching user: $error');
    }
  }

  // register user
  Future<void> register(User newUser, File? imageFile) async {
    // Call API to register the user
    final registerUrl = Uri.parse('$authUrl/signup');
    // await _secureStorage.deleteAll();
    try {
      // Preparing JSON body for the request
      var registerRequestBody = {
        'firstName': newUser.firstName,
        'lastName': newUser.lastName,
        'username': newUser.userName,
        'email': newUser.email,
        'password': newUser.password,
        'bio': newUser.bio,
      };

      final response = await http.post(
        registerUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(registerRequestBody),
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        // Assuming the response contains 'token' and 'userRole'
        String authToken = responseData['authToken'];
        await _secureStorage.write(key: 'authToken', value: authToken);
        // bool userRole = responseData['admin'];

        // Update the user with the received data
        _user = newUser.copyWith(
          id: responseData['userId'],
          // userRole: userRole,
        );
        notifyListeners();

        // If an image file is provided, upload it
        if (imageFile != null) {
          await uploadImage(imageFile, _user!.id);
        } else {debugPrint("Image is null");}
      } else {
        debugPrint("Error in user registration: ${response.body}");
      }
    } catch (e) {
      debugPrint("Exception in registering user: $e");
    }
  }


  // upload user profile photo
  Future<void> uploadImage(File image, String userId) async {
    try {
      var request = http.MultipartRequest(
          "POST",
          Uri.parse("$photoUrl/photos/upload/user")
      );

      // Add file to the request
      var picture = await http.MultipartFile.fromPath('uploadProfilePhoto', image.path);
      request.files.add(picture);

      // Add userId as a field if needed
      request.fields['userId'] = userId;

      // Read authToken from secure storage and add it to request header
      String? authToken = await _secureStorage.read(key: 'authToken');
      if (authToken != null) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }

      // Send the request
      var response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var result = json.decode(utf8.decode(responseData));

        // Assuming the response contains the photo path
        var updatedPhotoUrl = result['photo']; // Adjust the key according to actual response
        _user?.profilePhotoPath = updatedPhotoUrl;
        notifyListeners();
      } else {
        var responseBody = await response.stream.bytesToString();
        debugPrint("Error uploading image: $responseBody");
      }
    } catch (e) {
      debugPrint("Exception in image upload: $e");
    }
  }


  // LOGIN
  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$authUrl/signin');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        String authToken = responseData['authToken'];
        bool isAdmin = responseData['admin'];
        await _secureStorage.write(key: 'authToken', value: authToken);
        await _secureStorage.write(key: 'admin', value: isAdmin.toString());

        // Update _user with the fetched user data, including admin status
        _user?.isAdmin = isAdmin;
        notifyListeners();
        return true;
      } else {
        // Handle error
        var responseBody = json.decode(response.body);
        debugPrint("Error logging in : $responseBody");
        return false;
      }
    } catch (e) {
      // Handle exception
      debugPrint("Exception in logging in user: $e");
      return false;
    }
  }



// Add any other methods you might need to modify the user data
}
