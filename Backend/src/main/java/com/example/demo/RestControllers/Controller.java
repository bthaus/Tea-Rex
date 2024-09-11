package com.example.demo.RestControllers;



import com.example.demo.Entities.Comment;
import com.example.demo.Entities.GameMap;
import com.example.demo.Entities.Rating;
import com.example.demo.Repositories.UserRepository;
import com.example.demo.Entities.UserAccount;
import com.example.demo.Services.DBService;
import com.example.demo.Services.JWTService;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;

import org.h2.engine.User;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Set;


@AllArgsConstructor
@RestController
public class Controller {

    ObjectMapper objectMapper;
    UserRepository userRepository;
    DBService dbService;
    JWTService jwtService;


    @GetMapping("/hello")
    String hello() {
        System.out.println("connected!");
        return "hi";
    }

    @PostMapping("/get_user_by_id")
    String get_user_by_id(@RequestBody String id_as_string) {
        System.out.println(id_as_string);
        int id=Integer.parseInt(id_as_string);
        UserAccount user=userRepository.findById(id);
        if (user==null){
            return "user not found";
        }
        System.out.println("connected!");
        return user.getName();
    }


    @PostMapping("/register_acc")
    ResponseEntity<String> post_user(@RequestBody String user) throws JsonProcessingException {
        System.out.println(user);
        UserAccount u=objectMapper.readValue(user, UserAccount.class);
        ResponseCookie cookie=dbService.addUser(u);
        HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.SET_COOKIE,cookie.toString());
        return ResponseEntity.status(HttpStatus.OK).headers(headers).body(String.valueOf(u.getUser_id()));

    }


    @PostMapping("validated/add_comment")
    String add_comment(@RequestBody String comment,@CookieValue(name = "token", defaultValue = "no.to.ken")String token) throws JsonProcessingException {
        System.out.println(comment);
        UserAccount user=dbService.getUserFromToken(token);
        Comment c=objectMapper.readValue(comment, Comment.class);
        c.setUser_name(user.getName());
        String resonse=dbService.addComment(c);
        System.out.println(resonse);
        return resonse;
    }
    @Transactional
    @GetMapping("get_comments_from_map/{map_name}")
    Set<Comment> get_comments_from_map(@PathVariable String map_name)
    {
        GameMap map=dbService.getMap(map_name);

        Set<Comment> comments= map.getComments();
        System.out.println(comments.size() +" comments from map: "+map.getName()+" requested");

        return comments;


    }
    @GetMapping("get_maps_from_user/{user_name}")
    Set<GameMap> get_maps_from_user(@PathVariable String user_name){
        Set<GameMap> maps=dbService.get_maps_from_user(user_name);
        System.out.println("maps from requested from"+user_name);
        return maps;


    }
    @PostMapping("validated/add_rating_to_map")
    String add_rating_to_map(@RequestBody String rating) throws JsonProcessingException {

        Rating r=objectMapper.readValue(rating, Rating.class);
        System.out.println(r.getRating());
        return dbService.add_rating(r);
    }
    @GetMapping("get_rating_from_map/{map_name}")
    int get_rating_from_map(@PathVariable String map_name){
        GameMap map=dbService.getMap(map_name);
        int sum=0;
       int counter=0;
        for (Rating r:map.getRatings()) {
            sum+=r.getRating();
            counter++;
        }
        if (counter==0){
            return 0;
        }
        return sum/counter;
    }
    @PostMapping("validated/add_map")
    String add_map(@RequestBody String map,@CookieValue(name = "token", defaultValue = "no.to.ken")String token) throws JsonProcessingException {
        UserAccount user=dbService.getUserFromToken(token);
        System.out.println(map);
        GameMap gameMap;
        gameMap=objectMapper.readValue(map, GameMap.class);
        gameMap.setUser_name(user.getName());
        var response= dbService.add_map(gameMap);
        System.out.println(response);
        return response;
    }
    @GetMapping("/get_map/{map_name}")
    GameMap get_map(@PathVariable String map_name) {
        GameMap map=dbService.getMap(map_name);
        System.out.println(map.getName()+" requested");
        return map;
    }
}
