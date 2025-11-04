package com.example.Sneakers.services;

import com.example.Sneakers.dtos.NewsDTO;
import com.example.Sneakers.exceptions.DataNotFoundException;
import com.example.Sneakers.models.News;
import com.example.Sneakers.models.NewsStatus;
import com.example.Sneakers.repositories.NewsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NewsService implements INewsService {
    private final NewsRepository newsRepository;

    @Override
    @Transactional
    public News createNews(NewsDTO newsDTO) {
        News news = News.builder()
                .title(newsDTO.getTitle())
                .content(newsDTO.getContent())
                .summary(newsDTO.getSummary())
                .author(newsDTO.getAuthor())
                .category(newsDTO.getCategory())
                .status(newsDTO.getStatus() != null ? newsDTO.getStatus() : NewsStatus.DRAFT)
                .featuredImage(newsDTO.getFeaturedImage())
                .views(0L)
                .build();

        // Set published date if status is PUBLISHED
        if (news.getStatus() == NewsStatus.PUBLISHED) {
            news.setPublishedAt(LocalDateTime.now());
        }

        return newsRepository.save(news);
    }

    @Override
    @Transactional
    public News updateNews(Long id, NewsDTO newsDTO) throws DataNotFoundException {
        News existingNews = newsRepository.findById(id)
                .orElseThrow(() -> new DataNotFoundException("Cannot find news with id = " + id));

        existingNews.setTitle(newsDTO.getTitle());
        existingNews.setContent(newsDTO.getContent());
        existingNews.setSummary(newsDTO.getSummary());
        existingNews.setAuthor(newsDTO.getAuthor());
        existingNews.setCategory(newsDTO.getCategory());
        existingNews.setFeaturedImage(newsDTO.getFeaturedImage());

        // Update status
        NewsStatus oldStatus = existingNews.getStatus();
        if (newsDTO.getStatus() != null && newsDTO.getStatus() != oldStatus) {
            existingNews.setStatus(newsDTO.getStatus());
            
            // Set published date when changing from DRAFT to PUBLISHED
            if (oldStatus != NewsStatus.PUBLISHED && newsDTO.getStatus() == NewsStatus.PUBLISHED) {
                existingNews.setPublishedAt(LocalDateTime.now());
            }
        }

        return newsRepository.save(existingNews);
    }

    @Override
    @Transactional
    public void deleteNews(Long id) {
        newsRepository.deleteById(id);
    }

    @Override
    public News getNewsById(Long id) throws DataNotFoundException {
        return newsRepository.findById(id)
                .orElseThrow(() -> new DataNotFoundException("Cannot find news with id = " + id));
    }

    @Override
    public Page<News> getAllNews(PageRequest pageRequest) {
        return newsRepository.findAllByOrderByCreatedAtDesc(pageRequest);
    }

    @Override
    public Page<News> getPublishedNews(PageRequest pageRequest) {
        return newsRepository.findByStatusOrderByPublishedAtDesc(NewsStatus.PUBLISHED, pageRequest);
    }

    @Override
    public Page<News> getNewsByCategory(String category, PageRequest pageRequest) {
        return newsRepository.findByStatusAndCategoryOrderByPublishedAtDesc(
                NewsStatus.PUBLISHED, category, pageRequest);
    }

    @Override
    public Page<News> searchNews(String keyword, PageRequest pageRequest) {
        return newsRepository.findByStatusAndTitleContainingIgnoreCaseOrderByPublishedAtDesc(
                NewsStatus.PUBLISHED, keyword, pageRequest);
    }

    @Override
    @Transactional
    public void incrementViews(Long id) {
        newsRepository.incrementViews(id);
    }

    @Override
    public List<String> getCategories() {
        return newsRepository.findDistinctCategoriesByStatus(NewsStatus.PUBLISHED);
    }

    @Override
    @Transactional
    public News publishNews(Long id) throws DataNotFoundException {
        News news = newsRepository.findById(id)
                .orElseThrow(() -> new DataNotFoundException("Cannot find news with id = " + id));
        
        news.setStatus(NewsStatus.PUBLISHED);
        if (news.getPublishedAt() == null) {
            news.setPublishedAt(LocalDateTime.now());
        }
        
        return newsRepository.save(news);
    }

    @Override
    @Transactional
    public News archiveNews(Long id) throws DataNotFoundException {
        News news = newsRepository.findById(id)
                .orElseThrow(() -> new DataNotFoundException("Cannot find news with id = " + id));
        
        news.setStatus(NewsStatus.ARCHIVED);
        return newsRepository.save(news);
    }
}

