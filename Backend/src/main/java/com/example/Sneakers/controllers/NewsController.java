package com.example.Sneakers.controllers;

import com.example.Sneakers.dtos.NewsDTO;
import com.example.Sneakers.dtos.NewsPage;
import com.example.Sneakers.models.News;
import com.example.Sneakers.services.NewsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("${api.prefix}/news")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class NewsController {

    private final NewsService newsService;

    @GetMapping(value = "", produces = "application/json")
    public ResponseEntity<?> getAllNews(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int limit) {

        try {
            log.info("Getting news with page: {}, limit: {}", page, limit);
            if (page < 0) {
                page = 0;
            }
            NewsPage newsPage = newsService.getAllNews("", "", page, limit);
            return ResponseEntity.ok(newsPage);

        } catch (Exception e) {
            log.error("Error getting news", e);
            return ResponseEntity.badRequest().body(Map.of("error", "Failed to fetch news", "message", e.getMessage()));
        }
    }

    @GetMapping(value = "/{id}", produces = "application/json")
    public ResponseEntity<?> getNewsById(@PathVariable Long id) {
        try {
            News news = newsService.getNewsById(id);
            return ResponseEntity.ok(NewsDTO.fromNews(news));
        } catch (Exception e) {
            log.error("Error getting news by id: {}", id, e);
            return ResponseEntity.badRequest().body(Map.of("error", "News not found", "message", e.getMessage()));
        }
    }

    @PostMapping(value = "", produces = "application/json")
    public ResponseEntity<?> createNews(
            @RequestBody NewsDTO newsDTO,
            @RequestHeader("Authorization") String authorizationHeader) {
        try {
            log.info("Creating news with title: {}", newsDTO.getTitle());
            News createdNews = newsService.createNews(newsDTO);
            return ResponseEntity.ok(Map.of(
                    "message", "Create news successfully!",
                    "newsId", createdNews.getId()
            ));
        } catch (Exception e) {
            log.error("Error creating news", e);
            return ResponseEntity.badRequest().body(Map.of("error", "Failed to create news", "message", e.getMessage()));
        }
    }

    @PutMapping(value = "/{id}", produces = "application/json")
    public ResponseEntity<?> updateNews(
            @PathVariable Long id,
            @RequestBody NewsDTO newsDTO,
            @RequestHeader("Authorization") String authorizationHeader) {
        try {
            log.info("Updating news id: {}", id);
            News updatedNews = newsService.updateNews(id, newsDTO);
            return ResponseEntity.ok(Map.of(
                    "message", "Update news successfully!",
                    "news", NewsDTO.fromNews(updatedNews)
            ));
        } catch (Exception e) {
            log.error("Error updating news id: {}", id, e);
            return ResponseEntity.badRequest().body(Map.of("error", "Failed to update news", "message", e.getMessage()));
        }
    }

    @DeleteMapping(value = "/{id}", produces = "application/json")
    public ResponseEntity<?> deleteNews(
            @PathVariable Long id,
            @RequestHeader("Authorization") String authorizationHeader) {
        try {
            log.info("Deleting news id: {}", id);
            newsService.deleteNews(id);
            return ResponseEntity.ok(Map.of("message", "Delete news successfully!"));
        } catch (Exception e) {
            log.error("Error deleting news id: {}", id, e);
            return ResponseEntity.badRequest().body(Map.of("error", "Failed to delete news", "message", e.getMessage()));
        }
    }

    @GetMapping("/test")
    public String testNews() {
        return "News API is working!";
    }
}
