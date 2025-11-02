package com.example.Sneakers.services;

import com.example.Sneakers.dtos.NewsDTO;
import com.example.Sneakers.dtos.NewsPage;
import com.example.Sneakers.models.News;
import com.example.Sneakers.repositories.NewsRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class NewsService {

    private final NewsRepository newsRepository;

    public NewsPage getAllNews(String keyword, String status, int page, int limit) {
        // Đảm bảo page không âm
        if (page < 0) page = 0;
        Pageable pageable = PageRequest.of(page, limit);

        // Sử dụng query đơn giản để test trước
        Page<News> newsPage = newsRepository.findAll(pageable);

        List<NewsDTO> newsDTOs = newsPage.getContent().stream()
                .map(NewsDTO::fromNews)
                .collect(Collectors.toList());

        return NewsPage.builder()
                .news(newsDTOs)
                .totalPages(newsPage.getTotalPages())
                .totalElements(newsPage.getTotalElements())
                .currentPage(page)
                .pageSize(limit)
                .build();
    }

    public News createNews(NewsDTO newsDTO) {
        News news = News.builder()
                .title(newsDTO.getTitle())
                .content(newsDTO.getContent())
                .status(newsDTO.getStatus())
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        return newsRepository.save(news);
    }

    public News updateNews(Long id, NewsDTO newsDTO) {
        News news = newsRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("News not found with id: " + id));
        
        news.setTitle(newsDTO.getTitle());
        news.setContent(newsDTO.getContent());
        news.setStatus(newsDTO.getStatus());
        news.setUpdatedAt(LocalDateTime.now());
        
        return newsRepository.save(news);
    }

    public void deleteNews(Long id) {
        if (!newsRepository.existsById(id)) {
            throw new RuntimeException("News not found with id: " + id);
        }
        newsRepository.deleteById(id);
    }

    public News getNewsById(Long id) {
        return newsRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("News not found with id: " + id));
    }
}
