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
public class ShoppingPlaceRequest extends PlaceRequest {
    private List<String> associatedBrands;
}
