package com.example.Sneakers.responses;

import com.example.Sneakers.models.Review;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ReviewResponse {
    private Long id;
    private Long productId;
    private Long userId;
    private String userName;
    private Integer rating;
    private String comment;
    
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime createdAt;
    
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime updatedAt;
    
    private String staffReply;
    private Long staffReplyBy;
    private String staffReplyByName;
    
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime staffReplyAt;

    public static ReviewResponse fromReview(Review review) {
        try {
            Long userId = null;
            String userName = "Người dùng đã xóa";
            
            try {
                if (review.getUser() != null) {
                    userId = review.getUser().getId();
                    userName = review.getUser().getFullName();
                }
            } catch (Exception e) {
                // User doesn't exist or can't be loaded
                System.err.println("ReviewResponse.fromReview() - User not found for review ID " + review.getId() + ": " + e.getMessage());
            }
            
            Long staffReplyBy = null;
            String staffReplyByName = null;
            
            try {
                if (review.getStaffReplyBy() != null) {
                    staffReplyBy = review.getStaffReplyBy().getId();
                    staffReplyByName = review.getStaffReplyBy().getFullName();
                }
            } catch (Exception e) {
                // Staff reply by user doesn't exist
                System.err.println("ReviewResponse.fromReview() - Staff reply user not found for review ID " + review.getId() + ": " + e.getMessage());
            }
            
            return ReviewResponse.builder()
                    .id(review.getId())
                    .productId(review.getProduct() != null ? review.getProduct().getId() : null)
                    .userId(userId)
                    .userName(userName)
                    .rating(review.getRating())
                    .comment(review.getComment())
                    .createdAt(review.getCreatedAt())
                    .updatedAt(review.getUpdatedAt())
                    .staffReply(review.getStaffReply())
                    .staffReplyBy(staffReplyBy)
                    .staffReplyByName(staffReplyByName)
                    .staffReplyAt(review.getStaffReplyAt())
                    .build();
        } catch (Exception e) {
            System.err.println("ReviewResponse.fromReview() - Error converting review ID " + review.getId() + ": " + e.getMessage());
            e.printStackTrace();
            // Return a minimal response
            return ReviewResponse.builder()
                    .id(review.getId())
                    .productId(null)
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
        }
    }
}

