package com.example.Sneakers.models;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

/**
 * ChatConversation represents a chat SESSION (phiên chat).
 * Each conversation can be closed by staff, and a new one is created when customer continues chatting.
 */
@Entity
@Table(name = "chat_conversations", indexes = {
    @Index(name = "idx_conv_customer_staff", columnList = "customer_id,staff_id,is_closed"),
    @Index(name = "idx_conv_guest_session", columnList = "guest_session_id,is_closed")
})
@EqualsAndHashCode(callSuper = false)
@Data
@Builder
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class ChatConversation extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Registered customer (nullable for guest conversations)
    @ManyToOne
    @JoinColumn(name = "customer_id")
    private User customer;

    // Staff that handles this conversation (nullable until assigned)
    @ManyToOne
    @JoinColumn(name = "staff_id")
    private User staff;

    // For guest conversations, we track guest session id
    @Column(name = "guest_session_id", length = 255)
    private String guestSessionId;

    // Is this conversation session closed?
    @Column(name = "is_closed", nullable = false)
    @Builder.Default
    private Boolean isClosed = false;
    
    // Who closed this conversation (staff/admin)
    @ManyToOne
    @JoinColumn(name = "closed_by_id")
    private User closedBy;
    
    // When was this conversation closed
    @Column(name = "closed_at")
    private LocalDateTime closedAt;
    
    // First message time (for sorting conversations)
    @Column(name = "first_message_at")
    private LocalDateTime firstMessageAt;
    
    // Last message time (for sorting conversations)
    @Column(name = "last_message_at")
    private LocalDateTime lastMessageAt;
}



