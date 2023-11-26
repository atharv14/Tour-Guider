// views/favorite_places_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/place_view_model.dart';

class FavoritePlacesView extends StatelessWidget {
  const FavoritePlacesView({super.key});

  @override
  Widget build(BuildContext context) {
    final placeViewModel = Provider.of<PlaceViewModel>(context);
    final favoritePlaces = placeViewModel.getFavoritePlaces();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Places'),
      ),
      body: ListView.builder(
        itemCount: favoritePlaces.length,
        itemBuilder: (ctx, index) {
          final place = favoritePlaces[index];
          return ListTile(
            title: Text(place.name),
            subtitle: Text(place.description),
            // Display other place details here
          );
        },
      ),
    );
  }
}
