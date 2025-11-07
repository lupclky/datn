package com.example.Sneakers.repositories;

import com.example.Sneakers.models.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {
    
    // Get all messages in a conversation (sorted by creation time)
    @Query("SELECT m FROM ChatMessage m WHERE m.conversation.id = :conversationId ORDER BY m.createdAt ASC")
    List<ChatMessage> findByConversationIdOrderByCreatedAtAsc(@Param("conversationId") Long conversationId);
    
    // Get unread messages for a user across all their conversations
    @Query("SELECT m FROM ChatMessage m WHERE m.receiver IS NOT NULL AND m.receiver.id = :userId AND m.isRead = false ORDER BY m.createdAt ASC")
    List<ChatMessage> findUnreadMessages(@Param("userId") Long userId);
    
    // Count unread messages for a user
    @Query("SELECT COUNT(m) FROM ChatMessage m WHERE m.receiver IS NOT NULL AND m.receiver.id = :userId AND m.isRead = false")
    Long countUnreadMessages(@Param("userId") Long userId);
    
    // Get last message in a conversation (for preview)
    @Query("SELECT m FROM ChatMessage m WHERE m.conversation.id = :conversationId ORDER BY m.createdAt DESC LIMIT 1")
    ChatMessage findLastMessageByConversationId(@Param("conversationId") Long conversationId);
    
    // Get all messages for a specific receiver
    @Query("SELECT m FROM ChatMessage m WHERE m.receiver IS NOT NULL AND m.receiver.id = :userId ORDER BY m.createdAt DESC")
    List<ChatMessage> findByReceiverId(@Param("userId") Long userId);
    
    // Get unread messages by receiver ID
    @Query("SELECT m FROM ChatMessage m WHERE m.receiver IS NOT NULL AND m.receiver.id = :userId AND m.isRead = false ORDER BY m.createdAt DESC")
    List<ChatMessage> findUnreadMessagesByReceiverId(@Param("userId") Long userId);
    
    // Get public messages (messages without receiver, typically for guest users)
    @Query("SELECT m FROM ChatMessage m WHERE m.receiver IS NULL AND m.isStaffMessage = false ORDER BY m.createdAt DESC")
    List<ChatMessage> findPublicMessagesOrderByCreatedAtDesc();
    
    // Get customer messages (non-staff messages for staff dashboard)
    @Query("SELECT m FROM ChatMessage m WHERE m.isStaffMessage = false ORDER BY m.createdAt DESC")
    List<ChatMessage> findCustomerMessagesOrderByCreatedAtDesc();
    
    // Get conversation between two users (legacy method for old ChatService)
    @Query("SELECT m FROM ChatMessage m WHERE " +
           "(m.sender.id = :userId1 AND m.receiver.id = :userId2) OR " +
           "(m.sender.id = :userId2 AND m.receiver.id = :userId1) " +
           "ORDER BY m.createdAt ASC")
    List<ChatMessage> findConversation(@Param("userId1") Long userId1, @Param("userId2") Long userId2);
    
    // Get conversation for customer (legacy method for old ChatService)
    @Query("SELECT m FROM ChatMessage m WHERE " +
           "(m.sender.id = :customerId OR m.receiver.id = :customerId) AND " +
           "(m.sender.id = :staffId OR m.receiver.id = :staffId) " +
           "ORDER BY m.createdAt ASC")
    List<ChatMessage> findConversationForCustomer(@Param("customerId") Long customerId, @Param("staffId") Long staffId);
}

