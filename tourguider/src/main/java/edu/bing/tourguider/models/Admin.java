package edu.bing.tourguider.models;

import edu.bing.tourguider.pojo.user.UserRole;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;
import org.springframework.data.annotation.TypeAlias;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.Arrays;
import java.util.Collection;

@Data
@EqualsAndHashCode(callSuper = true)
@Document(collection = "users")
@TypeAlias("admin")
@SuperBuilder
@NoArgsConstructor
public class Admin extends User {

    public Admin(User user) {
        this.firstName = user.getFirstName();
        this.lastName = user.getLastName();
        this.email = user.getEmail();
        this.username = user.getUsername();
        this.password = user.getPassword();
        this.bio = user.getBio();
        this.userRole = UserRole.ADMIN;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return Arrays.asList(
                new SimpleGrantedAuthority(UserRole.USER.name()),
                new SimpleGrantedAuthority(UserRole.ADMIN.name())
        );
    }
}
