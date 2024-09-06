package com.example.demo.Repositories;

import com.example.demo.Entities.UserAccount;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<UserAccount, Integer> {
    UserAccount findByEmail(String email);
    UserAccount findById(int id);
}
