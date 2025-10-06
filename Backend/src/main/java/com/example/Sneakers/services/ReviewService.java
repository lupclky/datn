package com.example.Sneakers.services;

import com.example.Sneakers.dtos.ReviewDTO;
import com.example.Sneakers.exceptions.DataNotFoundException;
import com.example.Sneakers.models.Product;
import com.example.Sneakers.models.Review;
import com.example.Sneakers.models.User;
import com.example.Sneakers.repositories.ProductRepository;
import com.example.Sneakers.repositories.ReviewRepository;
import com.example.Sneakers.repositories.UserRepository;
import com.example.Sneakers.responses.ReviewResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReviewService {
    private final ReviewRepository reviewRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;

    @Transactional
    public ReviewResponse createReview(ReviewDTO reviewDTO, Long userId) throws DataNotFoundException {
        // Check if user already reviewed this product
        if (reviewRepository.existsByProductIdAndUserId(reviewDTO.getProductId(), userId)) {
            throw new RuntimeException("Bạn đã đánh giá sản phẩm này rồi");
        }

        Product product = productRepository.findById(reviewDTO.getProductId())
                .orElseThrow(() -> new DataNotFoundException("Product not found"));
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new DataNotFoundException("User not found"));

        Review review = Review.builder()
                .product(product)
                .user(user)
                .rating(reviewDTO.getRating())
                .comment(reviewDTO.getComment())
                .build();

        Review savedReview = reviewRepository.save(review);
        return ReviewResponse.fromReview(savedReview);
    }

    @Transactional
    public ReviewResponse updateReview(Long reviewId, ReviewDTO reviewDTO, Long userId) throws DataNotFoundException {
        Review review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new DataNotFoundException("Review not found"));

        // Check if user owns this review
        if (!review.getUser().getId().equals(userId)) {
            throw new RuntimeException("Bạn không có quyền sửa đánh giá này");
        }

        review.setRating(reviewDTO.getRating());
        review.setComment(reviewDTO.getComment());

        Review updatedReview = reviewRepository.save(review);
        return ReviewResponse.fromReview(updatedReview);
    }

    @Transactional
    public void deleteReview(Long reviewId, Long userId) throws DataNotFoundException {
        Review review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new DataNotFoundException("Review not found"));

        System.out.println("Review owner ID: " + review.getUser().getId());
        System.out.println("Current user ID: " + userId);
        System.out.println("IDs equal? " + review.getUser().getId().equals(userId));
        
        // Check if user owns this review
        if (!review.getUser().getId().equals(userId)) {
            throw new RuntimeException("Bạn không có quyền xóa đánh giá này");
        }

        reviewRepository.delete(review);
        System.out.println("Review deleted successfully");
    }

    public List<ReviewResponse> getReviewsByProductId(Long productId) {
        return reviewRepository.findByProductIdWithUser(productId).stream()
                .map(ReviewResponse::fromReview)
                .collect(Collectors.toList());
    }

    public Page<ReviewResponse> getReviewsByProductIdPaginated(Long productId, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return reviewRepository.findByProductId(productId, pageable)
                .map(ReviewResponse::fromReview);
    }

    public Map<String, Object> getProductRatingStats(Long productId) {
        Double avgRating = reviewRepository.getAverageRatingByProductId(productId);
        Long totalReviews = reviewRepository.countByProductId(productId);

        Map<String, Object> stats = new HashMap<>();
        stats.put("averageRating", avgRating != null ? avgRating : 0.0);
        stats.put("totalReviews", totalReviews);
        
        return stats;
    }

    public ReviewResponse getReviewById(Long reviewId) throws DataNotFoundException {
        Review review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new DataNotFoundException("Review not found"));
        return ReviewResponse.fromReview(review);
    }
}

