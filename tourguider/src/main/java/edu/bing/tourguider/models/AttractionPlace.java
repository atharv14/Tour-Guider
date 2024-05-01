package edu.bing.tourguider.models;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;
import org.springframework.data.annotation.TypeAlias;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@EqualsAndHashCode(callSuper = true)
@SuperBuilder
@NoArgsConstructor
@Document(collection = "places")
@TypeAlias("attraction_place")
public class AttractionPlace extends Place {
    protected String theme;
    protected Boolean kidFriendly;
    protected Boolean parkingAvailable;
    protected Double entryFee;
}
