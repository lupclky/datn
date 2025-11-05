package com.example.Sneakers.responses;

import com.example.Sneakers.models.Product;
import com.example.Sneakers.models.ProductImage;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ProductResponse extends BaseResponse{
    private Long id;

    private String name;

    private Long price;

    private String thumbnail;

    private String description;

    @JsonProperty("category_id")
    private Long categoryId;

    private Long discount;

    private Long quantity;

    @JsonProperty("product_images")
    private List<ProductImage> productImages= new ArrayList<>();

    private List<FeatureResponse> features = new ArrayList<>();
    
    private Double averageRating;
    
    private Long totalReviews;

    public static ProductResponse fromProduct(Product product){
        List<FeatureResponse> features = product.getProductFeatures() != null ?
            product.getProductFeatures().stream()
                .map(pf -> FeatureResponse.builder()
                    .id(pf.getFeature().getId())
                    .name(pf.getFeature().getName())
                    .description(pf.getFeature().getDescription())
                    .build())
                .collect(Collectors.toList()) : new ArrayList<>();

        // Get product images - ensure we have the list even if lazy loaded
        List<ProductImage> productImages = product.getProductImages() != null ? 
            product.getProductImages() : new ArrayList<>();
        
        // If no thumbnail but has product_images, set first image as thumbnail
        String thumbnail = product.getThumbnail();
        if ((thumbnail == null || thumbnail.trim().isEmpty() || "null".equals(thumbnail)) 
            && !productImages.isEmpty() && productImages.get(0) != null) {
            thumbnail = productImages.get(0).getImageUrl();
        }

        ProductResponse productResponse = ProductResponse.builder()
                .id(product.getId())
                .name(product.getName())
                .price(product.getPrice())
                .thumbnail(thumbnail)
                .description(product.getDescription())
                .categoryId(product.getCategory() != null ? product.getCategory().getId() : null)
                .discount(product.getDiscount())
                .quantity(product.getQuantity())
                .productImages(productImages)
                .features(features)
                .build();
        productResponse.setCreatedAt(product.getCreatedAt());
        productResponse.setUpdatedAt(product.getUpdatedAt());
        return productResponse;
    }
}