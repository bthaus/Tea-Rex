package com.example.demo.Entities;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Set;

@Data
@NoArgsConstructor  // No-args constructor
@Entity
public class Map {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int map_id;

    private String name;
    private String description;
    private String map_data;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")  // Foreign key column in the order table
    private UserAccount user;

    @OneToMany(fetch = FetchType.LAZY)
    @JoinColumn(name = "rating_id")  // Foreign key column in the order table
    private Set<Rating> ratings;

    @OneToMany
    @JoinColumn(name = "comment_id")
    private Set<Comment> comments;




}
