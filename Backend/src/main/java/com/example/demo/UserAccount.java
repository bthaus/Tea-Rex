package com.example.demo;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.Data;
import lombok.NoArgsConstructor;


@Data
@NoArgsConstructor  // No-args constructor
@Entity
public class UserAccount {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private int id;
    private String name;
    private String email;

    @JsonCreator
    public UserAccount(
            @JsonProperty("id") int id,
            @JsonProperty("name") String name,
            @JsonProperty("email") String email) {
        this.id = id;
        this.name = name;
        this.email = email;
    }
    // Constructors, Getters, Setters
}
