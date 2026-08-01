package org.example.orderservice.service.impl;

import org.example.orderservice.model.Order;
import org.example.orderservice.repository.OrderRepository;
import org.example.orderservice.service.OrderService;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class OrderServiceImpl implements OrderService {
    private final OrderRepository repo;

    public OrderServiceImpl(OrderRepository repo) {
        this.repo = repo;
    }

    @Override
    public List<Order> findAll() { return repo.findAll(); }

    @Override
    public Optional<Order> findById(Long id) { return repo.findById(id); }

    @Override
    public Order create(Order order) { return repo.save(order); }
}

