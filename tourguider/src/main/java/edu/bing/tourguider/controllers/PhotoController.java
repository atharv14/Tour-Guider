package edu.bing.tourguider.controllers;

import edu.bing.tourguider.models.User;
import edu.bing.tourguider.service.PhotoService;
import edu.bing.tourguider.util.AuthUtils;
import io.swagger.annotations.ApiParam;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Arrays;
import java.util.Objects;
import java.util.Set;

@Controller
@RequestMapping("/api/v1/photos")
@RequiredArgsConstructor
public class PhotoController {

    private final PhotoService photoService;
    @Value("#{${photos.file.extensions}}")
    private Set<String> listOfAllowedExtensions;

    @GetMapping("/fetch")
    public @ResponseBody ResponseEntity<Object> getFile(@RequestParam String photoPath) throws IOException {
        byte[] bytes = photoService.loadPhoto(photoPath);
        if (bytes != null && bytes.length > 0) {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
            headers.add("Content-Disposition", "attachment; filename=" + photoPath);
            return ResponseEntity.ok()
                    .headers(headers)
                    .body(bytes);
        }
        return ResponseEntity.notFound().build();
    }

    @PostMapping(path = "/upload/review/{reviewId}", consumes = "multipart/form-data")
    public ResponseEntity<String> uploadReviewPhotos(
            @PathVariable String reviewId,
            @RequestPart("files") @ApiParam(value = "files", required = true) MultipartFile[] files
    ) throws IOException {
        if (areFilesPhotos(files)) {
            User loggedInUser = AuthUtils.getLoggedInUser();
            photoService.saveReviewPhotos(loggedInUser, reviewId, files);
        } else {
            return ResponseEntity.badRequest()
                    .body("Invalid file format. Only these files are allowed: " + listOfAllowedExtensions);
        }

        return ResponseEntity.ok("Files uploaded successfully!");
    }

    @PreAuthorize("hasAuthority('ADMIN')")
    @PostMapping(path = "/upload/places/{placeId}", consumes = "multipart/form-data")
    public ResponseEntity<String> uploadPlacesPhotos(
            @PathVariable String placeId,
            @RequestPart("files") @ApiParam(value = "files", required = true) MultipartFile[] files
    ) throws IOException {
        if (areFilesPhotos(files)) {
            photoService.savePlacePhotos(placeId, files);
        } else {
            return ResponseEntity.badRequest()
                    .body("Invalid file format. Only these files are allowed: " + listOfAllowedExtensions);
        }
        return ResponseEntity.ok("Files uploaded successfully!");
    }

    @PostMapping("/upload/user")
    public ResponseEntity<String> uploadProfilePicture(
            @RequestPart("file") @ApiParam(value = "File", required = true) MultipartFile file) throws IOException {
        if (areFilesPhotos(file)) {
            User loggedInUser = AuthUtils.getLoggedInUser();
            photoService.saveUserPhoto(loggedInUser, file);
        } else {
            return ResponseEntity.badRequest()
                    .body("Invalid file format. Only these files are allowed: " + listOfAllowedExtensions);
        }

        return ResponseEntity.ok("File uploaded successfully!");
    }

    private boolean areFilesPhotos(MultipartFile... files) {
        return Arrays.stream(files)
                .map(MultipartFile::getOriginalFilename)
                .filter(Objects::nonNull)
                .map(photoService::getFileExtension)
                .allMatch(listOfAllowedExtensions::contains);
    }


}
