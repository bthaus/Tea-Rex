package com.example.demo.Services;


import com.example.demo.DTOs.MapDTO;

import com.example.demo.DTOs.UserDTO;
import com.example.demo.Entities.Comment;
import com.example.demo.Entities.GameMap;
import com.example.demo.Entities.UserAccount;
import com.example.demo.Repositories.CommentRepository;
import com.example.demo.Repositories.MapRepository;
import com.example.demo.Repositories.RatingRepository;
import com.example.demo.Repositories.UserRepository;
import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class DBService {

    private CommentRepository commentRepository;
    private MapRepository mapRepository;
    private RatingRepository ratingRepository;
    private UserRepository userRepository;

    public String add_map(GameMap gameMap){
        UserAccount user=userRepository.findByName(gameMap.getUser_name());
        if (user==null){
            return "User not found";
        }
        GameMap current=mapRepository.findByName(gameMap.getName());
        if (current!=null){
            return "Map already exists";
        }

        mapRepository.save(gameMap);
        user.getGameMaps().add(gameMap);
        userRepository.save(user);
        return String.valueOf(gameMap.getMap_id());
    }
    @Transactional
    public String addComment(Comment comment){
        UserAccount user=userRepository.findByName(comment.getUser_name());
        if (user==null){
            return "User not found";
        }
        GameMap current=mapRepository.findByName(comment.getMap_name());
        if (current==null){
            return "Map doesnt exist";
        }

        current.getComments().add(comment);
        user.getComments().add(comment);

        commentRepository.save(comment);
        mapRepository.save(current);
        userRepository.save(user);

        return "Success";
    }


    public String addUser(UserDTO userDTO){

        return "Success";
    }

    public GameMap get_map(String map_name){
        GameMap map = mapRepository.findByName(map_name);
        if (map==null){
            throw new IllegalArgumentException("Map not found");
        }
        return map;
    }



}
