package edu.bing.tourguider.service;

import edu.bing.tourguider.dto.ReviewDto;
import edu.bing.tourguider.exceptions.PlaceDoesNotExistException;
import edu.bing.tourguider.exceptions.ReviewDoesNotExistException;
import edu.bing.tourguider.mapper.ReviewMapper;
import edu.bing.tourguider.models.Place;
import edu.bing.tourguider.models.Review;
import edu.bing.tourguider.models.User;
import edu.bing.tourguider.pojo.reviews.ReviewRequest;
import edu.bing.tourguider.repository.PlaceRepository;
import edu.bing.tourguider.repository.ReviewRepository;
import edu.bing.tourguider.repository.UserRepository;
import edu.bing.tourguider.util.AuthUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final PlaceRepository placeRepository;
    private final UserRepository userRepository;

    public List<ReviewDto> fetchReviewsByPlace(String placeId) {
        return reviewRepository.findByPlace_Id(placeId).stream()
                .map(ReviewMapper::toMap)
                .collect(Collectors.toList());
    }

    public ReviewDto createReview(ReviewRequest reviewRequest, String placeId) {
        Place place = placeRepository.findById(placeId).orElseThrow(() -> new PlaceDoesNotExistException("id", placeId));
        User loggedInUser = AuthUtils.getLoggedInUser();
        Review review = ReviewMapper.fromRequest(reviewRequest, place, loggedInUser);
        Review savedReview = reviewRepository.save(review);

        if (CollectionUtils.isEmpty(place.getReviews())) {
            place.setReviews(new ArrayList<>());
        }
        place.getReviews().add(savedReview);
        placeRepository.save(place);

        if (CollectionUtils.isEmpty(loggedInUser.getReviews())) {
            loggedInUser.setReviews(new ArrayList<>());
        }
        loggedInUser.getReviews().add(review);
        userRepository.save(loggedInUser);

        return ReviewMapper.toMap(savedReview);
    }

    public ReviewDto fetchReview(String id) {
        return reviewRepository.findById(id)
                .map(ReviewMapper::toMap)
                .orElseThrow(() -> new ReviewDoesNotExistException("id", id));
    }

    public void updateReview(String id, ReviewRequest reviewRequest, User user) {
        Review review = reviewRepository.findById(id)
                .orElseThrow(() -> new ReviewDoesNotExistException("id", id));
        if (!review.getUser().equals(user)) {
            throw new AccessDeniedException(String.format("%s doesn't own this review!", user.getUsername()));
        }

        review.setSubject(reviewRequest.getSubject());
        review.setContent(reviewRequest.getContent());
        review.setRatings(reviewRequest.getRatings());
        review.setDateTime(LocalDateTime.now());
        reviewRepository.save(review);
    }

    public void deleteReview(String id, User user) {
        Review reviewToDelete = reviewRepository.findById(id)
                .orElseThrow(() -> new ReviewDoesNotExistException("id", id));
        if (!reviewToDelete.getUser().equals(user)) {
            throw new AccessDeniedException(String.format("%s doesn't own this review!", user.getUsername()));
        }
        Place placeReviewed = placeRepository.findById(reviewToDelete.getPlace().getId())
                .orElseThrow(() -> new PlaceDoesNotExistException("id", reviewToDelete.getPlace().getId()));
        placeReviewed.getReviews().removeIf(review -> reviewToDelete.getId().equals(review.getId()));
        placeRepository.save(placeReviewed);
        user.getReviews().removeIf(review -> reviewToDelete.getId().equals(review.getId()));
        userRepository.save(user);
        reviewRepository.delete(reviewToDelete);
    }

}
