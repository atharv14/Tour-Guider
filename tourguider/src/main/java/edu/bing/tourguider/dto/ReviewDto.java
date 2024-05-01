package edu.bing.tourguider.dto;

import edu.bing.tourguider.models.Photo;
import edu.bing.tourguider.models.Review;
import lombok.Builder;
import lombok.Value;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;

/**
 * DTO for {@link Review}
 */
@Value
@Builder
public class ReviewDto implements Serializable {
    String id;
    int ratings;
    String subject;
    String content;
    LocalDateTime dateTime;
    String userId;
    String placeId;
    List<Photo> photos;

}