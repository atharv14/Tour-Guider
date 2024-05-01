package edu.bing.tourguider.models;

import lombok.Data;

@Data
public final class Address {
    private final String street;
    private final String city;
    private final String state;
    private final String country;
    private final String zipCode;
}
