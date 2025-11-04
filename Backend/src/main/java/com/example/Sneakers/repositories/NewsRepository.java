package com.example.Sneakers.repositories;

import com.example.Sneakers.models.News;
import com.example.Sneakers.models.NewsStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface NewsRepository extends JpaRepository<News, Long> {
    // Find all published news
    Page<News> findByStatusOrderByPublishedAtDesc(NewsStatus status, Pageable pageable);

    // Find news by category
    Page<News> findByStatusAndCategoryOrderByPublishedAtDesc(NewsStatus status, String category, Pageable pageable);

    // Find news by title containing keyword
    Page<News> findByStatusAndTitleContainingIgnoreCaseOrderByPublishedAtDesc(NewsStatus status, String keyword, Pageable pageable);

    // Get all news for admin (all statuses)
    Page<News> findAllByOrderByCreatedAtDesc(Pageable pageable);

    // Get news by status
    Page<News> findByStatusOrderByCreatedAtDesc(NewsStatus status, Pageable pageable);

    // Increment view count
    @Modifying
    @Query("UPDATE News n SET n.views = n.views + 1 WHERE n.id = :id")
    void incrementViews(@Param("id") Long id);

    // Get distinct categories
    @Query("SELECT DISTINCT n.category FROM News n WHERE n.status = :status AND n.category IS NOT NULL ORDER BY n.category")
    List<String> findDistinctCategoriesByStatus(@Param("status") NewsStatus status);
}

