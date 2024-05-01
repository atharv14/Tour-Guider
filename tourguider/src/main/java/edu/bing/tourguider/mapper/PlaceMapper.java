package edu.bing.tourguider.mapper;

import edu.bing.tourguider.dto.AttractionPlaceDto;
import edu.bing.tourguider.dto.PlaceDto;
import edu.bing.tourguider.dto.RestaurantPlaceDto;
import edu.bing.tourguider.dto.ShoppingPlaceDto;
import edu.bing.tourguider.models.*;
import org.springframework.util.CollectionUtils;

import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

public class PlaceMapper {
    public static PlaceDto toDto(Place place) {
        switch (place.getCategory()) {
            case SHOPPING:
                return toShoppingDto((ShoppingPlace) place);
            case RESTAURANT:
                return toRestaurantDto((RestaurantPlace) place);
            case ATTRACTION:
                return toAttractionDto((AttractionPlace) place);
            case OTHER:
            default:
                PlaceDto.PlaceDtoBuilder<?, ?> builder = PlaceDto.builder();
                buildPlace(builder, place);
                return builder.build();
        }
    }

    private static AttractionPlaceDto toAttractionDto(AttractionPlace place) {
        AttractionPlaceDto.AttractionPlaceDtoBuilder<?, ?> builder = AttractionPlaceDto.builder();
        buildPlace(builder, place);
        return builder
                .theme(place.getTheme())
                .kidFriendly(place.getKidFriendly())
                .parkingAvailable(place.getParkingAvailable())
                .entryFee(place.getEntryFee())
                .build();
    }

    private static ShoppingPlaceDto toShoppingDto(ShoppingPlace place) {
        ShoppingPlaceDto.ShoppingPlaceDtoBuilder<?, ?> builder = ShoppingPlaceDto.builder();
        buildPlace(builder, place);
        return builder
                .associatedBrands(place.getAssociatedBrands())
                .build();
    }

    public static RestaurantPlaceDto toRestaurantDto(RestaurantPlace restaurantPlace) {
        RestaurantPlaceDto.RestaurantPlaceDtoBuilder<?, ?> builder = RestaurantPlaceDto.builder();
        buildPlace(builder, restaurantPlace);
        return builder.type(restaurantPlace.getType())
                .cuisines(restaurantPlace.getCuisines())
                .reservationsRequired(restaurantPlace.getReservationsRequired())
                .priceForTwo(restaurantPlace.getPriceForTwo())
                .build();
    }

    public static void buildPlace(PlaceDto.PlaceDtoBuilder<?, ?> builder, Place place) {
        builder.id(place.getId())
                .name(place.getName())
                .description(place.getDescription())
                .address(place.getAddress())
                .category(place.getCategory())
                .reviews(ReviewMapper.mapToList(place.getReviews()))
                .averageRatings(getAverageRatings(place.getReviews()))
                .contact(place.getContact())
                .operatingHours(place.getOperatingHours())
                .photos(place.getPhotos());

    }

    private static Double getAverageRatings(List<Review> reviews) {
        return CollectionUtils.isEmpty(reviews) ? null : computeAverageRatings(reviews);
    }

    private static double computeAverageRatings(List<Review> reviews) {
        return reviews.stream()
                .mapToInt(Review::getRatings)
                .average()
                .orElse(0);
    }

    public static Collection<PlaceDto> mapToList(List<Place> savedPlaces) {
        if (CollectionUtils.isEmpty(savedPlaces))
            return null;
        return savedPlaces.stream().map(PlaceMapper::toDto).collect(Collectors.toList());
    }
}
