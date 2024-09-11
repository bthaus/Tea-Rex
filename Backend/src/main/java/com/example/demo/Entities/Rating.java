package com.example.demo.Entities;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor  // No-args constructor
@Entity
public class Rating {
    @Id
    @GeneratedValue
    private Long rating_id;

    private int rating;


}
