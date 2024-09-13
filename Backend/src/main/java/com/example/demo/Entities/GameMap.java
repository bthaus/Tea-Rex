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
public class GameMap {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int map_id;
    @Column(unique = true)
    private String name;
    private String description;

    private String user_name;
    private int slot_amount;
    private int number_of_waves;
    private int average_rating;
    private int number_of_comments;
    private int difficulty_rating;


    @JsonCreator
    public GameMap(
            @JsonProperty("name") String name,
            @JsonProperty("reduced_entities") String reduced_entities,
            @JsonProperty("reduced_shapes") String reduced_shapes,
            @JsonProperty("reduced_waves") String reduced_waves,
            @JsonProperty("user_name") String user_name,
            @JsonProperty("description") String description){
        this.user_name = user_name;
        this.name = name;
        this.reduced_entities = reduced_entities;
        this.reduced_shapes = reduced_shapes;
        this.reduced_waves = reduced_waves;
        this.description = description;
    }
    public void add_comment(Comment comment){
        this.number_of_comments++;
        getComments().add(comment);
    }
    public void add_rating(Rating rating){
        ratings.add(rating);
        int sum=0;
        int counter=0;
        for (Rating r:getRatings()) {
            sum+=r.getRating();
            counter++;
        }
        if (counter==0){
           average_rating=0;
           return;

        }
        average_rating = sum/counter;
    }
    @Lob
    @Column(columnDefinition = "TEXT")  // Explicitly define the column type for databases like Oracle
    private String reduced_entities;
    @Lob
    @Column(columnDefinition = "TEXT")  // Explicitly define the column type for databases like Oracle
    private String reduced_shapes;
    @Lob
    @Column(columnDefinition = "TEXT")  // Explicitly define the column type for databases like Oracle
    private String reduced_waves;


    @OneToMany(cascade = CascadeType.PERSIST,fetch = FetchType.EAGER)
    @JsonIgnore  // Avoid infinite recursion  // Foreign key column in the order table
    private Set<Rating> ratings;

    @OneToMany(cascade = CascadeType.PERSIST)
    @JsonIgnore  // Avoid infinite recursion
    private Set<Comment> comments;




}
