package org.example.analytics.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/analytics")
public class AnalyticsController {

    @PostMapping("/event")
    public ResponseEntity<Map<String, String>> acceptEvent(@RequestBody Map<String, Object> event) {
        // stub: in a real app we'd push to Kafka or process
        return ResponseEntity.ok(Map.of("status", "accepted"));
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        return ResponseEntity.ok(Map.of("status", "ok"));
    }
}

