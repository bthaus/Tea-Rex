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
    private long user_id;

    private String pw;
    private String token;

    @Column(unique = true)
    private String name;

    @Column(unique = true)
    private String email;

    @JsonCreator
    public UserAccount(
            @JsonProperty("user_name") String name,
            @JsonProperty("password")String password,
            @JsonProperty("email") String email) {
        this.name = name;
        this.email = email;
        this.pw = password;
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
