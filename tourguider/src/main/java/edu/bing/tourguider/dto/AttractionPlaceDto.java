package edu.bing.tourguider.dto;

import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.experimental.SuperBuilder;

@Getter
@SuperBuilder
@EqualsAndHashCode(callSuper = true)
public class AttractionPlaceDto extends PlaceDto {
    protected String theme;
    protected Boolean kidFriendly;
    protected Boolean parkingAvailable;
    protected Double entryFee;
}
