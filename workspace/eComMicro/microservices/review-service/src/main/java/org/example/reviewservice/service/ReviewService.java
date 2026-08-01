package org.example.reviewservice.service;

import org.example.reviewservice.model.Review;

import java.util.List;

public interface ReviewService {
    List<Review> findByProductId(String productId);
    Review create(Review r);
}

