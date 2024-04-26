import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tour_guider/provider/PlaceProvider.dart';
import 'dart:io';
import '../models/Attraction.dart';
import '../models/Restaurant.dart';
import '../models/Shopping.dart';
import '../models/place.dart';
import '../models/place_category.dart';
// Import your PlaceProvider and models

class PlaceCreationScreen extends StatefulWidget {
  @override
  _PlaceCreationScreenState createState() => _PlaceCreationScreenState();
}

class _PlaceCreationScreenState extends State<PlaceCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  // Address Controllers
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  // Attraction Specific Controllers
  final TextEditingController _entryFeeController = TextEditingController();
  final TextEditingController _themeController = TextEditingController();
  bool _kidFriendly = false;
  bool _parkingAvailable = false;

  // Restaurant Specific Controllers
  final TextEditingController _cuisineController = TextEditingController();
  final TextEditingController _priceForTwoController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  bool _reservationsRequired = false;

  // Shopping Specific Controllers
  final TextEditingController _brandController = TextEditingController();

  PlaceCategory _selectedCategory = PlaceCategory.Attraction;

  Map<String, Map<String, dynamic>> operatingHours = {
    for (var day in [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY'
    ])
      day: {
        'opening': {'hour': '0', 'minute': '0', 'nano': 0, 'second': '0'},
        'closing': {'hour': '0', 'minute': '0', 'nano': 0, 'second': '0'},
      }
  };

  final List<File> _images = []; // To store picked images temporarily
  final ImagePicker _picker = ImagePicker();

