package edu.bing.tourguider.controllers;

import edu.bing.tourguider.mapper.UserMapper;
import edu.bing.tourguider.models.User;
import edu.bing.tourguider.pojo.user.UserDto;
import edu.bing.tourguider.service.UserService;
import edu.bing.tourguider.util.AuthUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PreAuthorize("hasAuthority('ADMIN')")
    @GetMapping
    public ResponseEntity<List<UserDto>> fetchAllUsers() {
        List<UserDto> users = userService.fetchAllUsers();
        return ResponseEntity.ok(users);
    }

    @GetMapping("/loggedInUser")
    public ResponseEntity<UserDto> fetchLoggedInUser() {
        User loggedInUser = AuthUtils.getLoggedInUser();
        return ResponseEntity.ok(UserMapper.toDto(loggedInUser));
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserDto> fetchUser(@PathVariable String id) {
        UserDto user = userService.fetchUser(id);
        return user != null ? ResponseEntity.ok(user) : ResponseEntity.notFound().build();
    }

    @PutMapping("/place/{placeId}")
    public ResponseEntity<Object> savePlace(@PathVariable String placeId) {
        userService.savePlace(AuthUtils.getLoggedInUser(), placeId);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/place/{placeId}")
    public ResponseEntity<Object> deletePlace(@PathVariable String placeId) {
        userService.removePlace(AuthUtils.getLoggedInUser(), placeId);
        return ResponseEntity.noContent().build();
    }
}
