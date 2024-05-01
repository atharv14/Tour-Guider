package edu.bing.tourguider.exceptions;

public class EntityDoesNotExistException extends RuntimeException {
    public EntityDoesNotExistException(String entity, String field, String value) {
        super(String.format("No %s exists for %s: %s", entity, field, value));
    }
}
