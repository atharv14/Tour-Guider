package edu.bing.tourguider.exceptions;

public class PlaceDoesNotExistException extends EntityDoesNotExistException {
    public PlaceDoesNotExistException(String field, String value) {
        super("place", field, value);
    }
}