// Function to pick images
  void _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _images.addAll(images.map((xFile) => File(xFile.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _pickTime(BuildContext context, String day, bool isOpeningTime) async {
    final now = DateTime.now();
    final initialTime = TimeOfDay(hour: now.hour, minute: now.minute);
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      setState(() {
        operatingHours[day]![isOpeningTime ? 'opening' : 'closing'] = {
          'hour': pickedTime.hour.toString(),
          'minute': pickedTime.minute.toString(),
          'nano': 0, // Static value as Flutter doesn't provide nanoseconds
          'second': '' // Static value, or calculate from DateTime if needed
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final placeProvider = Provider.of<PlaceProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Place')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter the place name';
                  return null;
                },
              ),
              DropdownButtonFormField<PlaceCategory>(
                value: _selectedCategory,
                onChanged: (PlaceCategory? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                items: PlaceCategory.values.map((PlaceCategory category) {
                  return DropdownMenuItem<PlaceCategory>(
                    value: category,
                    child: Text(category.toString().split('.').last),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the place description';
                  }
                  return null;
                },
              ),
              // Contact
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact'),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter the place contact';
                  return null;
                },
              ),
              // Address Fields with rows
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(labelText: 'Street'),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter the street';
                  return null;
                },
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'City'),
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter the city';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8), // Spacing between the inputs
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(labelText: 'State'),
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter the state';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _zipCodeController,
                      decoration: const InputDecoration(labelText: 'Zip Code'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter the zip code';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8), // Spacing between the inputs
                  Expanded(
                    child: TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(labelText: 'Country'),
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter the country';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              // Operating Hours
              ...operatingHours.keys.map((day) => ListTile(
                    title: Text(day),
                    subtitle: Text(
                      'Open: ${operatingHours[day]!['opening']['hour']}:${operatingHours[day]!['opening']['minute'].toString().padLeft(2, '0')} - '
                      'Close: ${operatingHours[day]!['closing']['hour']}:${operatingHours[day]!['closing']['minute'].toString().padLeft(2, '0')}',
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () {
                      _pickTime(context, day, false);
                      _pickTime(context, day, true);
                    },
                  )),

              // category specific fields
              ..._buildCategorySpecificFields(),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _pickImages,
                child: const Text("Pick Images"),
              ),
              GridView.builder(
                shrinkWrap: true,
                itemCount: _images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of columns
                  crossAxisSpacing: 4.0, // Horizontal space between items
                  mainAxisSpacing: 4.0, // Vertical space between items
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        _images[index],
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        right: 5,
                        top: 5,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              ElevatedButton(
                child: const Text('Create Place'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Build place data based on category and send to provider
                    await _handlePlaceCreation(placeProvider);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, Map<String, String>> formatOperatingHours() {
    Map<String, Map<String, String>> formattedHours = {};
    operatingHours.forEach((day, times) {
      String openingTime =
          '${times['opening']['hour'].toString().padLeft(2, '0')}:${times['opening']['minute'].toString().padLeft(2, '0')}';
      String closingTime =
          '${times['closing']['hour'].toString().padLeft(2, '0')}:${times['closing']['minute'].toString().padLeft(2, '0')}';
      formattedHours[day] = {
        "openingTime": openingTime,
        "closingTime": closingTime
      };
    });
    return formattedHours;
  }

  List<Widget> _buildCategorySpecificFields() {
    List<Widget> categoryFields = [];
    switch (_selectedCategory) {
      case PlaceCategory.Attraction:
        categoryFields.addAll([
          TextFormField(
            controller: _entryFeeController,
            decoration: const InputDecoration(labelText: 'Entry Fee'),
            keyboardType: TextInputType.number,
            validator: (value) =>
                value!.isEmpty ? 'Entry fee cannot be empty' : null,
          ),
          TextFormField(
            controller: _themeController,
            decoration: const InputDecoration(labelText: 'Theme'),
            validator: (value) =>
                value!.isEmpty ? 'Theme cannot be empty' : null,
          ),
          SwitchListTile(
            title: const Text('Kid Friendly'),
            value: _kidFriendly,
            onChanged: (bool value) {
              setState(() {
                _kidFriendly = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Parking Available'),
            value: _parkingAvailable,
            onChanged: (bool value) {
              setState(() {
                _parkingAvailable = value;
              });
            },
          ),
        ]);
        break;
      case PlaceCategory.Restaurant:
        categoryFields.addAll([
          TextFormField(
            controller: _cuisineController,
            decoration: const InputDecoration(labelText: 'Cuisines'),
            validator: (value) =>
                value!.isEmpty ? 'Cuisines cannot be empty' : null,
          ),
          TextFormField(
            controller: _priceForTwoController,
            decoration: const InputDecoration(labelText: 'Price for Two'),
            keyboardType: TextInputType.number,
            validator: (value) =>
                value!.isEmpty ? 'Price for two cannot be empty' : null,
          ),TextFormField(
            controller: _typeController,
            decoration: const InputDecoration(labelText: 'Type of Restaurant ex: Dining'),
            validator: (value) =>
                value!.isEmpty ? 'Type of Restaurant cannot be empty' : null,
          ),
          SwitchListTile(
            title: const Text('Reservations Required'),
            value: _reservationsRequired,
            onChanged: (bool value) {
              setState(() {
                _reservationsRequired = value;
              });
            },
          ),
        ]);
        break;
      case PlaceCategory.Shopping:
        categoryFields.add(
          TextFormField(
            controller: _brandController,
            decoration: const InputDecoration(labelText: 'Associated Brands'),
            validator: (value) =>
                value!.isEmpty ? 'Associated brands cannot be empty' : null,
          ),
        );
        break;
      case PlaceCategory.Other:
        // Add fields for the 'Other' category if needed
        break;
    }
    return categoryFields;
  }

  Future<void> _handlePlaceCreation(PlaceProvider placeProvider) async {
    if (_formKey.currentState!.validate()) {
      // Address Mapping
      Map<String, dynamic> addressMap = {
        "street": _streetController.text,
        "city": _cityController.text,
        "state": _stateController.text,
        "zipCode": _zipCodeController.text,
        "country": _countryController.text
      };

      debugPrint('contactList: ${_contactController.text}');

      // Convert the contact string into a list
      List<String> contactList = _contactController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      // Format operating hours using the helper function
      var formattedOperatingHours = formatOperatingHours();

      Place place;
      switch (_selectedCategory) {
        case PlaceCategory.Attraction:
          place = Attraction(
            id: '', // ID will be assigned by the backend upon creation
            name: _nameController.text,
            description: _descriptionController.text,
            category: _selectedCategory.toString().split('.').last,
            address: addressMap,
            contactInfo: contactList,
            entryFee: double.parse(_entryFeeController.text),
            theme: _themeController.text,
            kidFriendly: _kidFriendly,
            parkingAvailable: _parkingAvailable,
            operatingHours: formattedOperatingHours,
            reviews: [], // Initialize empty, assuming backend handles reviews
            imageUrl: [], // Todo uploading images for places
            averageRating:
                null, // Initialize empty, assuming backend handles reviews
          );
          break;
        case PlaceCategory.Restaurant:
          place = Restaurant(
            id: '',
            name: _nameController.text,
            description: _descriptionController.text,
            category: _selectedCategory.toString().split('.').last,
            address: addressMap,
            contactInfo: contactList,
            cuisines: _cuisineController.text
                .split(',')
                .map((e) => e.trim())
                .toList(),
            priceForTwo: double.parse(_priceForTwoController.text),
            reservationsRequired: _reservationsRequired,
            operatingHours: formattedOperatingHours,
            reviews: [],
            imageUrl: [],
            averageRating: null,
            type: _typeController.text,
          );
          break;
        case PlaceCategory.Shopping:
          place = Shopping(
            id: '',
            name: _nameController.text,
            description: _descriptionController.text,
            category: _selectedCategory.toString().split('.').last,
            address: addressMap,
            contactInfo: contactList,
            associatedBrands:
                _brandController.text.split(',').map((e) => e.trim()).toList(),
            operatingHours: formattedOperatingHours,
            reviews: [],
            imageUrl: [],
            averageRating: null,
          );
          break;
        case PlaceCategory.Other:
        default:
          place = Place(
            id: '',
            name: _nameController.text,
            description: _descriptionController.text,
            category: _selectedCategory.toString().split('.').last,
            address: addressMap,
            contactInfo: contactList,
            operatingHours: formattedOperatingHours,
            reviews: [],
            imageUrl: [],
            averageRating: null,
          );
          break;
      }

      Map<String, dynamic> result = await placeProvider.createPlace(place);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Place created successfully')),
        );
        String placeId = result['placeId'];
        // After successful place creation, upload images
        if (_images.isNotEmpty) {
          await placeProvider.uploadImagesForPlace(_images, placeId);
        }
        Navigator.pop(context); // Go back to previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create place')),
        );
      }
    }
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _nameController.dispose();
    _descriptionController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _contactController.dispose();
    _entryFeeController.dispose();
    _themeController.dispose();
    _cuisineController.dispose();
    _typeController.dispose();
    _priceForTwoController.dispose();
    _brandController.dispose();
    super.dispose();
  }
}
