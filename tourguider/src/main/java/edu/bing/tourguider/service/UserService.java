package edu.bing.tourguider.service;

import edu.bing.tourguider.exceptions.PlaceDoesNotExistException;
import edu.bing.tourguider.exceptions.UserDoesNotExistException;
import edu.bing.tourguider.mapper.UserMapper;
import edu.bing.tourguider.models.Place;
import edu.bing.tourguider.models.User;
import edu.bing.tourguider.pojo.user.UserDto;
import edu.bing.tourguider.repository.PlaceRepository;
import edu.bing.tourguider.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService implements UserDetailsService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final PlaceRepository placeRepository;

    @Override
    public User loadUserByUsername(String username) {
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new UserDoesNotExistException("username", username));
    }

    public User createUser(User user) {
        return userRepository.save(user);
    }

    public void changePassword(String username, String newPassword) {
        User user = loadUserByUsername(username);
        String encodedNewPassword = passwordEncoder.encode(newPassword);
        user.setPassword(encodedNewPassword);
        userRepository.save(user);
    }

    public List<UserDto> fetchAllUsers() {
        return userRepository.findAll()
                .stream()
                .map(UserMapper::toDto)
                .collect(Collectors.toList());
    }

    public UserDto fetchUser(String id) {
        return userRepository.findById(id)
                .map(UserMapper::toDto)
                .orElseThrow(() -> new UserDoesNotExistException("id", id));
    }

    public void savePlace(User user, String placeId) {
        Place placeToSave = placeRepository.findById(placeId).orElseThrow(() -> new PlaceDoesNotExistException("id", placeId));
        if (CollectionUtils.isEmpty(user.getSavedPlaces())) {
            user.setSavedPlaces(new ArrayList<>());
        }
        user.getSavedPlaces().add(placeToSave);
        userRepository.save(user);
    }

    public void removePlace(User user, String placeId) {
        Place placeToRemove = placeRepository.findById(placeId).orElseThrow(() -> new PlaceDoesNotExistException("id", placeId));
        user.getSavedPlaces().removeIf(place -> placeToRemove.getId().equals(place.getId()));
        userRepository.save(user);
    }
}
