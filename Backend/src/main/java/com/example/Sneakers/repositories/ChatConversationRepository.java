package com.example.Sneakers.repositories;

import com.example.Sneakers.models.ChatConversation;
import com.example.Sneakers.models.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ChatConversationRepository extends JpaRepository<ChatConversation, Long> {

    // Find active (not closed) conversation by customer and staff
    @Query("SELECT c FROM ChatConversation c WHERE c.customer = :customer AND c.staff = :staff AND c.isClosed = false")
    Optional<ChatConversation> findActiveByCustomerAndStaff(@Param("customer") User customer,
                                                            @Param("staff") User staff);

    // Find active conversation by guest session ID
    @Query("SELECT c FROM ChatConversation c WHERE c.guestSessionId = :guestSessionId AND c.isClosed = false")
    Optional<ChatConversation> findActiveByGuestSession(@Param("guestSessionId") String guestSessionId);
    
    // Find all conversations for a customer (both active and closed, sorted by last activity)
    @Query("SELECT c FROM ChatConversation c WHERE c.customer = :customer ORDER BY c.lastMessageAt DESC NULLS LAST, c.createdAt DESC")
    List<ChatConversation> findByCustomerOrderByLastMessageAtDesc(@Param("customer") User customer);
    
    // Find all active conversations (for staff dashboard)
    @Query("SELECT c FROM ChatConversation c WHERE c.isClosed = false ORDER BY c.lastMessageAt DESC NULLS LAST, c.createdAt DESC")
    List<ChatConversation> findAllActiveOrderByLastMessageAtDesc();
    
    // Find all conversations assigned to a staff member
    @Query("SELECT c FROM ChatConversation c WHERE c.staff = :staff ORDER BY c.lastMessageAt DESC NULLS LAST, c.createdAt DESC")
    List<ChatConversation> findByStaffOrderByLastMessageAtDesc(@Param("staff") User staff);
    
    // Find all guest conversations (active only)
    @Query("SELECT c FROM ChatConversation c WHERE c.guestSessionId IS NOT NULL AND c.isClosed = false ORDER BY c.lastMessageAt DESC NULLS LAST, c.createdAt DESC")
    List<ChatConversation> findGuestConversations();
}




