package com.example.demo.Services;


import com.example.demo.DTOs.CommentDTO;
import com.example.demo.DTOs.MapDTO;
import com.example.demo.DTOs.RatingDTO;
import com.example.demo.DTOs.UserDTO;
import com.example.demo.Entities.GameMap;
import com.example.demo.Entities.UserAccount;
import com.example.demo.Repositories.CommentRepository;
import com.example.demo.Repositories.MapRepository;
import com.example.demo.Repositories.RatingRepository;
import com.example.demo.Repositories.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@AllArgsConstructor
public class DBService {

    private CommentRepository commentRepository;
    private MapRepository mapRepository;
    private RatingRepository ratingRepository;
    private UserRepository userRepository;

    public String add_map(MapDTO mapDTO){
        UserAccount user=userRepository.findById(Integer.parseInt(mapDTO.getUser_id()));
        if (user==null){
            return "User not found";
        }
        GameMap current=mapRepository.findByName(mapDTO.getName());
        if (current!=null){
            return "Map already exists";
        }
        current=new GameMap(user,mapDTO.getName(),mapDTO.getReduced_entities(),mapDTO.getReduced_waves(),mapDTO.getReduced_shapes());
        mapRepository.save(current);
        return String.valueOf(current.getMap_id());
    }
    public String addComment(CommentDTO commentDTO){

        return "Success";
    }

    public String addRating(RatingDTO ratingDTO){

        return "Success";
    }
    public String addUser(UserDTO userDTO){

        return "Success";
    }

    public MapDTO get_map(String id){
        Optional<GameMap> map = mapRepository.findById(Integer.parseInt(id));
        if (map.isEmpty()){
            throw new IllegalArgumentException("Map not found");
        }
        return map.get().getDto();
    }



}
