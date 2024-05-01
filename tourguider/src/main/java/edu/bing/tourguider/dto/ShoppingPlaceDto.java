package edu.bing.tourguider.dto;

import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.experimental.SuperBuilder;

import java.util.List;

@Getter
@SuperBuilder
@EqualsAndHashCode(callSuper = true)
public class ShoppingPlaceDto extends PlaceDto {
    private List<String> associatedBrands;
}
