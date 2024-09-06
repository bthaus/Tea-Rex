package com.example.demo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public List<UserAccount> getAllUsers() {
        return userRepository.findAll();
    }

    public UserAccount getUserByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    public UserAccount saveUser(UserAccount userAccount) {
        return userRepository.save(userAccount);
    }
}
