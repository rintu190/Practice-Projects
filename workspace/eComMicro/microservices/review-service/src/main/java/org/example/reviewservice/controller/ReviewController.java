package org.example.reviewservice.controller;

import org.example.reviewservice.model.Review;
import org.example.reviewservice.service.ReviewService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/reviews")
public class ReviewController {
    private final ReviewService service;

    public ReviewController(ReviewService service) {
        this.service = service;
    }

    @GetMapping("/product/{productId}")
    public List<Review> byProduct(@PathVariable String productId) {
        return service.findByProductId(productId);
    }

    @PostMapping
    public ResponseEntity<Review> create(@RequestBody Review r) {
        Review created = service.create(r);
        return ResponseEntity.created(URI.create("/reviews/" + created.getId())).body(created);
    }
}

