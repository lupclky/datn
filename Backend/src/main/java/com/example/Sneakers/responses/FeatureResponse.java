package com.example.Sneakers.responses;

import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class FeatureResponse {
    private Long id;
    private String name;
    private String description;
}

