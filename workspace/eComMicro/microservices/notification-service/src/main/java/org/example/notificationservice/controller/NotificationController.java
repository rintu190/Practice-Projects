package org.example.notificationservice.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/notifications")
public class NotificationController {

    @PostMapping("/email")
    public ResponseEntity<Map<String, String>> sendEmail(@RequestBody Map<String, Object> req) {
        return ResponseEntity.ok(Map.of("status", "sent"));
    }

    @PostMapping("/sms")
    public ResponseEntity<Map<String, String>> sendSms(@RequestBody Map<String, Object> req) {
        return ResponseEntity.ok(Map.of("status", "sent"));
    }
}

