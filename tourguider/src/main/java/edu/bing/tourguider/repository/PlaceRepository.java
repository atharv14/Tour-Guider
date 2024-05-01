package edu.bing.tourguider.repository;

import edu.bing.tourguider.models.Place;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;

import java.util.List;

public interface PlaceRepository extends MongoRepository<Place, String> {
    @Query("{'$text': {'$search': ?0}}")
    List<Place> findByTextSearch(String searchText);
}
