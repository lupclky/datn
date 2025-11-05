package com.example.Sneakers.repositories;

import com.example.Sneakers.models.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {
    
    // Get messages between two users (conversation)
    // This includes:
    // 1. Direct messages between two users (both sender and receiver are not null)
    // 2. Public messages from userId1 (sender = userId1, receiver = null)
    // 3. Public messages from userId2 (sender = userId2, receiver = null)
    // 4. Staff replies to userId1 (isStaffMessage = true, receiver = userId1)
    // 5. Staff replies to userId2 (isStaffMessage = true, receiver = userId2)
    // 6. Public staff replies (isStaffMessage = true, receiver = null) - visible to all
    @Query("SELECT m FROM ChatMessage m WHERE " +
           "((m.sender IS NOT NULL AND m.sender.id = :userId1 AND m.receiver IS NOT NULL AND m.receiver.id = :userId2) OR " +
           "(m.sender IS NOT NULL AND m.sender.id = :userId2 AND m.receiver IS NOT NULL AND m.receiver.id = :userId1) OR " +
           "(m.sender IS NOT NULL AND m.sender.id = :userId1 AND m.receiver IS NULL) OR " +
           "(m.sender IS NOT NULL AND m.sender.id = :userId2 AND m.receiver IS NULL) OR " +
           "(m.isStaffMessage = true AND m.receiver IS NOT NULL AND (m.receiver.id = :userId1 OR m.receiver.id = :userId2)) OR " +
           "(m.isStaffMessage = true AND m.receiver IS NULL)) " + // All public staff replies are visible to everyone
           "ORDER BY m.createdAt ASC")
    List<ChatMessage> findConversation(@Param("userId1") Long userId1, @Param("userId2") Long userId2);
    
    // Get conversation for a specific customer (for staff view)
    // Includes messages from customer (both private and public, whether receiver is null or assigned to staff) and staff replies
    // Includes closed conversations so staff can view history
    // Also includes messages assigned to this staff member (receiver = staffId)
    // IMPORTANT: This query must return ALL messages from customer, regardless of receiver status
    // Query logic: 
    // 1. All customer messages (sender = customerId, regardless of receiver)
    // 2. Guest messages (when customerId = 0)
    // 3. Staff replies to customer or from this staff
    @Query("SELECT m FROM ChatMessage m WHERE " +
           "(m.sender IS NOT NULL AND m.sender.id = :customerId AND m.isStaffMessage = false) OR " + // All messages FROM customer (not staff messages)
           "(:customerId = 0 AND m.sender IS NULL AND m.guestSessionId IS NOT NULL AND m.isStaffMessage = false) OR " + // Guest messages (only when customerId = 0)
           "(m.isStaffMessage = true AND m.receiver IS NOT NULL AND m.receiver.id = :customerId) OR " + // Staff replies TO customer
           "(m.isStaffMessage = true AND m.receiver IS NOT NULL AND m.receiver.id = :staffId) OR " + // Staff replies to this staff (for context)
           "(m.isStaffMessage = true AND m.receiver IS NULL AND m.sender IS NOT NULL AND m.sender.id = :staffId) " + // Public staff replies from this staff
           "ORDER BY m.createdAt ASC")
    List<ChatMessage> findConversationForCustomer(@Param("customerId") Long customerId, @Param("staffId") Long staffId);
    
    // Check if conversation is closed
    // For guest users (customerId = 0), check if any guest messages are closed
    @Query("SELECT COUNT(m) > 0 FROM ChatMessage m WHERE " +
           "((m.sender IS NOT NULL AND m.sender.id = :customerId) OR " +
           "(m.isStaffMessage = true AND m.receiver IS NOT NULL AND m.receiver.id = :customerId) OR " +
           "(:customerId = 0 AND m.sender IS NULL AND m.receiver IS NULL AND m.isStaffMessage = false)) AND " +
           "m.isClosed = true")
    boolean isConversationClosed(@Param("customerId") Long customerId);
    
    // Get all messages for a user (including public messages where receiver is null)
    // Also includes staff replies where receiver is the user or receiver is null (public staff replies)
    // IMPORTANT: Sort by createdAt ASC (oldest first) so messages display chronologically
    @Query("SELECT m FROM ChatMessage m WHERE " +
           "(m.sender IS NOT NULL AND m.sender.id = :userId) OR " +
           "(m.receiver IS NOT NULL AND m.receiver.id = :userId) OR " +
           "(m.receiver IS NULL AND m.isStaffMessage = false) OR " + // Customer public messages
           "(m.receiver IS NULL AND m.isStaffMessage = true) " + // Staff public replies (visible to all)
           "ORDER BY m.createdAt ASC")
    List<ChatMessage> findMessagesForUser(@Param("userId") Long userId);
    
    // Get unread messages for a user
    @Query("SELECT m FROM ChatMessage m WHERE " +
           "m.receiver IS NOT NULL AND m.receiver.id = :userId AND m.isRead = false " +
           "ORDER BY m.createdAt ASC")
    List<ChatMessage> findUnreadMessages(@Param("userId") Long userId);
    
    // Get all conversations for staff (messages from customers - exclude null sender)
    @Query("SELECT DISTINCT m.sender FROM ChatMessage m WHERE " +
           "m.sender IS NOT NULL AND m.isStaffMessage = false AND m.receiver IS NULL " +
           "ORDER BY m.createdAt DESC")
    List<com.example.Sneakers.models.User> findCustomersForStaff();
    
    // Get messages from customers waiting for staff response (including guest users)
    // This includes both customer messages and staff replies to customers
    // Excludes closed conversations
    // IMPORTANT: Include messages that have receiver_id assigned (already assigned to staff)
    // but still show them in the customer list so staff can continue the conversation
    // Guest users are identified by guestSessionId or sender IS NULL
    @Query("SELECT m FROM ChatMessage m WHERE " +
           "((m.isStaffMessage = false AND (m.receiver IS NULL OR m.receiver IS NOT NULL)) OR " + // Customer messages (both public and assigned)
           "(m.isStaffMessage = true AND m.receiver IS NULL)) AND " + // Staff public replies (not yet assigned)
           "m.isClosed = false " +
           "ORDER BY m.createdAt ASC")
    List<ChatMessage> findCustomerMessages();
    
    // Find messages by guest session ID
    @Query("SELECT m FROM ChatMessage m WHERE " +
           "m.guestSessionId = :guestSessionId AND m.isClosed = false " +
           "ORDER BY m.createdAt ASC")
    List<ChatMessage> findByGuestSessionId(@Param("guestSessionId") String guestSessionId);
    
    // Get public messages (for guest users to view)
    // Includes customer messages and staff replies that are public (receiver IS NULL)
    // IMPORTANT: Sort by createdAt ASC (oldest first) so messages display chronologically
    @Query("SELECT m FROM ChatMessage m WHERE " +
           "(m.receiver IS NULL AND m.isStaffMessage = false) OR " + // Customer public messages
           "(m.receiver IS NULL AND m.isStaffMessage = true) " + // Staff public replies (visible to all guests)
           "ORDER BY m.createdAt ASC")
    List<ChatMessage> findPublicMessages();
}

