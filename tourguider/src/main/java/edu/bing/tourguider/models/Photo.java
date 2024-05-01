package edu.bing.tourguider.models;

import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.ToString;
import org.springframework.data.annotation.Id;

@Getter
@ToString
@EqualsAndHashCode
@RequiredArgsConstructor
public class Photo {
    @Id
    private final String path;

}
