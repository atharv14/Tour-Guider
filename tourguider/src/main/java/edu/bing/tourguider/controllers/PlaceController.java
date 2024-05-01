package edu.bing.tourguider.controllers;

import edu.bing.tourguider.dto.PlaceDto;
import edu.bing.tourguider.models.Place;
import edu.bing.tourguider.pojo.places.*;
import edu.bing.tourguider.service.PlaceService;
import io.swagger.annotations.Api;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.MvcUriComponentsBuilder;

import java.net.URI;
import java.util.Collection;
import java.util.List;

import static org.springframework.hateoas.server.mvc.MvcLink.on;

@RestController
@RequestMapping("/api/v1/places")
@Api(value = "places", description = "Endpoint for tourist place management")
@RequiredArgsConstructor
public class PlaceController {

    private final PlaceService placeService;

    @GetMapping
    public ResponseEntity<Collection<PlaceDto>> fetchAllPlaces() {
        Collection<PlaceDto> places = placeService.fetchAllPlaces();
        return ResponseEntity.ok(places);
    }

    @GetMapping("/{id}")
    public ResponseEntity<PlaceDto> fetchPlace(@PathVariable String id) {
        PlaceDto placeDto = placeService.fetchPlaceById(id);
        return placeDto != null ? ResponseEntity.ok(placeDto) : ResponseEntity.notFound().build();
    }

    @PreAuthorize("hasAuthority('ADMIN')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Object> deletePlace(@PathVariable String id) {
        placeService.deletePlace(id);
        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("hasAuthority('ADMIN')")
    @PostMapping
    public ResponseEntity<Object> createPlace(@RequestBody PlaceRequest placeRequest) {
        Place savedPlace = placeService.createPlace(placeRequest, PlaceCategory.OTHER);
        URI savedPlaceUri = MvcUriComponentsBuilder.fromMethodCall(
                        on(PlaceController.class)
                                .fetchPlace(savedPlace.getId())
                )
                .build()
                .toUri();
        return ResponseEntity.created(savedPlaceUri).body(savedPlace);
    }

    @PreAuthorize("hasAuthority('ADMIN')")
    @PutMapping("/{id}")
    public ResponseEntity<Object> updatePlace(@PathVariable String id, @RequestBody PlaceRequest PlaceRequest) {
        Place savedPlace = placeService.updatePlace(id, PlaceRequest);
        return ResponseEntity.accepted().body(savedPlace);
    }

    @PreAuthorize("hasAuthority('ADMIN')")
    @PostMapping("/restaurants")
    public ResponseEntity<Object> createRestaurantPlace(@RequestBody RestaurantPlaceRequest restaurantRequest) {
        Place savedPlace = placeService.createPlace(restaurantRequest, PlaceCategory.RESTAURANT);
        URI savedPlaceUri = MvcUriComponentsBuilder.fromMethodCall(
                        on(PlaceController.class)
                                .fetchPlace(savedPlace.getId())
                )
                .build()
                .toUri();
        return ResponseEntity.created(savedPlaceUri).body(savedPlace);
    }

    @PreAuthorize("hasAuthority('ADMIN')")
    @PutMapping("/restaurants/{id}")
    public ResponseEntity<Object> updateRestaurantPlace(@PathVariable String id, @RequestBody RestaurantPlaceRequest restaurantRequest) {
        Place savedPlace = placeService.updatePlace(id, restaurantRequest);
        return ResponseEntity.accepted().body(savedPlace);
    }

    @PreAuthorize("hasAuthority('ADMIN')")
    @PostMapping("/shopping")
    public ResponseEntity<Object> createShoppingPlace(@RequestBody ShoppingPlaceRequest shoppingPlaceRequest) {
        Place savedPlace = placeService.createPlace(shoppingPlaceRequest, PlaceCategory.SHOPPING);
        URI savedPlaceUri = MvcUriComponentsBuilder.fromMethodCall(
                        on(PlaceController.class)
                                .fetchPlace(savedPlace.getId())
                )
                .build()
                .toUri();
        return ResponseEntity.created(savedPlaceUri).body(savedPlace);
    }

    @PreAuthorize("hasAuthority('ADMIN')")
    @PutMapping("/shopping/{id}")
    public ResponseEntity<Object> updateShoppingPlace(@PathVariable String id, @RequestBody ShoppingPlaceRequest shoppingPlaceRequest) {
        Place savedPlace = placeService.updatePlace(id, shoppingPlaceRequest);
        return ResponseEntity.accepted().body(savedPlace);
    }

    @PreAuthorize("hasAuthority('ADMIN')")
    @PostMapping("/attractions")
    public ResponseEntity<Object> createAttractionPlace(@RequestBody AttractionPlaceRequest attractionPlaceRequest) {
        Place savedPlace = placeService.createPlace(attractionPlaceRequest, PlaceCategory.ATTRACTION);
        URI savedPlaceUri = MvcUriComponentsBuilder.fromMethodCall(
                        on(PlaceController.class)
                                .fetchPlace(savedPlace.getId())
                )
                .build()
                .toUri();
        return ResponseEntity.created(savedPlaceUri).body(savedPlace);
    }

    @PreAuthorize("hasAuthority('ADMIN')")
    @PutMapping("/attractions/{id}")
    public ResponseEntity<Object> updateAttractionPlace(@PathVariable String id, @RequestBody AttractionPlaceRequest attractionPlaceRequest) {
        Place savedPlace = placeService.updatePlace(id, attractionPlaceRequest);
        return ResponseEntity.accepted().body(savedPlace);
    }

    @GetMapping("/search")
    public ResponseEntity<List<PlaceDto>> searchPlaces(@RequestParam String searchText) {
        List<PlaceDto> searchedPlaces = placeService.searchPlaces(searchText);
        return ResponseEntity.ok(searchedPlaces);
    }
}
