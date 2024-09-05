package com.example.demo;


import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Controller {
    String map;
    @GetMapping("/hello")
    String hello() {
        System.out.println("connected!");
        return map;
    }
    @PostMapping("/post_map")
    String post_map(@RequestBody String map) {
        System.out.println(map);
        this.map = map;
        return "received";
    }
}
