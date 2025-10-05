package com.example.Sneakers.services;

import com.example.Sneakers.dtos.ProductFeatureDTO;
import com.example.Sneakers.models.LockFeature;
import com.example.Sneakers.models.Product;
import com.example.Sneakers.models.ProductFeature;
import com.example.Sneakers.repositories.LockFeatureRepository;
import com.example.Sneakers.repositories.ProductFeatureRepository;
import com.example.Sneakers.repositories.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProductFeatureService {
    private final ProductFeatureRepository productFeatureRepository;
    private final ProductRepository productRepository;
    private final LockFeatureRepository lockFeatureRepository;

    @Transactional
    public List<ProductFeatureDTO> assignFeaturesToProduct(Long productId, List<Long> featureIds) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        // Xóa các chức năng hiện tại của sản phẩm
        productFeatureRepository.deleteByProductId(productId);

        // Thêm các chức năng mới
        List<ProductFeature> productFeatures = featureIds.stream()
                .map(featureId -> {
                    LockFeature feature = lockFeatureRepository.findById(featureId)
                            .orElseThrow(() -> new RuntimeException("Feature not found"));

                    return ProductFeature.builder()
                            .product(product)
                            .feature(feature)
                            .build();
                })
                .collect(Collectors.toList());

        List<ProductFeature> savedFeatures = productFeatureRepository.saveAll(productFeatures);
        return savedFeatures.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<ProductFeatureDTO> getFeaturesByProductId(Long productId) {
        List<ProductFeature> productFeatures = productFeatureRepository.findByProductIdWithFeature(productId);
        return productFeatures.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public void removeFeatureFromProduct(Long productId, Long featureId) {
        productFeatureRepository.findByProductIdAndFeatureId(productId, featureId)
                .ifPresent(productFeatureRepository::delete);
    }

    private ProductFeatureDTO convertToDTO(ProductFeature productFeature) {
        return ProductFeatureDTO.builder()
                .id(productFeature.getId())
                .productId(productFeature.getProduct().getId())
                .featureId(productFeature.getFeature().getId())
                .featureName(productFeature.getFeature().getName())
                .featureDescription(productFeature.getFeature().getDescription())
                .build();
    }
}

