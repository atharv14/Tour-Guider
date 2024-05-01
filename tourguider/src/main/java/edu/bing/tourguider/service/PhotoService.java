package edu.bing.tourguider.service;

import edu.bing.tourguider.exceptions.PlaceDoesNotExistException;
import edu.bing.tourguider.exceptions.ReviewDoesNotExistException;
import edu.bing.tourguider.models.Photo;
import edu.bing.tourguider.models.Place;
import edu.bing.tourguider.models.Review;
import edu.bing.tourguider.models.User;
import edu.bing.tourguider.repository.PlaceRepository;
import edu.bing.tourguider.repository.ReviewRepository;
import edu.bing.tourguider.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PhotoService {

    @Value("${photos.file.storage.path}")
    private String photosFileStoragePath;

    @Value("#{${photos.file.extensions}}")
    private Set<String> listOfAllowedExtensions;

    private final ReviewRepository reviewRepository;
    private final PlaceRepository placeRepository;
    private final UserRepository userRepository;

    public byte[] loadPhoto(String photoPath) throws IOException {
        String photoAbsolutePath = Paths.get(photosFileStoragePath, photoPath).toString();
        BufferedImage bImage = ImageIO.read(new File(photoAbsolutePath));
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        String fileExtension = getFileExtension(photoPath);
        if (listOfAllowedExtensions.contains(fileExtension)) {
            ImageIO.write(bImage, fileExtension, bos);
        }
        return bos.toByteArray();
    }

    public void saveReviewPhotos(User user, String reviewId, MultipartFile[] files) throws IOException {
        Review review = reviewRepository.findById(reviewId).orElseThrow(() -> new ReviewDoesNotExistException("id", reviewId));
        if (!review.getUser().equals(user)) {
            throw new AccessDeniedException(String.format("%s doesn't own this review!", user.getUsername()));
        }
        List<Photo> reviewPhotos = savePhotos(Paths.get(photosFileStoragePath, "reviews", reviewId), files);
        review.setPhotos(reviewPhotos);
        reviewRepository.save(review);
    }

    public void savePlacePhotos(String placeId, MultipartFile[] files) throws IOException {
        Place place = placeRepository.findById(placeId).orElseThrow(() -> new PlaceDoesNotExistException("id", placeId));
        List<Photo> placePhotos = savePhotos(Paths.get(photosFileStoragePath, "places", placeId), files);
        place.setPhotos(placePhotos);
        placeRepository.save(place);
    }

    public void saveUserPhoto(User user, MultipartFile file) throws IOException {
        Path directory = Files.createDirectories(Paths.get(photosFileStoragePath, "user", user.getId()));
        Photo userPhoto = savePhoto(directory, file);
        user.setPhoto(userPhoto);
        userRepository.save(user);
    }

    private List<Photo> savePhotos(Path directoryToCreate, MultipartFile... files) throws IOException {
        Path directory = Files.createDirectories(directoryToCreate);
        return Arrays.stream(files)
                .map(multipartFile -> savePhoto(directory, multipartFile))
                .collect(Collectors.toList());
    }

    public String getFileExtension(String fileName) {
        int index = fileName.lastIndexOf('.');
        return index > 0 ? fileName.substring(index + 1) : "";
    }

    private Photo savePhoto(Path directory, MultipartFile multipartFile) {
        String filePath = Paths.get(directory.toString(), multipartFile.getOriginalFilename()).toString();
        try {
            multipartFile.transferTo(new File(filePath));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        String relativePath = filePath.replaceFirst("^" + photosFileStoragePath, "");
        return new Photo(relativePath);
    }

}
