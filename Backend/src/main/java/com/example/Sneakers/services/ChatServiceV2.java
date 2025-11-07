package com.example.Sneakers.services;

import com.example.Sneakers.dtos.ChatMessageDTO;
import com.example.Sneakers.exceptions.DataNotFoundException;
import com.example.Sneakers.models.ChatMessage;
import com.example.Sneakers.models.ChatConversation;
import com.example.Sneakers.models.User;
import com.example.Sneakers.repositories.ChatMessageRepository;
import com.example.Sneakers.repositories.ChatConversationRepository;
import com.example.Sneakers.repositories.UserRepository;
import com.example.Sneakers.responses.ChatMessageResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * ChatServiceV2 - Conversation-based chat service
 * 
 * Key concepts:
 * - ChatConversation = một phiên chat (session)
 * - ChatMessage = tin nhắn trong phiên
 * - Khi staff đóng phiên → customer tiếp tục chat → tạo phiên mới
 */
@Service("chatServiceV2")
@RequiredArgsConstructor
public class ChatServiceV2 {
    private final ChatMessageRepository chatMessageRepository;
    private final ChatConversationRepository chatConversationRepository;
    private final UserRepository userRepository;

    /**
     * Send a message. Creates or finds active conversation automatically.
     */
    @Transactional
    public ChatMessageResponse sendMessage(ChatMessageDTO chatMessageDTO, Long senderId) throws DataNotFoundException {
        User sender = null;
        if (senderId != null) {
            sender = userRepository.findById(senderId)
                    .orElseThrow(() -> new DataNotFoundException("Sender not found"));
        }
        
        User receiver = null;
        if (chatMessageDTO.getReceiverId() != null) {
            receiver = userRepository.findById(chatMessageDTO.getReceiverId())
                    .orElseThrow(() -> new DataNotFoundException("Receiver not found"));
        }

        // Get or create active conversation
        ChatConversation conversation = getOrCreateActiveConversation(sender, receiver, chatMessageDTO.getGuestSessionId());

        ChatMessage chatMessage = ChatMessage.builder()
                .conversation(conversation)
                .sender(sender)
                .guestSessionId(chatMessageDTO.getGuestSessionId())
                .receiver(receiver)
                .message(chatMessageDTO.getMessage())
                .messageType(chatMessageDTO.getMessageType() != null ? chatMessageDTO.getMessageType() : "TEXT")
                .isRead(false)
                .isStaffMessage(chatMessageDTO.getIsStaffMessage() != null ? chatMessageDTO.getIsStaffMessage() : false)
                .build();

        ChatMessage savedMessage = chatMessageRepository.save(chatMessage);
        
        // Update conversation timestamps
        updateConversationTimestamps(conversation);
        
        return ChatMessageResponse.fromChatMessage(savedMessage);
    }

    /**
     * Send a file message
     */
    @Transactional
    public ChatMessageResponse sendFileMessage(ChatMessageDTO chatMessageDTO, Long senderId, String fileUrl, String fileName) throws DataNotFoundException {
        User sender = null;
        if (senderId != null) {
            sender = userRepository.findById(senderId)
                    .orElseThrow(() -> new DataNotFoundException("Sender not found"));
        }
        
        User receiver = null;
        if (chatMessageDTO.getReceiverId() != null) {
            receiver = userRepository.findById(chatMessageDTO.getReceiverId())
                    .orElseThrow(() -> new DataNotFoundException("Receiver not found"));
        }

        ChatConversation conversation = getOrCreateActiveConversation(sender, receiver, chatMessageDTO.getGuestSessionId());

        ChatMessage chatMessage = ChatMessage.builder()
                .conversation(conversation)
                .sender(sender)
                .guestSessionId(chatMessageDTO.getGuestSessionId())
                .receiver(receiver)
                .message(chatMessageDTO.getMessage())
                .messageType(chatMessageDTO.getMessageType() != null ? chatMessageDTO.getMessageType() : "FILE")
                .isRead(false)
                .isStaffMessage(chatMessageDTO.getIsStaffMessage() != null ? chatMessageDTO.getIsStaffMessage() : false)
                .fileUrl(fileUrl)
                .fileName(fileName)
                .build();

        ChatMessage savedMessage = chatMessageRepository.save(chatMessage);
        updateConversationTimestamps(conversation);
        
        return ChatMessageResponse.fromChatMessage(savedMessage);
    }

