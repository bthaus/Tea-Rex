package com.example.demo.RestControllers;


import com.example.demo.DTOs.CommentDTO;
import com.example.demo.DTOs.MapDTO;
import com.example.demo.Entities.Comment;
import com.example.demo.Entities.GameMap;
import com.example.demo.Repositories.UserRepository;
import com.example.demo.Entities.UserAccount;
import com.example.demo.Services.DBService;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;

import org.springframework.web.bind.annotation.*;

import java.util.LinkedList;
import java.util.Set;


@AllArgsConstructor
@RestController
public class Controller {

    ObjectMapper objectMapper;
    UserRepository userRepository;
    DBService dbService;

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


    @PostMapping("/post_user_dictionary")
    String post_user(@RequestBody String user) {
        System.out.println(user);
        UserAccount u;
        try {
           u=objectMapper.readValue(user, UserAccount.class);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
        userRepository.save(u);
        return "received";
    }


    @PostMapping("add_comment")
    String add_comment(@RequestBody String comment) throws JsonProcessingException {
        System.out.println(comment);
        CommentDTO commentDTO;
        commentDTO=objectMapper.readValue(comment, CommentDTO.class);
        String resonse=dbService.addComment(commentDTO);
        System.out.println(resonse);
        return resonse;
    }
    @Transactional
    @GetMapping("get_comments_from_map/{map_name}")
    CommentDTO[] get_comments_from_map(@PathVariable String map_name)
    {
        GameMap map=dbService.get_map(map_name);

        Set<Comment> comments= map.getComments();
        System.out.println(comments.size() +" comments from map: "+map.getName()+" requested");
        LinkedList<CommentDTO> list=new LinkedList<>();
        for (Comment c:comments){
            list.add(objectMapper.convertValue(c, CommentDTO.class));
    }
        return list.toArray(new CommentDTO[list.size()]);


    }

    @PostMapping("/add_map")
    String add_map(@RequestBody String map) throws JsonProcessingException {
        System.out.println(map);
        MapDTO mapDTO;
        mapDTO=objectMapper.readValue(map, MapDTO.class);
        var response= dbService.add_map(mapDTO);
        System.out.println(response);
        return response;
    }
    @GetMapping("/get_map/{map_name}")
    MapDTO get_map(@PathVariable String map_name) {
        GameMap map=dbService.get_map(map_name);
        MapDTO dto=map.getDto();
        System.out.println(dto.getName()+" requested");
        return dto;
    }
}
