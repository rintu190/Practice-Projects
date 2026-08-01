package org.example.cartservice.service;

import org.example.cartservice.model.CartItem;

import java.util.List;

public interface CartService {
    List<CartItem> getCart(String userId);
    void addItem(String userId, CartItem item);
}

