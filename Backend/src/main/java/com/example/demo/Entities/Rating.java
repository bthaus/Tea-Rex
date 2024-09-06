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
    @ManyToOne
    @JoinColumn(name = "user_id")  // Foreign key column in the order table
    private UserAccount user;

    @OneToOne
    @JoinColumn(name = "map_id")  // Foreign key column in the order table
    private GameMap gameMap;


}
