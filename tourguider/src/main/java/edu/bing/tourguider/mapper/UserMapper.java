package edu.bing.tourguider.mapper;

import edu.bing.tourguider.models.User;
import edu.bing.tourguider.pojo.user.UserDto;
import edu.bing.tourguider.pojo.user.UserJsonDto;

public class UserMapper {
    public static UserDto toDto(User user) {
        return UserDto.builder()
                .id(user.getId())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .username(user.getUsername())
                .email(user.getEmail())
                .bio(user.getBio())
                .savedPlaces(PlaceMapper.mapToList(user.getSavedPlaces()))
                .reviews(ReviewMapper.mapToList(user.getReviews()))
                .userRole(user.getUserRole())
                .photo(user.getPhoto())
                .build();
    }

    public static UserJsonDto toJsonDto(User user) {
        return UserJsonDto.builder()
                .id(user.getId())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .username(user.getUsername())
                .email(user.getEmail())
                .bio(user.getBio())
                .userRole(user.getUserRole())
                .build();
    }
}
