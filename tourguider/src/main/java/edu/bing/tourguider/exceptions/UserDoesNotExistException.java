package edu.bing.tourguider.exceptions;

public class UserDoesNotExistException extends EntityDoesNotExistException {
    public UserDoesNotExistException(String field, String value) {
        super("user", field, value);
    }
}
