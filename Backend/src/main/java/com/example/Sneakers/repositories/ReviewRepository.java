package com.example.Sneakers.repositories;

import com.example.Sneakers.models.Review;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {
    
    @Query("SELECT r FROM Review r JOIN FETCH r.user WHERE r.product.id = :productId ORDER BY r.createdAt DESC")
    List<Review> findByProductIdWithUser(@Param("productId") Long productId);
    
    Page<Review> findByProductId(Long productId, Pageable pageable);
    
    @Query("SELECT AVG(r.rating) FROM Review r WHERE r.product.id = :productId")
    Double getAverageRatingByProductId(@Param("productId") Long productId);
    
    @Query("SELECT COUNT(r) FROM Review r WHERE r.product.id = :productId")
    Long countByProductId(@Param("productId") Long productId);
    
    Optional<Review> findByProductIdAndUserId(Long productId, Long userId);
    
    boolean existsByProductIdAndUserId(Long productId, Long userId);
}

