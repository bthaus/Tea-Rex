package com.example.demo.DTOs;


import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor  // No-args constructor
public class MapDTO {
    String name;
    String reduced_entities;
    String reduced_shapes;
    String reduced_waves;
    String user_id;


    @JsonCreator
    public MapDTO(
            @JsonProperty("name") String name,
            @JsonProperty("reduced_entities") String reduced_entities,
            @JsonProperty("reduced_shapes") String reduced_shapes,
            @JsonProperty("reduced_waves") String reduced_waves,
            @JsonProperty("user_id") String user_id){
        this.user_id = user_id;
        this.name = name;
        this.reduced_entities = reduced_entities;
        this.reduced_shapes = reduced_shapes;
        this.reduced_waves = reduced_waves;
    }
}
