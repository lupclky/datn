package com.example.Sneakers.controllers;

import com.example.Sneakers.dtos.LockFeatureDTO;
import com.example.Sneakers.services.LockFeatureService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/lock-features")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class LockFeatureController {
    private final LockFeatureService lockFeatureService;

    @GetMapping
    public ResponseEntity<List<LockFeatureDTO>> getAllFeatures() {
        return ResponseEntity.ok(lockFeatureService.getAllFeatures());
    }

    @GetMapping("/{id}")
    public ResponseEntity<LockFeatureDTO> getFeatureById(@PathVariable Long id) {
        return ResponseEntity.ok(lockFeatureService.getFeatureById(id));
    }

    @PostMapping
    public ResponseEntity<LockFeatureDTO> createFeature(@RequestBody LockFeatureDTO featureDTO) {
        return ResponseEntity.ok(lockFeatureService.createFeature(featureDTO));
    }

    @PutMapping("/{id}")
    public ResponseEntity<LockFeatureDTO> updateFeature(@PathVariable Long id, @RequestBody LockFeatureDTO featureDTO) {
        return ResponseEntity.ok(lockFeatureService.updateFeature(id, featureDTO));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteFeature(@PathVariable Long id) {
        lockFeatureService.deleteFeature(id);
        return ResponseEntity.noContent().build();
    }
}

