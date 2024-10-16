package com.example.demo.utils;

import com.example.demo.Entities.UserAccount;
import com.example.demo.Repositories.UserRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Component;

@Component
public class UserDataInitializer {

    private final UserRepository userRepository;

    public UserDataInitializer(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @PostConstruct
    public void init() {
        // Check if the data already exists
        if (userRepository.count() == 0) {
            userRepository.save(new UserAccount( "JohnDoe","johniscool", "john.doe@example.com"));

        }
    }
}
