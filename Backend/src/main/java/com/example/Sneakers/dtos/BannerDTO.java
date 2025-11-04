package com.example.Sneakers.dtos;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.time.LocalDateTime;

@Data
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class BannerDTO {
    @JsonProperty("id")
    private Long id;

    @JsonProperty("title")
    @NotBlank(message = "Title is required")
    private String title;

    @JsonProperty("description")
    private String description;

    @JsonProperty("image_url")
    @NotBlank(message = "Image URL is required")
    private String imageUrl;

    @JsonProperty("button_text")
    private String buttonText;

    @JsonProperty("button_link")
    private String buttonLink;

    @JsonProperty("button_style")
    private String buttonStyle;

    @JsonProperty("display_order")
    private Integer displayOrder;

    @JsonProperty("is_active")
    private Boolean isActive;

    @JsonProperty("start_date")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime startDate;

    @JsonProperty("end_date")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime endDate;

    @JsonProperty("created_at")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;

    @JsonProperty("updated_at")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;
}

