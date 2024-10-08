package com.example.demo.Services;


import com.example.demo.Entities.*;
import com.example.demo.Repositories.CommentRepository;
import com.example.demo.Repositories.MapRepository;
import com.example.demo.Repositories.RatingRepository;
import com.example.demo.Repositories.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseCookie;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.Set;

@Service
@AllArgsConstructor
public class DBService {
    JWTService jwtService;
    private CommentRepository commentRepository;
    private MapRepository mapRepository;
    private RatingRepository ratingRepository;
    private UserRepository userRepository;
    private InputChecker inputChecker;

    public String add_map(GameMap gameMap){
        UserAccount user=userRepository.findByName(gameMap.getUsername());
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
        return String.valueOf(gameMap.getMapID());
    }
    public String add_rating(Rating rating){
        UserAccount user=getUserAccount(rating.getUser_name());
        GameMap map=getMapByID(rating.getMap_id());
        for(Rating r:user.getRatings()){
            if(r.getMap_id()==rating.getMap_id()){
               rating=r;
               r.setRating(rating.getRating());
               break;
            }
        }
        ratingRepository.save(rating);
        user.getRatings().add(rating);
        userRepository.save(user);
        map.add_rating(rating);
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
        GameMap current = getMapByID(comment.getMap_id());

        current.add_comment(comment);
        user.getComments().add(comment);

        commentRepository.save(comment);
        mapRepository.save(current);
        userRepository.save(user);

        return "Success";
    }


    public ResponseCookie addUser(UserAccount userDTO){
        if (userRepository.findByName(userDTO.getName())!=null){
            throw new IllegalArgumentException("Username already exists");
        }
        if (inputChecker.containsInvalidHttpChars(userDTO.getName())){
            throw new IllegalArgumentException("Name contains invalid characters");
        }
        if(userRepository.findByEmail(userDTO.getEmail())!=null){
            throw new IllegalArgumentException("Email already exists");
        }

        userRepository.save(userDTO);
      // String token=jwtService.generateToken(userDTO.getUser_id(), new JWTFields());
        ResponseCookie cookie=jwtService.getTokenCookie(String.valueOf(userDTO.getUser_id()));
        userDTO.setToken(cookie.getValue());
        userRepository.save(userDTO);
        return cookie;
    }

    public GameMap getMap(String map_name){
        GameMap map = mapRepository.findByName(map_name);
        if (map==null){
            throw new IllegalArgumentException("Map not found");
        }
        return map;
    }


    public UserAccount getUserFromToken(String token) {
        Long id= jwtService.getIDfromToken(token);
       if(!jwtService.validateToken(token)){
           throw new IllegalArgumentException("Invalid token");
       }
        Optional<UserAccount> account=userRepository.findById(id);
        if (account.isEmpty()){
            throw new IllegalArgumentException("User not found");
        }
        return account.get();
    }
    public String[] getMapNames(){
      List<GameMap>maps= mapRepository.findAll();
      String[]arr=new String[maps.size()];
      for (int i=0;i<maps.size();i++){
          arr[i]=maps.get(i).getName();
      }
      return arr;
    }

    public List<GameMap> getAllMaps() {
        return  mapRepository.findAll();
    }

    public GameMap getMapByID(int mapId) {
        Optional<GameMap> map = mapRepository.findById(mapId);
        if (map.isEmpty()){
            throw new IllegalArgumentException("Map not found");
        }
        return map.get();
    }
}
