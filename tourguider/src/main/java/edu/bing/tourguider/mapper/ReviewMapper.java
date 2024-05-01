package edu.bing.tourguider.mapper;

import edu.bing.tourguider.dto.ReviewDto;
import edu.bing.tourguider.models.Place;
import edu.bing.tourguider.models.Review;
import edu.bing.tourguider.models.User;
import edu.bing.tourguider.pojo.reviews.ReviewRequest;
import org.springframework.util.CollectionUtils;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

public class ReviewMapper {
    public static ReviewDto toMap(Review review) {
        return ReviewDto.builder()
                .id(review.getId())
                .ratings(review.getRatings())
                .subject(review.getSubject())
                .content(review.getContent())
                .dateTime(review.getDateTime())
                .userId(review.getUser().getId())
                .placeId(review.getPlace().getId())
                .photos(review.getPhotos())
                .build();
    }

    public static List<ReviewDto> mapToList(List<Review> reviews) {
        if (CollectionUtils.isEmpty(reviews))
            return null;
        return reviews.stream().map(ReviewMapper::toMap).collect(Collectors.toList());
    }

    public static Review fromRequest(ReviewRequest reviewRequest, Place place, User user) {
        return Review.builder()
                .ratings(reviewRequest.getRatings())
                .subject(reviewRequest.getSubject())
                .content(reviewRequest.getContent())
                .dateTime(LocalDateTime.now())
                .user(user)
                .place(place)
                .build();
    }
}
