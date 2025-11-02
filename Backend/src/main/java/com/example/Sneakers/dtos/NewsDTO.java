package com.example.Sneakers.dtos;

import com.example.Sneakers.models.News;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class NewsDTO {
    private Long id;
    private String title;
    private String content;
    private String thumbnail;
    private LocalDateTime publishedAt;
    private News.NewsStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static NewsDTO fromNews(News news) {
        return NewsDTO.builder()
                .id(news.getId())
                .title(news.getTitle())
                .content(news.getContent())
                .thumbnail(news.getThumbnail())
                .publishedAt(news.getPublishedAt())
                .status(news.getStatus())
                .createdAt(news.getCreatedAt())
                .updatedAt(news.getUpdatedAt())
                .build();
    }
}
