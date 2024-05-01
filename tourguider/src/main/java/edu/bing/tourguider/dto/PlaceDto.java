package edu.bing.tourguider.dto;

import edu.bing.tourguider.models.Address;
import edu.bing.tourguider.models.Photo;
import edu.bing.tourguider.models.Place;
import edu.bing.tourguider.pojo.places.OperatingHours;
import edu.bing.tourguider.pojo.places.PlaceCategory;
import lombok.Getter;
import lombok.experimental.SuperBuilder;

import java.io.Serializable;
import java.time.DayOfWeek;
import java.util.List;
import java.util.Map;

/**
 * DTO for {@link Place}
 */
@Getter
@SuperBuilder
public class PlaceDto implements Serializable {
    protected String id;
    protected String name;
    protected String description;
    protected Address address;
    protected PlaceCategory category;
    protected List<ReviewDto> reviews;
    protected Double averageRatings;
    protected List<String> contact;
    protected Map<DayOfWeek, OperatingHours> operatingHours;
    protected List<Photo> photos;
}