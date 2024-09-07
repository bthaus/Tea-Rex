package com.example.demo.Entities;

import com.example.demo.DTOs.MapDTO;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Set;

@Data
@NoArgsConstructor  // No-args constructor
@Entity
public class GameMap {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int map_id;

    private String name;
    private String description;
    @Lob
    @Column(columnDefinition = "TEXT")  // Explicitly define the column type for databases like Oracle
    private String reduced_entities;
    @Lob
    @Column(columnDefinition = "TEXT")  // Explicitly define the column type for databases like Oracle

    private String reduced_shapes;
    @Lob
    @Column(columnDefinition = "TEXT")  // Explicitly define the column type for databases like Oracle

    private String reduced_waves;

    public GameMap(UserAccount user, String name, String reduced_entities,String reduced_waves ,String reduced_shapes){
        this.name=name;
        this.reduced_entities=reduced_entities;
        this.reduced_waves=reduced_waves;
        this.reduced_shapes=reduced_shapes;
        this.user=user;
    }

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")  // Foreign key column in the order table
    private UserAccount user;

    @OneToMany(fetch = FetchType.LAZY)
    @JoinColumn(name = "rating_id")  // Foreign key column in the order table
    private Set<Rating> ratings;

    @OneToMany
    @JoinColumn(name = "comment_id")
    private Set<Comment> comments;

    public MapDTO getDto(){
        MapDTO mapDTO = new MapDTO();
        mapDTO.setName(name);
        mapDTO.setReduced_shapes(reduced_shapes);
        mapDTO.setReduced_entities(reduced_entities);
        mapDTO.setReduced_waves(reduced_waves);
        mapDTO.setUser_id(String.valueOf(user.getUser_id()));
        return mapDTO;
    }


}
