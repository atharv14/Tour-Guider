package edu.bing.tourguider.models;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import edu.bing.tourguider.pojo.user.UserRole;
import lombok.*;
import lombok.experimental.SuperBuilder;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.TypeAlias;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.DBRef;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;
import java.util.List;

@NoArgsConstructor
@Getter
@Setter
@ToString
@EqualsAndHashCode
@AllArgsConstructor
@Document(collection = "users")
@TypeAlias("user")
@SuperBuilder
public class User implements UserDetails {
    @Id
    protected String id;
    protected String firstName;
    protected String lastName;
    @Indexed(unique = true)
    protected String username;
    @Indexed(unique = true)
    protected String email;
    protected String password;
    protected String bio;
    protected UserRole userRole;
    @EqualsAndHashCode.Exclude
    @ToString.Exclude
    protected Photo photo;
    @DBRef
    @EqualsAndHashCode.Exclude
    @ToString.Exclude
    @JsonManagedReference
    protected List<Place> savedPlaces;
    @DBRef
    @EqualsAndHashCode.Exclude
    @ToString.Exclude
    @JsonManagedReference
    protected List<Review> reviews;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return Collections.singletonList(new SimpleGrantedAuthority(UserRole.USER.name()));
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }
}
