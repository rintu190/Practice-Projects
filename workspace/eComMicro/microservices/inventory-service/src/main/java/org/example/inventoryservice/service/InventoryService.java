package org.example.inventoryservice.service;

import org.example.inventoryservice.model.Inventory;

import java.util.List;
import java.util.Optional;

public interface InventoryService {
    List<Inventory> findAll();
    Optional<Inventory> findById(Long id);
    Inventory create(Inventory inv);
    Inventory findByProductId(String productId);
}

