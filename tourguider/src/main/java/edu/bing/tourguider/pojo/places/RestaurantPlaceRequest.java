package edu.bing.tourguider.pojo.places;

import lombok.*;
import lombok.experimental.SuperBuilder;

import java.util.List;

@Getter
@SuperBuilder
@AllArgsConstructor
@NoArgsConstructor
@ToString
@EqualsAndHashCode(callSuper = true)
public class RestaurantPlaceRequest extends PlaceRequest {
    protected String type;
    protected List<String> cuisines;
    protected Boolean reservationsRequired;
    protected Double priceForTwo;
}
