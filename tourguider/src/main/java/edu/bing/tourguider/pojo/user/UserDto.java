package edu.bing.tourguider.pojo.user;

import edu.bing.tourguider.dto.PlaceDto;
import edu.bing.tourguider.dto.ReviewDto;
import edu.bing.tourguider.models.Photo;
import lombok.*;

import java.util.Collection;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class UserDto {
    private String id;
    private String username;
    private String email;
    private String bio;
    private String firstName;
    private String lastName;
    private Collection<PlaceDto> savedPlaces;
    private Collection<ReviewDto> reviews;
    private UserRole userRole;
    private Photo photo;
}
