package edu.bing.tourguider.pojo.auth;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class RegisterRequest {
    private String username;
    private String email;
    private String bio;
    private String password;
    private String firstName;
    private String lastName;
}
