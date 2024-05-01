package edu.bing.tourguider.pojo.user;

import lombok.*;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class UserRequest {

    private String firstName;
    private String lastName;
    private String email;
    private String username;
    private String password;
    private UserRole userRole;

}
