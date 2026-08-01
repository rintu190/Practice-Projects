package org.example.inventoryservice.service.impl;

import org.example.inventoryservice.model.Inventory;
import org.example.inventoryservice.repository.InventoryRepository;
import org.example.inventoryservice.service.InventoryService;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class InventoryServiceImpl implements InventoryService {
    private final InventoryRepository repo;

    public InventoryServiceImpl(InventoryRepository repo) {
        this.repo = repo;
    }

    @Override
    public List<Inventory> findAll() { return repo.findAll(); }

    @Override
    public Optional<Inventory> findById(Long id) { return repo.findById(id); }

    @Override
    public Inventory create(Inventory inv) { return repo.save(inv); }

    @Override
    public Inventory findByProductId(String productId) { return repo.findByProductId(productId); }
}

