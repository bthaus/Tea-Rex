package com.example.demo.Repositories;

import com.example.demo.Entities.GameMap;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MapRepository extends JpaRepository<GameMap,Integer> {
    GameMap findByName(String name);

}
