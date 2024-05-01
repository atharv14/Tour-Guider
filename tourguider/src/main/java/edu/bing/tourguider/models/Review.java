package edu.bing.tourguider.models;

import com.fasterxml.jackson.annotation.JsonBackReference;
import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;
import org.springframework.data.mongodb.core.mapping.DBRef;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@Document(collection = "reviews")
public class Review {
    private String id;
    private int ratings;
    private String subject;
    private String content;
    private LocalDateTime dateTime;
    @EqualsAndHashCode.Exclude
    @ToString.Exclude
    protected List<Photo> photos;
    @DBRef
    @EqualsAndHashCode.Exclude
    @ToString.Exclude
    @JsonBackReference
    private Place place;
    @DBRef
    @EqualsAndHashCode.Exclude
    @ToString.Exclude
    @JsonBackReference
    private User user;
}
