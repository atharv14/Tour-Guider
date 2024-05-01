package edu.bing.tourguider.models;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;
import org.springframework.data.annotation.TypeAlias;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.List;

@Data
@EqualsAndHashCode(callSuper = true)
@SuperBuilder
@NoArgsConstructor
@Document(collection = "places")
@TypeAlias("restaurant_place")
public class RestaurantPlace extends Place {
    protected String type;
    protected List<String> cuisines;
    protected Boolean reservationsRequired;
    protected Double priceForTwo;
}
