package edu.bing.tourguider.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import edu.bing.tourguider.mapper.UserMapper;
import edu.bing.tourguider.models.Admin;
import edu.bing.tourguider.models.User;
import edu.bing.tourguider.pojo.auth.AuthenticationRequest;
import edu.bing.tourguider.pojo.auth.AuthenticationResponse;
import edu.bing.tourguider.pojo.auth.PasswordChangeRequest;
import edu.bing.tourguider.pojo.auth.RegisterRequest;
import edu.bing.tourguider.pojo.user.UserRole;
import edu.bing.tourguider.util.AuthUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class AuthenticationService {

    private final UserService userService;
    private final PasswordEncoder passwordEncoder;
    private final JWTService jwtService;
    private final AuthenticationManager authenticationManager;

    public AuthenticationResponse register(RegisterRequest request, UserRole userRole) {
        User user = User.builder()
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .email(request.getEmail())
                .bio(request.getBio())
                .username(request.getUsername())
                .password(passwordEncoder.encode(request.getPassword()))
                .userRole(userRole)
                .build();
        if (userRole == UserRole.ADMIN)
            user = new Admin(user);
        User createdUser = userService.createUser(user);
        return generateAuthResponse(createdUser);
    }


    public AuthenticationResponse authenticate(AuthenticationRequest request) {
        authenticationManager.authenticate(createUserAuthToken(request));
        User user = userService.loadUserByUsername(request.getUsername());
        return generateAuthResponse(user);

    }

    public void updatePassword(PasswordChangeRequest request) {
        String username = AuthUtils.getLoggedInUsername();
        authenticationManager.authenticate(createUserAuthToken(getAuthenticationRequest(username, request.getOldPassword())));
        userService.changePassword(username, request.getNewPassword());
    }

    private static AuthenticationRequest getAuthenticationRequest(String username, String password) {
        return new AuthenticationRequest(username, password);
    }

    private static UsernamePasswordAuthenticationToken createUserAuthToken(AuthenticationRequest request) {
        return new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword());
    }

    private AuthenticationResponse generateAuthResponse(User user) {
//        Create ObjectMapper instance
        ObjectMapper mapper = new ObjectMapper();
//        Converting POJO to Map

        Map<String, Object> userJson = mapper.convertValue(UserMapper.toJsonDto(user), new TypeReference<Map<String, Object>>() {
        });
//        Creating auth token
        String authToken = jwtService.generateToken(user, userJson);
        return AuthenticationResponse.builder()
                .authToken(authToken)
                .isAdmin(user.getUserRole() == UserRole.ADMIN)
                .build();
    }
}
