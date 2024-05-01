package edu.bing.tourguider.models;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import edu.bing.tourguider.pojo.places.OperatingHours;
import edu.bing.tourguider.pojo.places.PlaceCategory;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;
import lombok.experimental.SuperBuilder;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.TypeAlias;
import org.springframework.data.mongodb.core.mapping.DBRef;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.DayOfWeek;
import java.util.List;
import java.util.Map;

@Data
@Document(collection = "places")
@SuperBuilder
@NoArgsConstructor
@TypeAlias("place")
public class Place {
    @Id
    protected String id;
    protected String name;
    protected String description;
    protected Address address;
    protected PlaceCategory category;
    @DBRef
    @EqualsAndHashCode.Exclude
    @ToString.Exclude
    @JsonManagedReference
    protected List<Review> reviews;
    @EqualsAndHashCode.Exclude
    @ToString.Exclude
    protected List<Photo> photos;
    protected List<String> contact;
    protected Map<DayOfWeek, OperatingHours> operatingHours;
}
