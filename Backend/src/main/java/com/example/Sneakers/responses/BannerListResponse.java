package com.example.Sneakers.responses;

import com.example.Sneakers.dtos.BannerDTO;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import java.util.List;

@Data
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class BannerListResponse {
    @JsonProperty("message")
    private String message;

    @JsonProperty("banners")
    private List<BannerDTO> banners;

    @JsonProperty("total")
    private int total;
}



