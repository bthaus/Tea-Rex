package com.example.demo.Entities;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonIgnore;
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

    @Column(unique = true)
    private String name;

    @Column(unique = true)
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

    @OneToMany(cascade = CascadeType.PERSIST)
    @JsonIgnore  // Avoid infinite recursion
    private Set<GameMap> gameMaps;

    @OneToMany(cascade = CascadeType.PERSIST)
    @JsonIgnore  // Avoid infinite recursion
    private Set<Comment> comments;

    @OneToMany(cascade = CascadeType.PERSIST)
    @JsonIgnore  // Avoid infinite recursion
    private Set<Rating> ratings;

}
