package com.example.Sneakers.dtos;

import com.example.Sneakers.models.NewsStatus;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class NewsDTO {
    @JsonProperty("id")
    private Long id;

    @JsonProperty("title")
    @NotBlank(message = "Title is required")
    private String title;

    @JsonProperty("content")
    private String content;

    @JsonProperty("summary")
    private String summary;

    @JsonProperty("author")
    private String author;

    @JsonProperty("category")
    private String category;

    @JsonProperty("status")
    @NotNull(message = "Status is required")
    private NewsStatus status;

    @JsonProperty("featured_image")
    private String featuredImage;

    @JsonProperty("views")
    private Long views;

    @JsonProperty("published_at")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime publishedAt;

    @JsonProperty("created_at")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;

    @JsonProperty("updated_at")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;
}

