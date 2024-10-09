package com.example.demo.DTOs;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MapDTO {
    private int map_id;
    private String map_name;
    private String user_name;

    private String description;

    private int slot_amount;
    private int number_of_waves;
    private int average_rating;
    private int number_of_comments;
    private int difficulty_rating;

}
