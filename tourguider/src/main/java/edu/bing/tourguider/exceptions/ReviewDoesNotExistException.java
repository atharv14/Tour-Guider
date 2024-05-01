package edu.bing.tourguider.exceptions;

public class ReviewDoesNotExistException extends EntityDoesNotExistException {
    public ReviewDoesNotExistException(String field, String value) {
        super("review", field, value);
    }
}
