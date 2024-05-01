package edu.bing.tourguider.service;

import edu.bing.tourguider.dto.PlaceDto;
import edu.bing.tourguider.exceptions.PlaceDoesNotExistException;
import edu.bing.tourguider.factory.PlaceFactory;
import edu.bing.tourguider.mapper.PlaceMapper;
import edu.bing.tourguider.models.*;
import edu.bing.tourguider.pojo.places.*;
import edu.bing.tourguider.repository.PlaceRepository;
import edu.bing.tourguider.repository.ReviewRepository;
import edu.bing.tourguider.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PlaceService {

    private final PlaceRepository placeRepository;
    private final ReviewRepository reviewRepository;
    private final UserRepository userRepository;

    public Collection<PlaceDto> fetchAllPlaces() {
        return placeRepository.findAll()
                .stream()
                .map(PlaceMapper::toDto)
                .collect(Collectors.toList());
    }

    public Place createPlace(PlaceRequest request, PlaceCategory category) {
        Place place = PlaceFactory.getPlaceFromRequest(request, category);
        return placeRepository.save(place);
    }

    public PlaceDto fetchPlaceById(String id) {
        return placeRepository.findById(id).map(PlaceMapper::toDto).orElseThrow(() -> new PlaceDoesNotExistException("id", id));
    }

    public void deletePlace(String id) {
//        1. Find the place to delete
        Place placeToDelete = placeRepository.findById(id).orElseThrow(() -> new PlaceDoesNotExistException("id", id));

//        2. Find the reviews associated with the place and remove them
        List<Review> placeReviews = reviewRepository.findByPlace_Id(placeToDelete.getId());
        reviewRepository.deleteAll(placeReviews);

//        3. Finds the users associated with the place and remove the place from saved places
        List<User> usersThatSavedPlace = userRepository.findBySavedPlaces_Id(placeToDelete.getId());
        usersThatSavedPlace.forEach(user -> user.getSavedPlaces().removeIf(place -> place.getId().equals(placeToDelete.getId())));
        userRepository.saveAll(usersThatSavedPlace);

//        4. Delete the place
        placeRepository.delete(placeToDelete);
    }

    public Place updatePlace(String id, PlaceRequest request) {
        Place placeToUpdate = placeRepository.findById(id).orElseThrow(() -> new PlaceDoesNotExistException("id", id));
        switch (placeToUpdate.getCategory()) {
            case RESTAURANT:
                updateRestaurantPlace((RestaurantPlace) placeToUpdate, (RestaurantPlaceRequest) request);
                break;
            case SHOPPING:
                updateShoppingPlace((ShoppingPlace) placeToUpdate, (ShoppingPlaceRequest) request);
                break;
            case ATTRACTION:
                updateAttractionPlace((AttractionPlace) placeToUpdate, (AttractionPlaceRequest) request);
                break;
            case OTHER:
            default:
                updatePlace(placeToUpdate, request);
                break;
        }
        return placeRepository.save(placeToUpdate);
    }

    private void updatePlace(Place placeToUpdate, PlaceRequest request) {
        placeToUpdate.setName(request.getName());
        placeToUpdate.setDescription(request.getDescription());
        placeToUpdate.setAddress(request.getAddress());
        placeToUpdate.setContact(request.getContact());
        placeToUpdate.setOperatingHours(request.getOperatingHours());
    }

    private void updateRestaurantPlace(RestaurantPlace place, RestaurantPlaceRequest request) {
        updatePlace(place, request);
        place.setType(request.getType());
        place.setCuisines(request.getCuisines());
        place.setReservationsRequired(request.getReservationsRequired());
        place.setPriceForTwo(request.getPriceForTwo());
    }

    private void updateShoppingPlace(ShoppingPlace place, ShoppingPlaceRequest request) {
        updatePlace(place, request);
        place.setAssociatedBrands(request.getAssociatedBrands());
    }

    private void updateAttractionPlace(AttractionPlace place, AttractionPlaceRequest request) {
        updatePlace(place, request);
        place.setTheme(request.getTheme());
        place.setKidFriendly(request.getKidFriendly());
        place.setParkingAvailable(request.getParkingAvailable());
        place.setEntryFee(request.getEntryFee());
    }

    public List<PlaceDto> searchPlaces(String searchText) {
        List<Place> searchedPlaces = placeRepository.findByTextSearch(searchText);
        return searchedPlaces.stream()
                .map(PlaceMapper::toDto)
                .collect(Collectors.toList());
    }

}
