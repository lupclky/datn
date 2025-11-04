package com.example.Sneakers.services;

import com.example.Sneakers.dtos.NewsDTO;
import com.example.Sneakers.exceptions.DataNotFoundException;
import com.example.Sneakers.models.News;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;

import java.util.List;

public interface INewsService {
    News createNews(NewsDTO newsDTO);
    
    News updateNews(Long id, NewsDTO newsDTO) throws DataNotFoundException;
    
    void deleteNews(Long id);
    
    News getNewsById(Long id) throws DataNotFoundException;
    
    Page<News> getAllNews(PageRequest pageRequest);
    
    Page<News> getPublishedNews(PageRequest pageRequest);
    
    Page<News> getNewsByCategory(String category, PageRequest pageRequest);
    
    Page<News> searchNews(String keyword, PageRequest pageRequest);
    
    void incrementViews(Long id);
    
    List<String> getCategories();
    
    News publishNews(Long id) throws DataNotFoundException;
    
    News archiveNews(Long id) throws DataNotFoundException;
}