    /**
     * Get or create active conversation.
     * If closed conversation exists, creates a NEW one (phiên mới).
     */
    @Transactional
    public ChatConversation getOrCreateActiveConversation(User sender, User receiver, String guestSessionId) {
        // Determine customer and staff
        User customer = (sender != null && (sender.getRole() == null || sender.getRole().getId() == 1L)) ? sender : null;
        if (customer == null && receiver != null && (receiver.getRole() == null || receiver.getRole().getId() == 1L)) {
            customer = receiver;
        }

        User staff = (sender != null && sender.getRole() != null && (sender.getRole().getId() == 2L || sender.getRole().getId() == 3L)) ? sender : null;
        if (staff == null && receiver != null && receiver.getRole() != null && (receiver.getRole().getId() == 2L || receiver.getRole().getId() == 3L)) {
            staff = receiver;
        }

        // For guest conversations (no registered customer)
        if (customer == null && guestSessionId != null && !guestSessionId.trim().isEmpty()) {
            java.util.Optional<ChatConversation> existing = chatConversationRepository
                    .findActiveByGuestSession(guestSessionId);
            if (existing.isPresent()) {
                ChatConversation conv = existing.get();
                // If staff is replying and not yet assigned, assign them
                if (staff != null && conv.getStaff() == null) {
                    conv.setStaff(staff);
                    chatConversationRepository.save(conv);
                }
                return conv;
            }
            // Create new guest conversation
            return chatConversationRepository.save(ChatConversation.builder()
                    .guestSessionId(guestSessionId)
                    .staff(staff) // May be null if guest initiated, will be set when staff replies
                    .isClosed(false)
                    .firstMessageAt(LocalDateTime.now())
                    .lastMessageAt(LocalDateTime.now())
                    .build());
        }

        // For registered customer conversations (with or without staff)
        if (customer != null) {
            // First, try to find active conversation for this customer
            List<ChatConversation> customerConversations = chatConversationRepository
                    .findByCustomerOrderByLastMessageAtDesc(customer);
            
            // Find the most recent active conversation
            java.util.Optional<ChatConversation> activeConv = customerConversations.stream()
                    .filter(c -> !c.getIsClosed())
                    .findFirst();
            
            if (activeConv.isPresent()) {
                ChatConversation conv = activeConv.get();
                // If staff is replying and not yet assigned, assign them
                if (staff != null && conv.getStaff() == null) {
                    conv.setStaff(staff);
                    chatConversationRepository.save(conv);
                }
                return conv;
            }
            
            // Create new conversation
            return chatConversationRepository.save(ChatConversation.builder()
                    .customer(customer)
                    .staff(staff) // May be null if customer initiated, will be set when staff replies
                    .isClosed(false)
                    .firstMessageAt(LocalDateTime.now())
                    .lastMessageAt(LocalDateTime.now())
                    .build());
        }

        // Fallback: create loose conversation (shouldn't happen in normal flow)
        return chatConversationRepository.save(ChatConversation.builder()
                .customer(customer)
                .staff(staff)
                .guestSessionId(guestSessionId)
                .isClosed(false)
                .firstMessageAt(LocalDateTime.now())
                .lastMessageAt(LocalDateTime.now())
                .build());
    }

    /**
     * Get all messages in a conversation
     */
    public List<ChatMessageResponse> getConversationMessages(Long conversationId) {
        List<ChatMessage> messages = chatMessageRepository.findByConversationIdOrderByCreatedAtAsc(conversationId);
        return messages.stream()
                .map(ChatMessageResponse::fromChatMessage)
                .collect(Collectors.toList());
    }

    /**
     * Get all active conversations (for staff dashboard)
     */
    public List<ChatConversation> getAllActiveConversations() {
        return chatConversationRepository.findAllActiveOrderByLastMessageAtDesc();
    }

    /**
     * Get conversations for a specific customer
     */
    public List<ChatConversation> getCustomerConversations(Long customerId) throws DataNotFoundException {
        User customer = userRepository.findById(customerId)
                .orElseThrow(() -> new DataNotFoundException("Customer not found"));
        return chatConversationRepository.findByCustomerOrderByLastMessageAtDesc(customer);
    }

