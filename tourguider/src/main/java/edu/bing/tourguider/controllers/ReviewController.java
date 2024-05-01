package edu.bing.tourguider.controllers;

import edu.bing.tourguider.dto.ReviewDto;
import edu.bing.tourguider.pojo.reviews.ReviewRequest;
import edu.bing.tourguider.service.ReviewService;
import edu.bing.tourguider.util.AuthUtils;
import io.swagger.annotations.Api;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.MvcUriComponentsBuilder;

import java.net.URI;
import java.util.List;

import static org.springframework.hateoas.server.mvc.MvcLink.on;

@RestController
@RequestMapping("/api/v1/reviews")
@Api(value = "places", description = "Endpoint for managing reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    @GetMapping("/{id}")
    public ResponseEntity<ReviewDto> fetchReview(@PathVariable String id) {
        ReviewDto reviewDto = reviewService.fetchReview(id);
        return reviewDto != null ? ResponseEntity.ok(reviewDto) : ResponseEntity.notFound().build();
    }

    @GetMapping("/place/{placeId}")
    public ResponseEntity<List<ReviewDto>> fetchReviewsForPlace(@PathVariable String placeId) {
        List<ReviewDto> reviews = reviewService.fetchReviewsByPlace(placeId);
        return ResponseEntity.ok(reviews);
    }

    @PostMapping("/place/{placeId}")
    public ResponseEntity<ReviewDto> createReview(@RequestBody ReviewRequest reviewRequest, @PathVariable String placeId) {
        ReviewDto savedReview = reviewService.createReview(reviewRequest, placeId);
        URI savedPlaceUri = MvcUriComponentsBuilder.fromMethodCall(
                        on(ReviewController.class)
                                .fetchReview(savedReview.getId())
                )
                .build()
                .toUri();
        return ResponseEntity.created(savedPlaceUri).body(savedReview);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Object> updateReview(@PathVariable String id, @RequestBody ReviewRequest reviewRequest) {
        reviewService.updateReview(id, reviewRequest, AuthUtils.getLoggedInUser());
        return ResponseEntity.accepted().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Object> deleteReview(@PathVariable String id) {
        reviewService.deleteReview(id, AuthUtils.getLoggedInUser());
        return ResponseEntity.noContent().build();
    }
}
