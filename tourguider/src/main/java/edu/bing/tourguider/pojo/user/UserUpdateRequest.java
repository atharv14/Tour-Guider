package edu.bing.tourguider.pojo.user;

import lombok.*;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class UserUpdateRequest {

    private String firstName;
    private String lastName;
    private String email;

}
