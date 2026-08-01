package org.example.cartservice.service.impl;

import org.example.cartservice.model.CartItem;
import org.example.cartservice.service.CartService;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class CartServiceImpl implements CartService {
    // Simple in-memory store keyed by userId for the scaffold
    private final Map<String, List<CartItem>> store = new HashMap<>();

    @Override
    public List<CartItem> getCart(String userId) {
        return store.getOrDefault(userId, Collections.emptyList());
    }

    @Override
    public void addItem(String userId, CartItem item) {
        store.computeIfAbsent(userId, id -> new ArrayList<>()).add(item);
    }
}

