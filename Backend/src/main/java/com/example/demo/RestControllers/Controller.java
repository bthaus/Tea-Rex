package com.example.demo.RestControllers;


import com.example.demo.Repositories.UserRepository;
import com.example.demo.Entities.UserAccount;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
@AllArgsConstructor
@RestController
public class Controller {

    ObjectMapper objectMapper;
    UserRepository userRepository;
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

    @PostMapping("/post_map")
    String post_map(@RequestBody String map) {
        System.out.println(map);
        return "received";
    }
}
