package edu.bing.tourguider.pojo.places;

import edu.bing.tourguider.models.Address;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;
import lombok.experimental.SuperBuilder;

import java.time.DayOfWeek;
import java.util.List;
import java.util.Map;

@Getter
@SuperBuilder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class PlaceRequest {
    protected String name;
    protected String description;
    protected Address address;
    protected List<String> contact;
    protected Map<DayOfWeek, OperatingHours> operatingHours;
}
