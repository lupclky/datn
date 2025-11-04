package com.example.Sneakers.models;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "news")
@Data
@Builder
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode(callSuper=false)
public class News extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "title", nullable = false, length = 500)
    private String title;

    @Column(name = "content", columnDefinition = "TEXT")
    private String content;

    @Column(name = "summary", length = 1000)
    private String summary;

    @Column(name = "author", length = 100)
    private String author;

    @Column(name = "category", length = 50)
    private String category;

    @Column(name = "status", nullable = false)
    @Enumerated(EnumType.STRING)
    private NewsStatus status;

    @Column(name = "featured_image", length = 500)
    private String featuredImage;

    @Column(name = "views", nullable = false)
    @Builder.Default
    private Long views = 0L;

    @Column(name = "published_at")
    private LocalDateTime publishedAt;
}

