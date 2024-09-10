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

    public Comment(String comment) {
        this.comment = comment;


    }

}
