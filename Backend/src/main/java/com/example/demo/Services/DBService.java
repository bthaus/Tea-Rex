package com.example.demo.Services;


import com.example.demo.DTOs.CommentDTO;
import com.example.demo.DTOs.MapDTO;
import com.example.demo.DTOs.RatingDTO;
import com.example.demo.DTOs.UserDTO;
import com.example.demo.Repositories.CommentRepository;
import com.example.demo.Repositories.MapRepository;
import com.example.demo.Repositories.RatingRepository;
import com.example.demo.Repositories.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class DBService {

    private CommentRepository commentRepository;
    private MapRepository mapRepository;
    private RatingRepository ratingRepository;
    private UserRepository userRepository;

    public String add_map(MapDTO mapDTO){

        return "Success";
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



}
