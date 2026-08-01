package org.example.shippingservice.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/shipping")
public class ShippingController {

    @PostMapping("/create")
    public ResponseEntity<Map<String, String>> createShipment(@RequestBody Map<String, Object> req) {
        return ResponseEntity.ok(Map.of("status", "created", "trackingId", "tr-123"));
    }
}

