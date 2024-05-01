import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tour_guider/provider/PlaceProvider.dart';
import 'package:tour_guider/provider/UserProvider.dart';
import '../models/attraction.dart';
import '../models/place.dart'; // Make sure to import your Place model
import 'dart:io';

import '../models/restaurant.dart';
import '../models/shopping.dart';
import '../provider/ReviewProvider.dart';

class UpdatePlaceScreen extends StatefulWidget {
  final Place place;

  const UpdatePlaceScreen({super.key, required this.place});

  @override
  _UpdatePlaceScreenState createState() => _UpdatePlaceScreenState();
}

class _UpdatePlaceScreenState extends State<UpdatePlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _contactController;

  // Address Controllers
  TextEditingController _streetController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController _zipCodeController = TextEditingController();
  TextEditingController _countryController = TextEditingController();

  // Operating Hours Controllers
  final Map<String, Map<String, TextEditingController>>
      _operatingHoursControllers = {};

  // Attraction Specific Controllers
  TextEditingController _entryFeeController = TextEditingController();
  TextEditingController _themeController = TextEditingController();
  bool _kidFriendly = false;
  bool _parkingAvailable = false;

  // Restaurant Specific Controllers
  TextEditingController _cuisineController = TextEditingController();
  TextEditingController _priceForTwoController = TextEditingController();
  TextEditingController _typeController = TextEditingController();
  bool _reservationsRequired = false;

  // Shopping Specific Controllers
  TextEditingController _brandController = TextEditingController();

  // Display Images
  List<MemoryImage> _placeImages = [];
  final List<File> _newImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.place.description);
    _contactController =
        TextEditingController(text: widget.place.contactInfo.join(', '));

    // Initialize address controllers
    _streetController =
        TextEditingController(text: widget.place.address['street']);
    _cityController = TextEditingController(text: widget.place.address['city']);
    _stateController =
        TextEditingController(text: widget.place.address['state']);
    _zipCodeController =
        TextEditingController(text: widget.place.address['zipCode']);
    _countryController =
        TextEditingController(text: widget.place.address['country']);

    _initOperatingHours();

    // Initialize controllers based on type of place
    if (widget.place is Attraction) {
      Attraction attraction = widget.place as Attraction;
      _entryFeeController =
          TextEditingController(text: attraction.entryFee.toString());
      _themeController = TextEditingController(text: attraction.theme);
      _kidFriendly = attraction.kidFriendly;
      _parkingAvailable = attraction.parkingAvailable;
    } else if (widget.place is Restaurant) {
      Restaurant restaurant = widget.place as Restaurant;
      _cuisineController =
          TextEditingController(text: restaurant.cuisines.join(', '));
      _priceForTwoController =
          TextEditingController(text: restaurant.priceForTwo.toString());
      _typeController = TextEditingController(text: restaurant.type);
      _reservationsRequired = restaurant.reservationsRequired;
    } else if (widget.place is Shopping) {
      Shopping shopping = widget.place as Shopping;
      _brandController =
          TextEditingController(text: shopping.associatedBrands.join(', '));
    }

    // Existing images
    var imageUrl = widget.place.imageUrl;
    var provider = Provider.of<PlaceProvider>(context, listen: false);
    provider.downloadImagesForPlace(widget.place.id, imageUrl);
    // Update the state with existing images
    _placeImages = provider.getImagesForPlace(widget.place.id);
  }

  void _initOperatingHours() {
    _operatingHoursControllers.clear();
    const days = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY'
    ];
    for (var day in days) {
      String openingTime = '00:00'; // Default opening time
      String closingTime = '00:00'; // Default closing time

      if (widget.place.operatingHours.containsKey(day)) {
        var hours = widget.place.operatingHours[day];
        if (hours != null && hours is Map<String, dynamic>) {
          // Ensure 'openingTime' and 'closingTime' are treated as strings
          openingTime = hours['openingTime'] ?? '00:00';
          closingTime = hours['closingTime'] ?? '00:00';

          // Debugging: Log the values we are receiving
          debugPrint(
              'Operating hours for $day: Opening - $openingTime, Closing - $closingTime');
        } else {
          debugPrint('No valid hours data for $day, received: $hours');
        }
      } else {
        debugPrint('Operating hours data missing for $day');
      }

      _operatingHoursControllers[day] = {
        'opening': TextEditingController(text: openingTime),
        'closing': TextEditingController(text: closingTime)
      };
    }
  }

  String formatTimeFromJson(Map<String, dynamic>? time) {
    if (time != null &&
        time.containsKey('hour') &&
        time.containsKey('minute')) {
      int hour = time['hour'];
      int minute = time['minute'];
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }
    return '00:00'; // Default time if the input is null or incomplete
  }

  void _pickTime(BuildContext context, String day, bool isOpeningTime) async {
    var currentText =
        _operatingHoursControllers[day]![isOpeningTime ? 'opening' : 'closing']!
            .text;
    var initialTime =
        TimeOfDay.fromDateTime(DateFormat.Hm().parse(currentText));

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      setState(() {
        _operatingHoursControllers[day]![isOpeningTime ? 'opening' : 'closing']!
                .text =
            '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    setState(() {
      _newImages.addAll(images.map((xFile) => File(xFile.path)));
    });
  }

  Future<void> _updatePlace() async {
    if (_formKey.currentState!.validate()) {
      // Assign updated values back to the place object
      widget.place.description = _descriptionController.text;
      widget.place.contactInfo =
          _contactController.text.split(',').map((e) => e.trim()).toList();

      // Address
      widget.place.address = {
        'street': _streetController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'zipCode': _zipCodeController.text,
        'country': _countryController.text
      };

      // Operating Hours
      widget.place.operatingHours = {};
      _operatingHoursControllers.forEach((day, controllers) {
        widget.place.operatingHours[day] = {
          'openingTime': controllers['opening']!.text,
          'closingTime': controllers['closing']!.text
        };
      });

      // Handle the specific fields per type
      if (widget.place is Attraction) {
        (widget.place as Attraction).entryFee =
            double.parse(_entryFeeController.text);
        (widget.place as Attraction).theme = _themeController.text;
        (widget.place as Attraction).kidFriendly = _kidFriendly;
        (widget.place as Attraction).parkingAvailable = _parkingAvailable;
      } else if (widget.place is Restaurant) {
        (widget.place as Restaurant).cuisines =
            _cuisineController.text.split(',').map((e) => e.trim()).toList();
        (widget.place as Restaurant).priceForTwo =
            double.parse(_priceForTwoController.text);
        (widget.place as Restaurant).type = _typeController.text;
        (widget.place as Restaurant).reservationsRequired =
            _reservationsRequired;
      } else if (widget.place is Shopping) {
        (widget.place as Shopping).associatedBrands =
            _brandController.text.split(',').map((e) => e.trim()).toList();
      }

      var provider = Provider.of<PlaceProvider>(context, listen: false);
      // if (_newImages.isNotEmpty) {
      //   await provider.uploadImagesForPlace(_newImages, widget.place.id);
      // }

      var result = await provider.updatePlace(widget.place);

      List<File> imagesToUpload = [];

      // Convert existing MemoryImage to File
      for (int i = 0; i < _placeImages.length; i++) {
        File file =
            await memoryImageToFile(_placeImages[i], 'existing_image_$i.png');
        imagesToUpload.add(file);
      }

      // Add new images
      imagesToUpload.addAll(_newImages);

      // Upload all images
      if (imagesToUpload.isNotEmpty) {
        await Provider.of<PlaceProvider>(context, listen: false).uploadImagesForPlace(imagesToUpload, widget.place.id);
        // Update the place object with new image URLs
        // widget.place.imageUrl?.addAll(newImageUrls);
        // Once uploaded, clear both lists
        _placeImages.clear();
        _newImages.clear();
        debugPrint("All images uploaded successfully");
      } else {
        debugPrint("No images to upload");
      }

      // var result = await provider.updatePlace(widget.place);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Place updated successfully')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to update place: ${result['message']}')));
      }
    }
  }

  Future<File> memoryImageToFile(MemoryImage image, String imageName) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$imageName');
    await file.writeAsBytes(image.bytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update ${widget.place.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              var provider = Provider.of<PlaceProvider>(context, listen: false);
              var userProvider = Provider.of<UserProvider>(context, listen: false);
              var reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
              bool deleted = await provider.deletePlace(widget.place.id, userProvider, reviewProvider);
              if (deleted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Place deleted successfully')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete place')));
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact Info'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact info';
                  }
                  return null;
                },
              ),
              _buildTextField(
                  _streetController, 'Street', 'Please enter the street'),
              _buildTextField(_cityController, 'City', 'Please enter the city'),
              _buildTextField(
                  _stateController, 'State', 'Please enter the state'),
              _buildTextField(
                  _zipCodeController, 'Zip Code', 'Please enter the zip code'),
              _buildTextField(
                  _countryController, 'Country', 'Please enter the country'),
              ..._operatingHoursControllers.keys.map((day) => ListTile(
                    title: Text(day),
                    subtitle: Text(
                      'Open: ${_operatingHoursControllers[day]!['opening']!.text} - Close: ${_operatingHoursControllers[day]!['closing']!.text}',
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () {
                      _pickTime(context, day, false); // Opening time
                      _pickTime(context, day, true); // Closing time
                    },
                  )),
              if (widget.place is Attraction) ...[
                TextFormField(
                  controller: _entryFeeController,
                  decoration: const InputDecoration(labelText: 'Entry Fee'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter entry fee';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _themeController,
                  decoration: const InputDecoration(labelText: 'Theme'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter entry fee';
                    }
                    return null;
                  },
                ),
                _buildCupertinoSwitchTile("Kid Friendly", _kidFriendly,
                    (bool value) {
                  setState(() {
                    _kidFriendly = value;
                  });
                }),
                _buildCupertinoSwitchTile(
                    "Parking Available", _parkingAvailable, (bool value) {
                  setState(() {
                    _parkingAvailable = value;
                  });
                }),
              ],
              if (widget.place is Restaurant) ...[
                TextFormField(
                  controller: _cuisineController,
                  decoration: const InputDecoration(labelText: 'Cuisines'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter entry fee';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceForTwoController,
                  decoration: const InputDecoration(labelText: 'Price for Two'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter entry fee';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _typeController,
                  decoration:
                      const InputDecoration(labelText: 'Type of Restaurant'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter entry fee';
                    }
                    return null;
                  },
                ),
                _buildCupertinoSwitchTile(
                    "Reservation Required", _reservationsRequired,
                    (bool value) {
                  setState(() {
                    _reservationsRequired = value;
                  });
                }),
              ],
              if (widget.place is Shopping) ...[
                TextFormField(
                  controller: _brandController,
                  decoration:
                      const InputDecoration(labelText: 'Associated Brands'),
                ),
              ],
              ElevatedButton(
                onPressed: _pickImages,
                child: const Text("Pick Images"),
              ),
              // Modify the GridView.builder to display both existing and new images
              GridView.builder(
                shrinkWrap: true,
                itemCount: _placeImages.length + _newImages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  if (index < _placeImages.length) {
                    // Display existing images
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(
                          _placeImages[index].bytes,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: 5,
                          top: 5,
                          child: GestureDetector(
                            onTap: () {
                              // Handle deletion of existing image
                              // You can add the logic here to delete the image from the backend as well
                              setState(() {
                                _placeImages.removeAt(index);
                              });
                            },
                            child: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Display newly picked images
                    final newIndex = index - _placeImages.length;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          _newImages[newIndex],
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: 5,
                          top: 5,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _newImages.removeAt(newIndex);
                              });
                            },
                            child: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),

              ElevatedButton(
                onPressed: _updatePlace,
                child: const Text('Update Place'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String errorText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorText;
        }
        return null;
      },
    );
  }

  Widget _buildCupertinoSwitchTile(
      String title, bool value, void Function(bool) onChanged) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value ? "Yes" : "No"),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _contactController.dispose();
    _entryFeeController.dispose();
    _themeController.dispose();
    _cuisineController.dispose();
    _priceForTwoController.dispose();
    _typeController.dispose();
    _brandController.dispose();
    // Address
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }
}
