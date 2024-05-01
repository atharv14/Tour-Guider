package edu.bing.tourguider.dto;

import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.experimental.SuperBuilder;

import java.util.List;

@Getter
@SuperBuilder
@EqualsAndHashCode(callSuper = true)
public class RestaurantPlaceDto extends PlaceDto {
    protected String type;
    protected List<String> cuisines;
    protected Boolean reservationsRequired;
    protected Double priceForTwo;
}
