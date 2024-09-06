package com.example.demo.DTOs;


import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor  // No-args constructor
public class CommentDTO {

    String comment;
    String user_id;
    String map_id;

    @JsonCreator
    public CommentDTO(
            @JsonProperty("comment") String comment,
            @JsonProperty("user_id") String user_id,
            @JsonProperty("map_id") String map_id) {
        this.user_id = user_id;
        this.comment = comment;
        this.map_id = map_id;
    }

}
