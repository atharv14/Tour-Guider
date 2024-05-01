package edu.bing.tourguider.pojo.user;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

@Getter
@Builder
@AllArgsConstructor
@ToString
public class UserJsonDto {
    private String id;
    private String username;
    private String email;
    private String bio;
    private String firstName;
    private String lastName;
    private UserRole userRole;
}