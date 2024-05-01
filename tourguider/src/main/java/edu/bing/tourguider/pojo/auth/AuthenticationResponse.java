package edu.bing.tourguider.pojo.auth;

import lombok.*;

@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class AuthenticationResponse {

    private String authToken;
    private boolean isAdmin;
}
