package com.example.Sneakers.controllers;

import com.example.Sneakers.dtos.ProductFeatureDTO;
import com.example.Sneakers.services.ProductFeatureService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("${api.prefix}/product-features")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ProductFeatureController {
    private final ProductFeatureService productFeatureService;

    @PostMapping("/product/{productId}")
    public ResponseEntity<List<ProductFeatureDTO>> assignFeaturesToProduct(
            @PathVariable Long productId,
            @RequestBody List<Long> featureIds) {
        return ResponseEntity.ok(productFeatureService.assignFeaturesToProduct(productId, featureIds));
    }

    @GetMapping("/product/{productId}")
    public ResponseEntity<List<ProductFeatureDTO>> getFeaturesByProductId(@PathVariable Long productId) {
        return ResponseEntity.ok(productFeatureService.getFeaturesByProductId(productId));
    }

    @DeleteMapping("/product/{productId}/feature/{featureId}")
    public ResponseEntity<Void> removeFeatureFromProduct(
            @PathVariable Long productId,
            @PathVariable Long featureId) {
        productFeatureService.removeFeatureFromProduct(productId, featureId);
        return ResponseEntity.noContent().build();
    }
}

