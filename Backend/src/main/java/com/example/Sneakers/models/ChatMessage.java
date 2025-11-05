package com.example.Sneakers.models;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "chat_messages")
@Data
@Builder
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class ChatMessage extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "sender_id", nullable = true)
    private User sender; // NULL for guest users
    
    @Column(name = "guest_session_id", length = 255)
    private String guestSessionId; // Session ID for guest users (from localStorage)
    
    @ManyToOne
    @JoinColumn(name = "receiver_id")
    private User receiver;

    @Column(name = "message", columnDefinition = "TEXT", nullable = false)
    private String message;

    @Column(name = "message_type", length = 20, nullable = false)
    @Builder.Default
    private String messageType = "TEXT"; // TEXT, IMAGE, FILE

    @Column(name = "is_read", nullable = false)
    @Builder.Default
    private Boolean isRead = false;

    @Column(name = "is_staff_message", nullable = false)
    @Builder.Default
    private Boolean isStaffMessage = false;
    
    @Column(name = "is_closed", nullable = false)
    @Builder.Default
    private Boolean isClosed = false;
    
    @ManyToOne
    @JoinColumn(name = "closed_by")
    private User closedBy; // Staff/Admin who closed the conversation
    
    @Column(name = "closed_at")
    private java.time.LocalDateTime closedAt; // When the conversation was closed
    
    @Column(name = "file_url", length = 500)
    private String fileUrl; // URL to uploaded file
    
    @Column(name = "file_name", length = 255)
    private String fileName; // Original file name
}

