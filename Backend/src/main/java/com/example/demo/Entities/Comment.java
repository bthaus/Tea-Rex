package com.example.demo.Entities;


import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

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

    @OneToOne
    @JoinColumn(name = "map_id")  // Foreign key column in the order table
    private Map map;


}
