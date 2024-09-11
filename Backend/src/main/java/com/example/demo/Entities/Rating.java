package com.example.demo.Entities;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor  // No-args constructor
@Entity
public class Rating {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long rating_id;
    private int rating;
    private String user_name;
    private String map_name;

    @JsonCreator
    public Rating(
            @JsonProperty("rating") int rating,
            @JsonProperty("user_name") String user_name,
            @JsonProperty("map_name")String map_name){
        this.rating = rating;
        this.user_name = user_name;
        this.map_name = map_name;
    }


}
