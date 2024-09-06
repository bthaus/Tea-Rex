package com.example.demo.Entities;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Set;


@Data
@NoArgsConstructor  // No-args constructor
@Entity
public class UserAccount {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private int user_id;
    private String name;
    private String email;

    @JsonCreator
    public UserAccount(
            @JsonProperty("id") int id,
            @JsonProperty("name") String name,
            @JsonProperty("email") String email) {
        this.user_id = id;
        this.name = name;
        this.email = email;
    }

    @OneToMany
    @JoinColumn(name="map_id")
    private Set<Map> maps;

    @OneToMany
    @JoinColumn(name="comment_id")
    private Set<Comment> comments;

    @OneToMany
    @JoinColumn(name="rating_id")
    private Set<Rating> ratings;

}
