package com.example.Sneakers.controllers;

import com.example.Sneakers.dtos.LockFeatureDTO;
import com.example.Sneakers.services.LockFeatureService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("${api.prefix}/lock-features")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class LockFeatureController {
    private final LockFeatureService lockFeatureService;

    @GetMapping
    public ResponseEntity<List<LockFeatureDTO>> getAllFeatures() {
        List<LockFeatureDTO> features = lockFeatureService.getAllFeatures();
        return ResponseEntity.ok(features);
    }

    @GetMapping("/active")
    public ResponseEntity<List<LockFeatureDTO>> getActiveFeatures() {
        List<LockFeatureDTO> features = lockFeatureService.getActiveFeatures();
        return ResponseEntity.ok(features);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getFeatureById(@PathVariable Long id) {
        try {
            LockFeatureDTO feature = lockFeatureService.getFeatureById(id);
            return ResponseEntity.ok(feature);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

    @PostMapping
    public ResponseEntity<?> createFeature(@RequestBody LockFeatureDTO featureDTO) {
        try {
            LockFeatureDTO created = lockFeatureService.createFeature(featureDTO);
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateFeature(@PathVariable Long id, @RequestBody LockFeatureDTO featureDTO) {
        try {
            LockFeatureDTO updated = lockFeatureService.updateFeature(id, featureDTO);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteFeature(@PathVariable Long id) {
        try {
            lockFeatureService.deleteFeature(id);
            return ResponseEntity.noContent().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }
}

