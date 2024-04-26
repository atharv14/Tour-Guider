import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/place.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  User? _loggedInUser;
  List<User> _allUsers = [];
  final Map<String, User> _usersCache = {};
  List<String> get favoritePlaceIds =>
      _user?.savedPlaces?.map((place) => place.id).toList() ?? [];
  ImageProvider? _profileImage;

  final Map<String, ImageProvider> _userImages = {}; // new

  String ipPort = 'http://192.168.1.85:8080';

  // 192.168.1.230
  String authUrl = 'http://192.168.1.85:8080/api/v1/auth';
  String photoUrl = 'http://192.168.1.85:8080/api/v1';
  String baseUrl = 'http://192.168.1.85:8080/api/v1/users';
  final String userDetailUrl =
      'http://192.168.1.85:8080/api/v1/users/loggedInUser';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  User? get user => _user;
  List<User> get allUsers => List.unmodifiable(_allUsers);
  Map<String, User> get usersCache => _usersCache;
  ImageProvider? get profileImage => _profileImage;
  ImageProvider? getUserImage(String userId) => _userImages[userId]; // new

  void setUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }

  // to Change Password
  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    String? authToken = await _secureStorage.read(key: 'authToken');
    if (authToken == null) return false;

    try {
      final url = Uri.parse('$authUrl/changePassword');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'oldPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Error changing password: ${response.body}');
        return false;
      }
    } catch (error) {
      debugPrint('Exception in changing password: $error');
      return false;
    }
  }

  // download userprofile-photo image
  Future<void> downloadImageIfNeeded(String userId, String photoPath) async {
    if (!_userImages.containsKey(userId)) {
      try {
        String? authToken = await _secureStorage.read(key: 'authToken');
        final url = Uri.parse('$photoUrl/photos/fetch?photoPath=$photoPath');

        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $authToken',
          },
        );

        if (response.statusCode == 200) {
          _userImages[userId] = MemoryImage(response.bodyBytes);
          notifyListeners();
        } else {
          debugPrint("Failed to fetch photo: ${response.body}");
        }
      } catch (e) {
        debugPrint("Exception in fetching photo: $e");
      }
    }
  }

  Future<void> downloadImage(String photoPath) async {
    try {
      String? authToken = await _secureStorage.read(key: 'authToken');
      final url = Uri.parse('$photoUrl/photos/fetch?photoPath=$photoPath');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          // other headers if needed
        },
      );

      if (response.statusCode == 200) {
        _profileImage = MemoryImage(response.bodyBytes);
        notifyListeners();
      } else {
        debugPrint("Failed to fetch photo: ${response.body}");
      }
    } catch (e) {
      debugPrint("Exception in fetching photo: $e");
    }
  }

  // Future<User?> fetchUserForReview(String userId) async {
  //   // Assuming UserProvider is accessible
  //   return Provider.of<UserProvider>(context, listen: false).fetchUserById(userId);
  // }
  //
  // Future<void> fetchReviewsForPlace(String placeId) async {
  //   final url = Uri.parse('$baseUrl/place/$placeId');
  //   String? authToken = await _secureStorage.read(key: 'authToken');
  //
  //   try {
  //     final response = await http.get(url, headers: {
  //       'Authorization': 'Bearer $authToken',
  //       // 'Content-Type': 'application/json',
  //     });
  //     if (response.statusCode == 200) {
  //       List<dynamic> reviewJson = json.decode(response.body);
  //       _reviews = reviewJson.map((json) => Review.fromJson(json)).toList();
  //       notifyListeners();
  //     } else {
  //       debugPrint("Error getting response: ${response.body}");
  //     }
  //   } catch (e) {
  //     debugPrint("Failed to fetch reviews for the place: $e");
  //   }
  // }

  // Fetch logged in user

  // loggedIn User
  Future<void> fetchUserDetails() async {
    try {
      final url = Uri.parse(userDetailUrl);
      String? authToken = await _secureStorage.read(key: 'authToken');
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $authToken'});
      if (response.statusCode == 200) {
        Map<String, dynamic> userJson = json.decode(response.body);
        _user = User.fromJson(userJson);
        _loggedInUser = _user;
        notifyListeners();
      } else {
        // Handle non-200 responses
        debugPrint("Failed to fetch logged in user: ${response.body}");
      }
    } catch (error) {
      // Handle network error
      debugPrint("Exception in retrieving user details: $error");
    }
  }

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

  // Save places for the current user
  Future<bool> savePlaceForUser(Place placeId) async {
    String? authToken = await _secureStorage.read(key: 'authToken');
    if (authToken == null) return false;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/place/$placeId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 204) {
        // Assuming _user is your User object
        _user?.savedPlaces?.add(placeId);
        notifyListeners(); // Notifies listeners about the change.
        return true;
      } else {
        // Handle error
        debugPrint('Error saving place: ${response.body}');
        return false;
      }
    } catch (error) {
      debugPrint('Error saving place: $error');
      return false;
    }
  }

  bool isFavoritePlace(String placeId) {
    return _user?.savedPlaces?.any((place) => place.id == placeId) ?? false;
  }

  Future<bool> toggleFavoriteStatus(Place place) async {
    String? authToken = await _secureStorage.read(key: 'authToken');
    if (authToken == null) return false;

    try {
      // Check if the place is already a favorite
      bool isFavorite =
          _user?.savedPlaces?.any((savedPlace) => savedPlace.id == place.id) ??
              false;

      final response = await http.put(
        Uri.parse('$baseUrl/place/${place.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json
            .encode({'isFavorite': !isFavorite}), // Toggle the favorite status
      );

      if (response.statusCode == 204) {
        // Update the local user object
        if (isFavorite) {
          _user?.savedPlaces
              ?.removeWhere((savedPlace) => savedPlace.id == place.id);
        } else {
          _user?.savedPlaces?.add(place);
        }
        notifyListeners(); // Notifies listeners about the change
        return true;
      } else {
        // Handle error
        debugPrint('Error toggling favorite status: ${response.body}');
        return false;
      }
    } catch (error) {
      debugPrint('Error toggling favorite status: $error');
      return false;
    }
  }

  Future<void> updateFavoriteStatus(Place placeId, bool isFavorite) async {
    if (_user == null) return;

    // Initialize savedPlaces if it's null
    _user!.savedPlaces ??= [];

    if (isFavorite) {
      if (!_user!.savedPlaces!.contains(placeId)) {
        _user!.savedPlaces!.add(placeId);
      }
    } else {
      _user!.savedPlaces!.remove(placeId);
    }
    notifyListeners();
  }

  // Method to remove a place from the user's saved places
  Future<bool> removePlaceFromUser(Place place) async {
    String? authToken = await _secureStorage.read(key: 'authToken');
    if (authToken == null) return false;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/place/${place.id}'), // Use DELETE method
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 204) {
        // Remove the place from the _user's saved places list
        _user?.savedPlaces?.removeWhere((p) => p.id == place.id);
        notifyListeners(); // Notify listeners about the change
        return true;
      } else {
        // Handle error
        debugPrint('Error removing place: ${response.body}');
        return false;
      }
    } catch (error) {
      debugPrint('Error removing place: $error');
      return false;
    }
  }

  // Fetch a user by ID
  Future<User?> fetchUserById(String userId) async {
    // if (_usersCache.containsKey(userId)) {
    //   return _usersCache[userId];
    // }
    final url = Uri.parse('$baseUrl/$userId');
    String? authToken = await _secureStorage.read(key: 'authToken');

    try {
      final response = await http.get(url, headers: {
        'Authorization':
            'Bearer $authToken', // Uncomment and replace token-based auth
        // 'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        debugPrint("User JSON Response: ${response.body}");
        final userJson = json.decode(response.body);
        debugPrint("Decoded JSON: $userJson"); // Additional debugging print
        //
        User fetchedUser = User.fromJson(
            userJson); // Assuming User.fromJson is a constructor that initializes a User object from a JSON map
        _usersCache[userId] = fetchedUser;
        // notifyListeners();
        return fetchedUser;
      } else {
        // Handle non-200 responses
        debugPrint('Failed to fetch user: ${response.body}');
      }
    } catch (error) {
      // Handle network error, throw exception or log it
      debugPrint('Error fetching user: $error');
    }
    return null;
  }

  // register user
  Future<bool> register(User newUser, File? imageFile) async {
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
        bool isAdmin = responseData['admin'];
        // Assuming the response contains 'token' and 'userRole'
        String authToken = responseData['authToken'];
        await _secureStorage.write(key: 'authToken', value: authToken);
        await _secureStorage.write(key: 'admin', value: isAdmin.toString());

        // Update the user with the received data
        _user = newUser.copyWith(
          isAdmin: responseData['admin'],
        );
        notifyListeners();

        // If an image file is provided, upload it
        if (imageFile != null) {
          await uploadImage(imageFile, _user!.id);
          debugPrint("ImageUploaded");
        } else {
          debugPrint("Image is null");
        }
      } else {
        debugPrint("Error in user registration: ${response.body}");
      }
    } catch (e) {
      debugPrint("Exception in registering user: $e");
    }
    return true;
  }

  // upload user profile photo
  Future<void> uploadImage(File image, String userId) async {
    try {
      var request = http.MultipartRequest(
          "POST", Uri.parse("$photoUrl/photos/upload/user"));

      // Add file to the request
      var picture = await http.MultipartFile.fromPath('file', image.path);
      request.files.add(picture);

      // request.addFilePart('file', im)

      // Add userId as a field if needed
      request.fields['userId'] = userId;

      // Read authToken from secure storage and add it to request header
      String? authToken = await _secureStorage.read(key: 'authToken');
      request.headers['Authorization'] = 'Bearer $authToken';

      // Send the request
      var response = await request.send();

      // Handle the response
      if (response.statusCode != 200) {
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
        await fetchUserDetails(); // Fetch user details after login

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
