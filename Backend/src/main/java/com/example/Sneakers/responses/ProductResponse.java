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

    public static ProductResponse fromProduct(Product product){
        List<FeatureResponse> features = product.getProductFeatures() != null ?
            product.getProductFeatures().stream()
                .map(pf -> FeatureResponse.builder()
                    .id(pf.getFeature().getId())
                    .name(pf.getFeature().getName())
                    .description(pf.getFeature().getDescription())
                    .build())
                .collect(Collectors.toList()) : new ArrayList<>();

        ProductResponse productResponse = ProductResponse.builder()
                .id(product.getId())
                .name(product.getName())
                .price(product.getPrice())
                .thumbnail(product.getThumbnail())
                .description(product.getDescription())
                .categoryId(product.getCategory() != null ? product.getCategory().getId() : null)
                .discount(product.getDiscount())
                .quantity(product.getQuantity())
                .productImages(product.getProductImages())
                .features(features)
                .build();
        productResponse.setCreatedAt(product.getCreatedAt());
        productResponse.setUpdatedAt(product.getUpdatedAt());
        return productResponse;
    }
}