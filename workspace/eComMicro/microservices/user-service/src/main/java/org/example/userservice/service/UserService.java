package org.example.userservice.service;

import org.example.userservice.model.User;

import java.util.List;
import java.util.Optional;

public interface UserService {
    List<User> findAll();
    Optional<User> findById(Long id);
    User create(User user);
}

