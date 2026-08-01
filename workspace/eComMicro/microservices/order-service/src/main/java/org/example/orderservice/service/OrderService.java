package org.example.orderservice.service;

import org.example.orderservice.model.Order;

import java.util.List;
import java.util.Optional;

public interface OrderService {
    List<Order> findAll();
    Optional<Order> findById(Long id);
    Order create(Order order);
}

