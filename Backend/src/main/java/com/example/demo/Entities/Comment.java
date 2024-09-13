package com.example.demo.Entities;


import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;

@Data
@NoArgsConstructor  // No-args constructor

@Entity
public class Comment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long comment_id;

    private String comment;

    private String user_name;

    private int map_id;


    @JsonCreator
    public Comment(
            @JsonProperty("comment") String comment,
            @JsonProperty("user_name") String user_name,
            @JsonProperty("map_id") int map_id) {
        this.user_name = user_name;
        this.comment = comment;
        this.map_id = map_id;
    }


}
