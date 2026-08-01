package org.example.paymentservice.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/payments")
public class PaymentController {

    @PostMapping
    public ResponseEntity<Map<String, String>> pay(@RequestBody Map<String, Object> req) {
        // Stubbed response for scaffold
        return ResponseEntity.ok(Map.of("status", "success", "transactionId", "tx-123"));
    }
}

