package edu.bing.tourguider.repository;

import edu.bing.tourguider.models.Review;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface ReviewRepository extends MongoRepository<Review, String> {
    List<Review> findByPlace_Id(String id);
}
