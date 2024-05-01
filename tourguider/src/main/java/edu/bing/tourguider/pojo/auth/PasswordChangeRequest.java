package edu.bing.tourguider.pojo.auth;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class PasswordChangeRequest {
    private String oldPassword;
    private String newPassword;
}
