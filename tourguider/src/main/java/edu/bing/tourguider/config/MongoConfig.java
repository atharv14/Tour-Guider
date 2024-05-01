package edu.bing.tourguider.config;

import edu.bing.tourguider.models.Place;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.index.TextIndexDefinition;

import javax.annotation.PostConstruct;

@Configuration
@RequiredArgsConstructor
public class MongoConfig {

    private final MongoTemplate mongoTemplate;

    @PostConstruct
    public void setup() {
        mongoTemplate.indexOps(Place.class)
                .ensureIndex(
                        new TextIndexDefinition.TextIndexDefinitionBuilder()
                                .named("Place_Text_Index")
                                .onField("name", 3F)
                                .onField("description", 1F)
                                .onField("address.city", 2F)
                                .onField("address.street", 1F)
                                .onField("address.zipCode", 4F)
                                .onField("category", 1F)
//                                Restaurant-related
                                .onField("cuisines")
                                .onField("type")
//                                Attraction-related
                                .onField("theme")
//                                Shopping-related
                                .onField("associatedBrands")
                                .build()
                );

    }
}
