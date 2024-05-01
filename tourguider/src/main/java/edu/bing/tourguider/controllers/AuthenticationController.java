package edu.bing.tourguider.controllers;


import edu.bing.tourguider.pojo.auth.*;
import edu.bing.tourguider.pojo.user.UserRole;
import edu.bing.tourguider.service.AuthenticationService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthenticationController {

    @Value("${admin.master.key}")
    private String adminMasterKey;
    private final AuthenticationService authenticationService;

    @PostMapping("/signup")
    public ResponseEntity<AuthenticationResponse> register(@RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authenticationService.register(request, UserRole.USER));
    }

    @PostMapping(value = "/signin", consumes = {"application/json"})
    public ResponseEntity<AuthenticationResponse> login(@RequestBody AuthenticationRequest request) {
        return ResponseEntity.ok(authenticationService.authenticate(request));
    }

    @PostMapping("/changePassword")
    public void changePassword(@RequestBody PasswordChangeRequest request) {
        authenticationService.updatePassword(request);
    }

    @PostMapping("/admin/signup")
    public ResponseEntity<Object> registerAdmin(@RequestBody AdminRequest request) {
        if (request.getMasterKey().equals(adminMasterKey)) {
            return ResponseEntity.ok(authenticationService.register(request, UserRole.ADMIN));
        } else {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Access denied, incorrect master key");
        }
    }
}