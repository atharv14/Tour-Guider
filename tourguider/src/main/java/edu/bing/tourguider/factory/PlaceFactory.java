package edu.bing.tourguider.factory;

import edu.bing.tourguider.models.AttractionPlace;
import edu.bing.tourguider.models.Place;
import edu.bing.tourguider.models.RestaurantPlace;
import edu.bing.tourguider.models.ShoppingPlace;
import edu.bing.tourguider.pojo.places.*;

public class PlaceFactory {

    public static Place getPlaceFromRequest(PlaceRequest request, PlaceCategory category) {
        switch (category) {
            case SHOPPING:
                return getShoppingPlace((ShoppingPlaceRequest) request);
            case RESTAURANT:
                return getRestaurantPlace((RestaurantPlaceRequest) request);
            case ATTRACTION:
                return getAttractionPlace((AttractionPlaceRequest) request);
            case OTHER:
            default:
                return getPlace(request);
        }
    }

    private static ShoppingPlace getShoppingPlace(ShoppingPlaceRequest request) {
        ShoppingPlace.ShoppingPlaceBuilder<?, ?> builder = ShoppingPlace.builder();
        buildPlace(builder, request);
        return builder
                .associatedBrands(request.getAssociatedBrands())
                .category(PlaceCategory.SHOPPING)
                .build();
    }

    private static RestaurantPlace getRestaurantPlace(RestaurantPlaceRequest request) {
        RestaurantPlace.RestaurantPlaceBuilder<?, ?> builder = RestaurantPlace.builder();
        buildPlace(builder, request);
        return builder.type(request.getType())
                .cuisines(request.getCuisines())
                .reservationsRequired(request.getReservationsRequired())
                .priceForTwo(request.getPriceForTwo())
                .category(PlaceCategory.RESTAURANT)
                .build();
    }

    private static AttractionPlace getAttractionPlace(AttractionPlaceRequest request) {
        AttractionPlace.AttractionPlaceBuilder<?, ?> builder = AttractionPlace.builder();
        buildPlace(builder, request);
        return builder
                .theme(request.getTheme())
                .kidFriendly(request.getKidFriendly())
                .parkingAvailable(request.getParkingAvailable())
                .entryFee(request.getEntryFee())
                .category(PlaceCategory.ATTRACTION)
                .build();
    }

    private static Place getPlace(PlaceRequest request) {
        Place.PlaceBuilder<?, ?> builder = Place.builder();
        buildPlace(builder, request);
        return builder.category(PlaceCategory.OTHER).build();
    }

    private static void buildPlace(Place.PlaceBuilder<?, ?> builder, PlaceRequest request) {
        builder.name(request.getName())
                .description(request.getDescription())
                .address(request.getAddress())
                .contact(request.getContact())
                .operatingHours(request.getOperatingHours());
    }

}
