package org.example.productservice.service;

import org.example.productservice.model.Product;

import java.util.List;
import java.util.Optional;

public interface ProductService {
    List<Product> findAll();
    Optional<Product> findById(String id);
    Product create(Product p);
}

