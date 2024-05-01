package edu.bing.tourguider.repository;

import edu.bing.tourguider.models.User;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends MongoRepository<User, String> {
    List<User> findBySavedPlaces_Id(String id);

    Optional<User> findByUsername(String username);
}
