package com.example.demo;

import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<UserAccount, Integer> {
    UserAccount findByEmail(String email);
    UserAccount findById(int id);
}
