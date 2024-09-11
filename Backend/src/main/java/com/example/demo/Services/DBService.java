package com.example.demo.Services;


import com.example.demo.Entities.Comment;
import com.example.demo.Entities.GameMap;
import com.example.demo.Entities.Rating;
import com.example.demo.Entities.UserAccount;
import com.example.demo.Repositories.CommentRepository;
import com.example.demo.Repositories.MapRepository;
import com.example.demo.Repositories.RatingRepository;
import com.example.demo.Repositories.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Set;

@Service
@AllArgsConstructor
public class DBService {

    private CommentRepository commentRepository;
    private MapRepository mapRepository;
    private RatingRepository ratingRepository;
    private UserRepository userRepository;
    private InputChecker inputChecker;

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
    public String add_rating(Rating rating){
        UserAccount user=getUserAccount(rating.getUser_name());
        GameMap map=getMap(rating.getMap_name());
        for(Rating r:user.getRatings()){
            if(r.getMap_name()==rating.getMap_name()){
               rating=r;
               r.setRating(rating.getRating());
               break;
            }
        }
        ratingRepository.save(rating);
        user.getRatings().add(rating);
        userRepository.save(user);
        map.getRatings().add(rating);
        mapRepository.save(map);


        return String.valueOf(rating.getRating_id());


    }

    public Set<GameMap> get_maps_from_user(String user_name){
        UserAccount user = getUserAccount(user_name);
        return user.getGameMaps();
    }


    private UserAccount getUserAccount(String user_name) {
        UserAccount user=userRepository.findByName(user_name);
        if (user==null){
            throw new IllegalArgumentException("User not found");
        }
        return user;
    }

    public String addComment(Comment comment){
        UserAccount user=getUserAccount(comment.getUser_name());
        GameMap current = getMap(comment.getMap_name());

        current.getComments().add(comment);
        user.getComments().add(comment);

        commentRepository.save(comment);
        mapRepository.save(current);
        userRepository.save(user);

        return "Success";
    }


    public int addUser(UserAccount userDTO){
        if (userRepository.findByName(userDTO.getName())!=null){
            throw new IllegalArgumentException("Username already exists");
        }
        if (inputChecker.containsInvalidHttpChars(userDTO.getName())){
            throw new IllegalArgumentException("Name contains invalid characters");
        }
        userRepository.save(userDTO);
        return userDTO.getUser_id();
    }

    public GameMap getMap(String map_name){
        GameMap map = mapRepository.findByName(map_name);
        if (map==null){
            throw new IllegalArgumentException("Map not found");
        }
        return map;
    }



}
