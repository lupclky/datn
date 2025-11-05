package com.example.Sneakers.models;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "reviews")
@Data
@Builder
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class Review extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "rating", nullable = false)
    private Integer rating; // 1-5 stars

    @Column(name = "comment", columnDefinition = "TEXT")
    private String comment;

    @Column(name = "staff_reply", columnDefinition = "TEXT")
    private String staffReply;

    @ManyToOne
    @JoinColumn(name = "staff_reply_by")
    private User staffReplyBy;

    @Column(name = "staff_reply_at")
    private java.time.LocalDateTime staffReplyAt;
}

