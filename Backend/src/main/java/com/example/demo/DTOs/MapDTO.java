package com.example.demo.DTOs;

import jakarta.persistence.Column;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;
@Data
@NoArgsConstructor
public class MapDTO {
    private int map_id;
    private String name;
    private String description;
    private String user_name;
    private int slot_amount;
    private int number_of_waves;
    private int average_rating;
    private int number_of_comments;
    private int difficulty_rating;

}
