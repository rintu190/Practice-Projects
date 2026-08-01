package org.example.inventoryservice.controller;

import org.example.inventoryservice.model.Inventory;
import org.example.inventoryservice.service.InventoryService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/inventory")
public class InventoryController {
    private final InventoryService service;

    public InventoryController(InventoryService service) {
        this.service = service;
    }

    @GetMapping
    public List<Inventory> list() { return service.findAll(); }

    @GetMapping("/{id}")
    public ResponseEntity<Inventory> get(@PathVariable Long id) {
        return service.findById(id).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Inventory> create(@RequestBody Inventory inv) {
        Inventory created = service.create(inv);
        return ResponseEntity.created(URI.create("/inventory/" + created.getId())).body(created);
    }

    @GetMapping("/product/{productId}")
    public ResponseEntity<Inventory> byProduct(@PathVariable String productId) {
        Inventory inv = service.findByProductId(productId);
        if (inv == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(inv);
    }
}