    /**
     * Close a conversation (staff action)
     * Customer can continue chatting → creates NEW conversation
     */
    @Transactional
    public void closeConversation(Long conversationId, Long staffId) throws DataNotFoundException {
        ChatConversation conversation = chatConversationRepository.findById(conversationId)
                .orElseThrow(() -> new DataNotFoundException("Conversation not found"));
        
        User staff = userRepository.findById(staffId)
                .orElseThrow(() -> new DataNotFoundException("Staff not found"));
        
        conversation.setIsClosed(true);
        conversation.setClosedBy(staff);
        conversation.setClosedAt(LocalDateTime.now());
        chatConversationRepository.save(conversation);
    }

    /**
     * Customer ends their own session
     * Closes the active conversation, next message will create a new one
     */
    @Transactional
    public void endCustomerSession(Long customerId) throws DataNotFoundException {
        User customer = userRepository.findById(customerId)
                .orElseThrow(() -> new DataNotFoundException("Customer not found"));
        
        // Find all active conversations for this customer
        List<ChatConversation> conversations = chatConversationRepository
                .findByCustomerOrderByLastMessageAtDesc(customer);
        
        // Close all active conversations
        for (ChatConversation conv : conversations) {
            if (!conv.getIsClosed()) {
                conv.setIsClosed(true);
                conv.setClosedBy(customer); // Customer closed it themselves
                conv.setClosedAt(LocalDateTime.now());
                chatConversationRepository.save(conv);
            }
        }
    }

    /**
     * Mark messages as read in a conversation
     */
    @Transactional
    public void markConversationAsRead(Long conversationId, Long userId) {
        List<ChatMessage> messages = chatMessageRepository.findByConversationIdOrderByCreatedAtAsc(conversationId);
        for (ChatMessage message : messages) {
            if (message.getReceiver() != null && message.getReceiver().getId().equals(userId) && !message.getIsRead()) {
                message.setIsRead(true);
            }
        }
        chatMessageRepository.saveAll(messages);
    }

    /**
     * Get unread message count for a user
     */
    public Long getUnreadCount(Long userId) {
        return chatMessageRepository.countUnreadMessages(userId);
    }

    /**
     * Update conversation timestamps after sending a message
     */
    private void updateConversationTimestamps(ChatConversation conversation) {
        if (conversation.getFirstMessageAt() == null) {
            conversation.setFirstMessageAt(LocalDateTime.now());
        }
        conversation.setLastMessageAt(LocalDateTime.now());
        chatConversationRepository.save(conversation);
    }

    /**
     * Get conversation for customer (staff view)
     */
    public List<ChatMessageResponse> getConversationForCustomer(Long customerId, Long staffId) throws DataNotFoundException {
        User customer = userRepository.findById(customerId)
                .orElseThrow(() -> new DataNotFoundException("Customer not found"));
        User staff = userRepository.findById(staffId)
                .orElseThrow(() -> new DataNotFoundException("Staff not found"));
        
        // Find active conversation
        java.util.Optional<ChatConversation> conversationOpt = chatConversationRepository
                .findActiveByCustomerAndStaff(customer, staff);
        
        if (conversationOpt.isPresent()) {
            return getConversationMessages(conversationOpt.get().getId());
        }
        return List.of();
    }

    /**
     * Get conversation between two users
     */
    public List<ChatMessageResponse> getConversation(Long userId1, Long userId2) throws DataNotFoundException {
        User user1 = userRepository.findById(userId1)
                .orElseThrow(() -> new DataNotFoundException("User 1 not found"));
        User user2 = userRepository.findById(userId2)
                .orElseThrow(() -> new DataNotFoundException("User 2 not found"));
        
        // Try to find conversation either way
        java.util.Optional<ChatConversation> conversationOpt = chatConversationRepository
                .findActiveByCustomerAndStaff(user1, user2);
        
        if (!conversationOpt.isPresent()) {
            conversationOpt = chatConversationRepository.findActiveByCustomerAndStaff(user2, user1);
        }
        
        if (conversationOpt.isPresent()) {
            return getConversationMessages(conversationOpt.get().getId());
        }
        return List.of();
    }

