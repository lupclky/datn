package com.example.Sneakers.controllers;

import com.example.Sneakers.components.LocalizationUtils;
import com.example.Sneakers.dtos.NewsDTO;
import com.example.Sneakers.exceptions.DataNotFoundException;
import com.example.Sneakers.models.News;
import com.example.Sneakers.responses.NewsListResponse;
import com.example.Sneakers.responses.NewsResponse;
import com.example.Sneakers.responses.MessageResponse;
import com.example.Sneakers.services.INewsService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.util.StringUtils;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Objects;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("${api.prefix}/news")
@RequiredArgsConstructor
public class NewsController {
    private static final Logger logger = LoggerFactory.getLogger(NewsController.class);
    private final INewsService newsService;
    private final LocalizationUtils localizationUtils;

    /**
     * Get all published news (for users)
     */
    @GetMapping("/published")
    public ResponseEntity<NewsListResponse> getPublishedNews(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int limit) {
        try {
            PageRequest pageRequest = PageRequest.of(
                    page, limit,
                    Sort.by("publishedAt").descending());
            
            Page<News> newsPage = newsService.getPublishedNews(pageRequest);
            
            List<NewsResponse> newsResponses = newsPage.getContent().stream()
                    .map(this::convertToNewsResponse)
                    .collect(Collectors.toList());
            
            NewsListResponse response = NewsListResponse.builder()
                    .newsList(newsResponses)
                    .totalPages(newsPage.getTotalPages())
                    .build();
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("Error getting published news: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get news by ID (for users) - also increments view count
     */
    @GetMapping("/published/{id}")
    public ResponseEntity<NewsResponse> getPublishedNewsById(@PathVariable Long id) {
        try {
            News news = newsService.getNewsById(id);
            
            // Only allow access to published news for non-admin users
            if (news.getStatus().name().equals("PUBLISHED")) {
                // Increment view count
                newsService.incrementViews(id);
                
                // Reload to get updated view count
                news = newsService.getNewsById(id);
                
                return ResponseEntity.ok(convertToNewsResponse(news));
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
            }
        } catch (DataNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        } catch (Exception e) {
            logger.error("Error getting news by id: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Search published news by keyword
     */
    @GetMapping("/published/search")
    public ResponseEntity<NewsListResponse> searchPublishedNews(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int limit) {
        try {
            PageRequest pageRequest = PageRequest.of(
                    page, limit,
                    Sort.by("publishedAt").descending());
            
            Page<News> newsPage = newsService.searchNews(keyword, pageRequest);
            
            List<NewsResponse> newsResponses = newsPage.getContent().stream()
                    .map(this::convertToNewsResponse)
                    .collect(Collectors.toList());
            
            NewsListResponse response = NewsListResponse.builder()
                    .newsList(newsResponses)
                    .totalPages(newsPage.getTotalPages())
                    .build();
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("Error searching news: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get news by category
     */
    @GetMapping("/published/category/{category}")
    public ResponseEntity<NewsListResponse> getNewsByCategory(
            @PathVariable String category,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int limit) {
        try {
            PageRequest pageRequest = PageRequest.of(
                    page, limit,
                    Sort.by("publishedAt").descending());
            
            Page<News> newsPage = newsService.getNewsByCategory(category, pageRequest);
            
            List<NewsResponse> newsResponses = newsPage.getContent().stream()
                    .map(this::convertToNewsResponse)
                    .collect(Collectors.toList());
            
            NewsListResponse response = NewsListResponse.builder()
                    .newsList(newsResponses)
                    .totalPages(newsPage.getTotalPages())
                    .build();
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("Error getting news by category: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get all categories
     */
    @GetMapping("/categories")
    public ResponseEntity<List<String>> getCategories() {
        try {
            List<String> categories = newsService.getCategories();
            return ResponseEntity.ok(categories);
        } catch (Exception e) {
            logger.error("Error getting categories: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // ==================== ADMIN ENDPOINTS ====================

    /**
     * Get all news (for admin)
     */
    @GetMapping("/admin/all")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<NewsListResponse> getAllNewsForAdmin(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int limit) {
        try {
            PageRequest pageRequest = PageRequest.of(
                    page, limit,
                    Sort.by("createdAt").descending());
            
            Page<News> newsPage = newsService.getAllNews(pageRequest);
            
            List<NewsResponse> newsResponses = newsPage.getContent().stream()
                    .map(this::convertToNewsResponse)
                    .collect(Collectors.toList());
            
            NewsListResponse response = NewsListResponse.builder()
                    .newsList(newsResponses)
                    .totalPages(newsPage.getTotalPages())
                    .build();
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("Error getting all news: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get news by ID (for admin)
     */
    @GetMapping("/admin/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<NewsResponse> getNewsById(@PathVariable Long id) {
        try {
            News news = newsService.getNewsById(id);
            return ResponseEntity.ok(convertToNewsResponse(news));
        } catch (DataNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        } catch (Exception e) {
            logger.error("Error getting news by id: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Create news (admin only)
     */
    @PostMapping("/admin")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> createNews(
            @Valid @RequestBody NewsDTO newsDTO,
            BindingResult result) {
        try {
            if (result.hasErrors()) {
                List<String> errorMessages = result.getFieldErrors().stream()
                        .map(FieldError::getDefaultMessage)
                        .collect(Collectors.toList());
                return ResponseEntity.badRequest().body(errorMessages);
            }
            
            News news = newsService.createNews(newsDTO);
            return ResponseEntity.ok(MessageResponse.builder()
                    .message("News created successfully")
                    .build());
        } catch (Exception e) {
            logger.error("Error creating news: ", e);
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    /**
     * Update news (admin only)
     */
    @PutMapping("/admin/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> updateNews(
            @PathVariable Long id,
            @Valid @RequestBody NewsDTO newsDTO,
            BindingResult result) {
        try {
            if (result.hasErrors()) {
                List<String> errorMessages = result.getFieldErrors().stream()
                        .map(FieldError::getDefaultMessage)
                        .collect(Collectors.toList());
                return ResponseEntity.badRequest().body(errorMessages);
            }
            
            News news = newsService.updateNews(id, newsDTO);
            return ResponseEntity.ok(MessageResponse.builder()
                    .message("News updated successfully")
                    .build());
        } catch (DataNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        } catch (Exception e) {
            logger.error("Error updating news: ", e);
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    /**
     * Delete news (admin only)
     */
    @DeleteMapping("/admin/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> deleteNews(@PathVariable Long id) {
        try {
            newsService.deleteNews(id);
            return ResponseEntity.ok(MessageResponse.builder()
                    .message("News deleted successfully")
                    .build());
        } catch (Exception e) {
            logger.error("Error deleting news: ", e);
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    /**
     * Publish news (admin only)
     */
    @PutMapping("/admin/{id}/publish")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> publishNews(@PathVariable Long id) {
        try {
            News news = newsService.publishNews(id);
            return ResponseEntity.ok(MessageResponse.builder()
                    .message("News published successfully")
                    .build());
        } catch (DataNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        } catch (Exception e) {
            logger.error("Error publishing news: ", e);
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    /**
     * Archive news (admin only)
     */
    @PutMapping("/admin/{id}/archive")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> archiveNews(@PathVariable Long id) {
        try {
            News news = newsService.archiveNews(id);
            return ResponseEntity.ok(MessageResponse.builder()
                    .message("News archived successfully")
                    .build());
        } catch (DataNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        } catch (Exception e) {
            logger.error("Error archiving news: ", e);
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    /**
     * Upload featured image for news (admin only)
     */
    @PostMapping(value = "/admin/upload-image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> uploadFeaturedImage(@RequestParam("file") MultipartFile file) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().body("File is empty");
            }

            // Validate file size (max 5MB)
            if (file.getSize() > 5 * 1024 * 1024) {
                return ResponseEntity.status(HttpStatus.PAYLOAD_TOO_LARGE)
                        .body("File size exceeds maximum limit of 5MB");
            }

            // Validate file type
            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                return ResponseEntity.status(HttpStatus.UNSUPPORTED_MEDIA_TYPE)
                        .body("File must be an image");
            }

            // Store file
            String fileName = storeFile(file);

            return ResponseEntity.ok(new ImageUploadResponse(fileName, "/api/v1/news/images/" + fileName));
        } catch (IOException e) {
            logger.error("Error uploading image: ", e);
            return ResponseEntity.badRequest().body("Failed to upload image: " + e.getMessage());
        }
    }

    /**
     * Get image by filename
     */
    @GetMapping("/images/{imageName}")
    public ResponseEntity<?> viewImage(@PathVariable String imageName) {
        try {
            Path imagePath = Paths.get("uploads").resolve(imageName);
            if (!Files.exists(imagePath)) {
                return ResponseEntity.notFound().build();
            }
            
            org.springframework.core.io.Resource resource = new org.springframework.core.io.UrlResource(imagePath.toUri());
            return ResponseEntity.ok()
                    .contentType(MediaType.IMAGE_JPEG)
                    .body(resource);
        } catch (Exception e) {
            logger.error("Error loading image: ", e);
            return ResponseEntity.notFound().build();
        }
    }

    // Helper methods
    private boolean isImageFile(MultipartFile file) {
        String contentType = file.getContentType();
        return contentType != null && contentType.startsWith("image/");
    }

    private String storeFile(MultipartFile file) throws IOException {
        if (!isImageFile(file) || file.getOriginalFilename() == null) {
            throw new IOException("Invalid image format");
        }
        
        String fileName = StringUtils.cleanPath(Objects.requireNonNull(file.getOriginalFilename()));
        String uniqueFileName = UUID.randomUUID().toString() + "_" + fileName;
        Path uploadDir = Paths.get("uploads");
        
        if (!Files.exists(uploadDir)) {
            Files.createDirectories(uploadDir);
        }
        
        Path destination = Paths.get(uploadDir.toString(), uniqueFileName);
        Files.copy(file.getInputStream(), destination, StandardCopyOption.REPLACE_EXISTING);
        
        return uniqueFileName;
    }

    private NewsResponse convertToNewsResponse(News news) {
        return NewsResponse.builder()
                .id(news.getId())
                .title(news.getTitle())
                .content(news.getContent())
                .summary(news.getSummary())
                .author(news.getAuthor())
                .category(news.getCategory())
                .status(news.getStatus())
                .featuredImage(news.getFeaturedImage())
                .views(news.getViews())
                .publishedAt(news.getPublishedAt())
                .createdAt(news.getCreatedAt())
                .updatedAt(news.getUpdatedAt())
                .build();
    }

    // Inner class for upload response
    @lombok.Data
    @lombok.AllArgsConstructor
    static class ImageUploadResponse {
        private String fileName;
        private String imageUrl;
    }
}

