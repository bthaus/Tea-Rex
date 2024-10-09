package com.example.demo.Repositories;

import com.example.demo.Entities.GameMap;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Set;

public interface MapRepository extends JpaRepository<GameMap,Integer> {
    GameMap findByName(String name);

    GameMap findByMapID(int id);

    List<GameMap> findAllByUsername(String userName);

    List<GameMap> findAllByNumberOfWaves(int numberOfWaves);

    @Query(value = "SELECT m FROM GameMap m " +
            "WHERE(:mapId IS NULL OR :mapId = -1 OR m.mapID = :mapId)\n " +
            "AND (:mapName IS NULL OR :mapName = '' OR m.name LIKE %:mapName%) " +
            "AND (:username IS NULL OR :username = '' OR m.username = :username) " +
            "AND (:waveLengths IS NULL  OR m.numberOfWaves IN :waveLengths) "+
            // "AND (:clearRateUpTo IS NULL OR m. <= :clearRateUpTo) " +
            "ORDER BY " +
            "CASE WHEN :sortBy = 'map_name' THEN m.name  " +
            "  WHEN :sortBy = 'wave_lengths' THEN m.numberOfWaves " +
           // " WHEN :sortBy = 'clear_rate' THEN m.clearRate"+
            " ELSE m.mapID END "   // Default ordering by mapID if no sortBy value

    )
    List<GameMap> findMaps(
            @Param("mapId") int mapId,
           @Param("mapName") String mapName,
            @Param("username") String username,
            @Param("waveLengths") Set<Integer> waveLengths,
            @Param("sortBy") String sortBy

            //) @Param("sortBy") String sortBy
    );
}