    /**
     * Get messages for a specific user
     */
    /**
     * Get all messages for a user (both sent and received) - only from active conversations
     */
    public List<ChatMessageResponse> getMessagesForUser(Long userId) {
        // Get all conversations for this user
        User user = userRepository.findById(userId).orElse(null);
        if (user == null) {
            return new ArrayList<>();
        }
        
        // Get ONLY ACTIVE conversations where user is customer (isClosed = false)
        List<ChatConversation> conversations = chatConversationRepository.findByCustomerOrderByLastMessageAtDesc(user);
        
        // Filter to only active (not closed) conversations
        conversations = conversations.stream()
                .filter(conv -> !conv.getIsClosed())
                .collect(Collectors.toList());
        
        // Get all messages from these active conversations
        List<ChatMessage> allMessages = new ArrayList<>();
        for (ChatConversation conv : conversations) {
            List<ChatMessage> convMessages = chatMessageRepository.findByConversationIdOrderByCreatedAtAsc(conv.getId());
            allMessages.addAll(convMessages);
        }
        
        // Sort by created time
        allMessages.sort((a, b) -> {
            if (a.getCreatedAt() == null) return -1;
            if (b.getCreatedAt() == null) return 1;
            return a.getCreatedAt().compareTo(b.getCreatedAt());
        });
        
        return allMessages.stream()
                .map(ChatMessageResponse::fromChatMessage)
                .collect(Collectors.toList());
    }

    /**
     * Get public messages (for guests)
     */
    public List<ChatMessageResponse> getPublicMessages() {
        List<ChatMessage> messages = chatMessageRepository.findPublicMessagesOrderByCreatedAtDesc();
        return messages.stream()
                .map(ChatMessageResponse::fromChatMessage)
                .collect(Collectors.toList());
    }

    /**
     * Get unread messages for a user
     */
    public List<ChatMessageResponse> getUnreadMessages(Long userId) {
        List<ChatMessage> messages = chatMessageRepository.findUnreadMessagesByReceiverId(userId);
        return messages.stream()
                .map(ChatMessageResponse::fromChatMessage)
                .collect(Collectors.toList());
    }

    /**
     * Get all customer messages (for staff dashboard)
     */
    public List<ChatMessageResponse> getCustomerMessages() {
        List<ChatMessage> messages = chatMessageRepository.findCustomerMessagesOrderByCreatedAtDesc();
        return messages.stream()
                .map(ChatMessageResponse::fromChatMessage)
                .collect(Collectors.toList());
    }

    /**
     * Mark a specific message as read
     */
    @Transactional
    public void markAsRead(Long messageId, Long userId) throws DataNotFoundException {
        ChatMessage message = chatMessageRepository.findById(messageId)
                .orElseThrow(() -> new DataNotFoundException("Message not found"));
        
        if (message.getReceiver() != null && message.getReceiver().getId().equals(userId)) {
            message.setIsRead(true);
            chatMessageRepository.save(message);
        }
    }

    /**
     * Mark all messages as read for a user
     */
    @Transactional
    public void markAllAsRead(Long userId) {
        List<ChatMessage> messages = chatMessageRepository.findByReceiverId(userId);
        for (ChatMessage message : messages) {
            if (!message.getIsRead()) {
                message.setIsRead(true);
            }
        }
        chatMessageRepository.saveAll(messages);
    }

    /**
     * Get conversation status for customer - check if last conversation was closed by staff
     */
    public Map<String, Object> getCustomerConversationStatus(Long customerId) {
        User customer = userRepository.findById(customerId).orElse(null);
        if (customer == null) {
            return Map.of(
                "hasActiveConversation", false,
                "lastConversationClosedByStaff", false
            );
        }

        // Get all conversations for customer, sorted by last message time
        List<ChatConversation> conversations = chatConversationRepository.findByCustomerOrderByLastMessageAtDesc(customer);
        
        // Check if there's any active conversation
        boolean hasActiveConversation = conversations.stream()
                .anyMatch(conv -> !conv.getIsClosed());

        // Check if the most recent conversation was closed by staff
        boolean lastClosedByStaff = false;
        String closedByName = null;
        
        if (!conversations.isEmpty()) {
            ChatConversation lastConversation = conversations.get(0);
            if (lastConversation.getIsClosed() && lastConversation.getClosedBy() != null) {
                User closedBy = lastConversation.getClosedBy();
                // Check if closed by staff (not customer)
                if (!closedBy.getId().equals(customerId)) {
                    lastClosedByStaff = true;
                    closedByName = closedBy.getFullName();
                }
            }
        }

        return Map.of(
            "hasActiveConversation", hasActiveConversation,
            "lastConversationClosedByStaff", lastClosedByStaff,
            "closedByStaffName", closedByName != null ? closedByName : ""
        );
    }
}
