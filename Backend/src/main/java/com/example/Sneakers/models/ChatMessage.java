package com.example.Sneakers.models;

import jakarta.persistence.*;
import lombok.*;

/**
 * ChatMessage represents a single message in a conversation session.
 * All messages MUST belong to a conversation (conversation_id is required).
 */
@Entity
@Table(name = "chat_messages", indexes = {
    @Index(name = "idx_msg_conversation_created", columnList = "conversation_id,created_at"),
    @Index(name = "idx_msg_receiver_unread", columnList = "receiver_id,is_read"),
    @Index(name = "idx_msg_guest_session", columnList = "guest_session_id")
})
@EqualsAndHashCode(callSuper = false)
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

    // Link to conversation session (REQUIRED - every message belongs to a session)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "conversation_id", nullable = false)
    private ChatConversation conversation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sender_id")
    private User sender; // NULL for guest users
    
    @Column(name = "guest_session_id", length = 255)
    private String guestSessionId; // Session ID for guest users (from localStorage)
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "receiver_id")
    private User receiver; // NULL for public messages

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
    
    @Column(name = "file_url", length = 500)
    private String fileUrl; // URL to uploaded file
    
    @Column(name = "file_name", length = 255)
    private String fileName; // Original file name
    
    // Removed: is_closed, closed_by, closed_at
    // These are managed at conversation level only
}

