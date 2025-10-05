package com.example.Sneakers.dtos;

import lombok.*;

@Data
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ProductFeatureDTO {
    private Long id;
    private Long productId;
    private Long featureId;
    private String featureName;
    private String featureDescription;
}

