package com.example.demo.Entities;


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
    @GeneratedValue
    private Long comment_id;

    private String comment;
    @ManyToOne
    @JoinColumn(name = "user_id")  // Foreign key column in the order table
    private UserAccount user;

    @ManyToOne
    @JoinColumn(name = "map_id")  // Foreign key column in the order table
    private GameMap gameMap;


    public Comment(String comment, UserAccount user, GameMap current) {
        this.comment = comment;
        this.user = user;
        this.gameMap = current;
    }

}
