package com.example.Sneakers.services;

import com.example.Sneakers.dtos.ReviewDTO;
import com.example.Sneakers.dtos.ReviewReplyDTO;
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

import java.time.LocalDateTime;
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

    @Transactional
    public ReviewResponse replyToReview(ReviewReplyDTO replyDTO, Long staffId) throws DataNotFoundException {
        Review review = reviewRepository.findById(replyDTO.getReviewId())
                .orElseThrow(() -> new DataNotFoundException("Review not found"));
        
        User staff = userRepository.findById(staffId)
                .orElseThrow(() -> new DataNotFoundException("Staff not found"));
        
        // Check if staff has STAFF or ADMIN role
        if (!staff.getRole().getName().equals("STAFF") && !staff.getRole().getName().equals("ADMIN")) {
            throw new RuntimeException("Chỉ nhân viên hoặc admin mới có quyền phản hồi đánh giá");
        }
        
        review.setStaffReply(replyDTO.getReply());
        review.setStaffReplyBy(staff);
        review.setStaffReplyAt(LocalDateTime.now());
        
        Review updatedReview = reviewRepository.save(review);
        return ReviewResponse.fromReview(updatedReview);
    }

    public Page<ReviewResponse> getAllReviews(int page, int size, String keyword, Long productId) {
        // Use a custom query that handles missing users gracefully
        // We'll use findAll with JOIN FETCH to load user, but handle missing users
        Pageable pageable = PageRequest.of(page, size);
        Page<Review> reviewsPage;
        
        if (productId != null) {
            // Filter by productId
            reviewsPage = reviewRepository.findByProductId(productId, pageable);
        } else {
            // Get all reviews with pagination
            reviewsPage = reviewRepository.findAll(pageable);
        }
        
        // Filter by keyword if provided (in memory after loading)
        List<Review> filteredReviews = reviewsPage.getContent();
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            String keywordLower = keyword.toLowerCase();
            filteredReviews = filteredReviews.stream()
                .filter(review -> {
                    try {
                        boolean matchesComment = review.getComment() != null && 
                            review.getComment().toLowerCase().contains(keywordLower);
                        boolean matchesUserName = review.getUser() != null && 
                            review.getUser().getFullName() != null &&
                            review.getUser().getFullName().toLowerCase().contains(keywordLower);
                        return matchesComment || matchesUserName;
                    } catch (Exception e) {
                        // If user is missing, just check comment
                        return review.getComment() != null && 
                            review.getComment().toLowerCase().contains(keywordLower);
                    }
                })
                .collect(Collectors.toList());
        }
        
        // Filter out reviews with missing users
        filteredReviews = filteredReviews.stream()
            .filter(review -> {
                try {
                    // Try to access user - if it throws exception, user is missing
                    if (review.getUser() == null) {
                        return false; // Skip reviews with null user
                    }
                    // Try to access user id to trigger lazy loading and catch missing user
                    review.getUser().getId();
                    return true;
                } catch (Exception e) {
                    // User doesn't exist, skip this review
                    System.err.println("ReviewService.getAllReviews() - Skipping review ID " + review.getId() + 
                        " due to missing user: " + e.getMessage());
                    return false;
                }
            })
            .collect(Collectors.toList());
        
        // Apply pagination to filtered results
        int total = filteredReviews.size();
        int start = page * size;
        int end = Math.min(start + size, total);
        
        List<Review> pageContent = start < total ? filteredReviews.subList(start, end) : new java.util.ArrayList<>();
        
        Page<Review> reviewPage = new org.springframework.data.domain.PageImpl<>(pageContent, pageable, total);
        
        return reviewPage.map(review -> {
            try {
                return ReviewResponse.fromReview(review);
            } catch (Exception e) {
                System.err.println("ReviewService.getAllReviews() - Error converting review ID " + review.getId() + ": " + e.getMessage());
                // Return a response with null user info
                ReviewResponse response = ReviewResponse.builder()
                    .id(review.getId())
                    .productId(review.getProduct() != null ? review.getProduct().getId() : null)
                    .userId(null)
                    .userName("Người dùng đã xóa")
                    .rating(review.getRating())
                    .comment(review.getComment())
                    .createdAt(review.getCreatedAt())
                    .updatedAt(review.getUpdatedAt())
                    .staffReply(review.getStaffReply())
                    .staffReplyBy(null)
                    .staffReplyByName(null)
                    .staffReplyAt(review.getStaffReplyAt())
                    .build();
                return response;
            }
        });
    }
}

