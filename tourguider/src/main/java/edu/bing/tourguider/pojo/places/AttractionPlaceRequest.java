package edu.bing.tourguider.pojo.places;

import lombok.*;
import lombok.experimental.SuperBuilder;

@Getter
@SuperBuilder
@AllArgsConstructor
@NoArgsConstructor
@ToString
@EqualsAndHashCode(callSuper = true)
public class AttractionPlaceRequest extends PlaceRequest {
    protected String theme;
    protected Boolean kidFriendly;
    protected Boolean parkingAvailable;
    protected Double entryFee;
}
