package com.example.Sneakers.dtos;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TopStockProductDTO {
    private Long productId;
    private String productName;
    private String thumbnail;
    private Long quantity;
    private Long price;
    private String categoryName;
}







