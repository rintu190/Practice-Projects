package org.example.cartservice.controller;

import org.example.cartservice.model.CartItem;
import org.example.cartservice.service.CartService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/carts")
public class CartController {
    private final CartService service;

    public CartController(CartService service) {
        this.service = service;
    }

    @GetMapping("/{userId}")
    public List<CartItem> get(@PathVariable String userId) {
        return service.getCart(userId);
    }

    @PostMapping("/{userId}")
    public ResponseEntity<Void> add(@PathVariable String userId, @RequestBody CartItem item) {
        service.addItem(userId, item);
        return ResponseEntity.created(URI.create("/carts/" + userId)).build();
    }
}

