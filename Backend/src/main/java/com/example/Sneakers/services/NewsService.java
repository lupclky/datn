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
    private final IFacebookService facebookService;

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

        News savedNews = newsRepository.save(news);

        // Share to Facebook if requested
        if (Boolean.TRUE.equals(newsDTO.getShareToFacebook())) {
            try {
                shareNewsToFacebook(savedNews.getId(), newsDTO.getFacebookScheduledTime());
            } catch (Exception e) {
                // Log error but allow creation to proceed
                System.err.println("Failed to share news to Facebook during creation: " + e.getMessage());
            }
        }

        return savedNews;
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

        News savedNews = newsRepository.save(existingNews);

        // Share to Facebook if requested
        if (Boolean.TRUE.equals(newsDTO.getShareToFacebook())) {
            try {
                shareNewsToFacebook(savedNews.getId(), newsDTO.getFacebookScheduledTime());
            } catch (Exception e) {
                // Log error but allow creation to proceed
                System.err.println("Failed to share news to Facebook during update: " + e.getMessage());
            }
        }

        return savedNews;
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

    @Override
    @Transactional
    public void shareNewsToFacebook(Long id, Long scheduledTime) throws Exception {
        News news = getNewsById(id);
        
        // Use a configured base URL or default to localhost for dev
        String baseUrl = "http://localhost:4200"; // Should be in config
        
        // Create a rich message content
        StringBuilder message = new StringBuilder();
        message.append(news.getTitle().toUpperCase()).append("\n\n");
        
        if (news.getSummary() != null && !news.getSummary().isEmpty()) {
            message.append(news.getSummary()).append("\n\n");
        }
        
        if (news.getContent() != null && !news.getContent().isEmpty()) {
            String plainContent = stripHtml(news.getContent());
            // Truncate if too long (Facebook has high limits but good to be safe/concise, e.g. 5000 chars)
            if (plainContent.length() > 5000) {
                plainContent = plainContent.substring(0, 5000) + "...";
            }
            message.append(plainContent).append("\n\n");
        }
        
        // Append content (stripped of HTML if possible, or just raw text if simple)
        // Here we just append the "Read more" link as text
        message.append("--------------------\n");
        message.append("Xem bài viết gốc tại: ").append(baseUrl).append("/news/").append(news.getId());
        
        // Pass null for link parameter to avoid creating a link preview card
        // This will post as a regular status update with text
        String responseBody = facebookService.postToPage(message.toString(), null, scheduledTime);
        
        // Parse JSON response to get ID
        try {
            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            com.fasterxml.jackson.databind.JsonNode root = mapper.readTree(responseBody);
            String fbId = root.path("id").asText();
            
            news.setFacebookPostId(fbId);
            if (scheduledTime != null) {
                // Convert UNIX timestamp to LocalDateTime
                news.setFacebookScheduledAt(LocalDateTime.ofEpochSecond(scheduledTime, 0, java.time.ZoneOffset.of("+07:00")));
            } else {
                // Shared immediately, so scheduled time is null (or you could set it to now)
                news.setFacebookScheduledAt(null);
            }
            
            newsRepository.save(news);
            
        } catch (Exception e) {
            // Log error but don't fail the request as sharing might have succeeded
            System.err.println("Error parsing Facebook response or saving news: " + e.getMessage());
        }
    }

    @Override
    @Transactional
    public void syncFacebookPosts() {
        // Find all news that have a facebook post ID and are marked as scheduled (facebookScheduledAt is not null)
        List<News> scheduledNews = newsRepository.findByFacebookPostIdIsNotNullAndFacebookScheduledAtIsNotNull();
        
        for (News news : scheduledNews) {
            try {
                // Check if the post is published on Facebook
                boolean isPublished = facebookService.isPostPublished(news.getFacebookPostId());
                
                if (isPublished) {
                    // If published, clear the scheduled time to indicate it's now live
                    news.setFacebookScheduledAt(null);
                    newsRepository.save(news);
                }
            } catch (Exception e) {
                System.err.println("Error syncing FB post " + news.getFacebookPostId() + ": " + e.getMessage());
            }
        }
    }

    private String stripHtml(String html) {
        if (html == null) return "";
        // Replace paragraph and break tags with newlines to preserve some formatting
        String text = html.replaceAll("(?i)<br\\s*/?>", "\n")
                          .replaceAll("(?i)</?p\\s*>", "\n");
        // Remove all other HTML tags
        text = text.replaceAll("<[^>]+>", "");
        // Decode common HTML entities (basic ones)
        text = text.replace("&nbsp;", " ")
                   .replace("&amp;", "&")
                   .replace("&lt;", "<")
                   .replace("&gt;", ">")
                   .replace("&quot;", "\"")
                   .replace("&#39;", "'");
        // Remove multiple extra newlines
        return text.replaceAll("\\n\\s*\\n", "\n\n").trim();
    }
}

