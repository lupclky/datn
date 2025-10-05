package com.example.Sneakers.dtos;

import lombok.*;

@Data
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class LockFeatureDTO {
    private Long id;
    private String name;
    private String description;
    private Boolean isActive;
}

