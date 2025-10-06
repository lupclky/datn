package com.example.Sneakers.controllers;

import com.example.Sneakers.dtos.ReviewDTO;
import com.example.Sneakers.exceptions.DataNotFoundException;
import com.example.Sneakers.models.User;
import com.example.Sneakers.repositories.UserRepository;
import com.example.Sneakers.responses.ReviewResponse;
import com.example.Sneakers.services.ReviewService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("${api.prefix}/reviews")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ReviewController {
    private final ReviewService reviewService;
    private final UserRepository userRepository;

    @PostMapping
    public ResponseEntity<?> createReview(@Valid @RequestBody ReviewDTO reviewDTO) {
        try {
            System.out.println("Received ReviewDTO: " + reviewDTO);
            System.out.println("ProductId: " + reviewDTO.getProductId());
            System.out.println("Rating: " + reviewDTO.getRating());
            System.out.println("Comment: " + reviewDTO.getComment());
            
            Long userId = getCurrentUserId();
            System.out.println("Current UserId: " + userId);
            
            ReviewResponse response = reviewService.createReview(reviewDTO, userId);
            return ResponseEntity.ok(response);
        } catch (DataNotFoundException e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("error", "Internal server error: " + e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<ReviewResponse> updateReview(
            @PathVariable Long id,
            @Valid @RequestBody ReviewDTO reviewDTO) throws DataNotFoundException {
        Long userId = getCurrentUserId();
        ReviewResponse response = reviewService.updateReview(id, reviewDTO, userId);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteReview(@PathVariable Long id) {
        try {
            System.out.println("Delete review request - ReviewId: " + id);
            Long userId = getCurrentUserId();
            System.out.println("Current UserId: " + userId);
            reviewService.deleteReview(id, userId);
            return ResponseEntity.noContent().build();
        } catch (DataNotFoundException e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (RuntimeException e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("error", "Internal server error: " + e.getMessage()));
        }
    }

    @GetMapping("/product/{productId}")
    public ResponseEntity<List<ReviewResponse>> getReviewsByProduct(@PathVariable Long productId) {
        List<ReviewResponse> reviews = reviewService.getReviewsByProductId(productId);
        return ResponseEntity.ok(reviews);
    }

    @GetMapping("/product/{productId}/paginated")
    public ResponseEntity<Page<ReviewResponse>> getReviewsByProductPaginated(
            @PathVariable Long productId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Page<ReviewResponse> reviews = reviewService.getReviewsByProductIdPaginated(productId, page, size);
        return ResponseEntity.ok(reviews);
    }

    @GetMapping("/product/{productId}/stats")
    public ResponseEntity<Map<String, Object>> getProductRatingStats(@PathVariable Long productId) {
        Map<String, Object> stats = reviewService.getProductRatingStats(productId);
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ReviewResponse> getReviewById(@PathVariable Long id) throws DataNotFoundException {
        ReviewResponse review = reviewService.getReviewById(id);
        return ResponseEntity.ok(review);
    }

    private Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof User) {
            // If principal is already our User entity
            User user = (User) authentication.getPrincipal();
            return user.getId();
        } else if (authentication != null && authentication.getPrincipal() instanceof org.springframework.security.core.userdetails.User) {
            // If principal is Spring Security User, get by phone number (username)
            org.springframework.security.core.userdetails.User userDetails = 
                (org.springframework.security.core.userdetails.User) authentication.getPrincipal();
            String phoneNumber = userDetails.getUsername();
            User user = userRepository.findByPhoneNumber(phoneNumber)
                .orElseThrow(() -> new RuntimeException("User not found"));
            return user.getId();
        }
        throw new RuntimeException("User not authenticated");
    }
}

