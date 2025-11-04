package com.example.Sneakers.responses;

import com.example.Sneakers.dtos.BannerDTO;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

@Data
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class BannerResponse {
    @JsonProperty("message")
    private String message;

    @JsonProperty("banner")
    private BannerDTO banner;
}

