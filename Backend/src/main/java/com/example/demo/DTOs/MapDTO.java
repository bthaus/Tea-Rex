package com.example.demo.DTOs;


import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor  // No-args constructor
public class MapDTO {
    String name;
    String map_data;
    String user_id;


    @JsonCreator
    public MapDTO(
            @JsonProperty("name") String name,
            @JsonProperty("map_data") String map_data,
            @JsonProperty("user_id") String user_id){
        this.user_id = user_id;
        this.name = name;
        this.map_data = map_data;
    }
}
