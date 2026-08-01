package org.example.reviewservice.service.impl;

import org.example.reviewservice.model.Review;
import org.example.reviewservice.repository.ReviewRepository;
import org.example.reviewservice.service.ReviewService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ReviewServiceImpl implements ReviewService {
    private final ReviewRepository repo;

    public ReviewServiceImpl(ReviewRepository repo) {
        this.repo = repo;
    }

    @Override
    public List<Review> findByProductId(String productId) {
        return repo.findByProductId(productId);
    }

    @Override
    public Review create(Review r) {
        return repo.save(r);
    }
}

