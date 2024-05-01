package edu.bing.tourguider.pojo.reviews;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;
import lombok.experimental.SuperBuilder;

@Getter
@SuperBuilder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class ReviewRequest {
    private int ratings;
    private String subject;
    private String content;
}
