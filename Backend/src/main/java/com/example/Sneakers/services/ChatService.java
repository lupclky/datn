package com.example.Sneakers.services;

import com.example.Sneakers.dtos.ChatMessageDTO;
import com.example.Sneakers.exceptions.DataNotFoundException;
import com.example.Sneakers.models.ChatMessage;
import com.example.Sneakers.models.User;
import com.example.Sneakers.repositories.ChatMessageRepository;
import com.example.Sneakers.repositories.UserRepository;
import com.example.Sneakers.responses.ChatMessageResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatService {
    private final ChatMessageRepository chatMessageRepository;
    private final UserRepository userRepository;

    @Transactional
    public ChatMessageResponse sendMessage(ChatMessageDTO chatMessageDTO, Long senderId) throws DataNotFoundException {
        User sender = null;
        if (senderId != null) {
            sender = userRepository.findById(senderId)
                    .orElseThrow(() -> new DataNotFoundException("Sender not found"));
        }
        // If senderId is null, sender will be null (guest user)
        
        User receiver = null;
        if (chatMessageDTO.getReceiverId() != null) {
            receiver = userRepository.findById(chatMessageDTO.getReceiverId())
                    .orElseThrow(() -> new DataNotFoundException("Receiver not found"));
        }

        ChatMessage chatMessage = ChatMessage.builder()
                .sender(sender)
                .guestSessionId(chatMessageDTO.getGuestSessionId()) // Store guest session ID
                .receiver(receiver)
                .message(chatMessageDTO.getMessage())
                .messageType(chatMessageDTO.getMessageType() != null ? chatMessageDTO.getMessageType() : "TEXT")
                .isRead(false)
                .isStaffMessage(chatMessageDTO.getIsStaffMessage() != null ? chatMessageDTO.getIsStaffMessage() : false)
                .build();

        ChatMessage savedMessage = chatMessageRepository.save(chatMessage);
        return ChatMessageResponse.fromChatMessage(savedMessage);
    }

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

        ChatMessage chatMessage = ChatMessage.builder()
                .sender(sender)
                .guestSessionId(chatMessageDTO.getGuestSessionId()) // Store guest session ID
                .receiver(receiver)
                .message(chatMessageDTO.getMessage())
                .messageType(chatMessageDTO.getMessageType() != null ? chatMessageDTO.getMessageType() : "FILE")
                .isRead(false)
                .isStaffMessage(chatMessageDTO.getIsStaffMessage() != null ? chatMessageDTO.getIsStaffMessage() : false)
                .fileUrl(fileUrl)
                .fileName(fileName)
                .build();

        ChatMessage savedMessage = chatMessageRepository.save(chatMessage);
        return ChatMessageResponse.fromChatMessage(savedMessage);
    }

    public List<ChatMessageResponse> getConversation(Long userId1, Long userId2) {
        List<ChatMessage> messages = chatMessageRepository.findConversation(userId1, userId2);
        return messages.stream()
                .map(ChatMessageResponse::fromChatMessage)
                .collect(Collectors.toList());
    }

    public List<ChatMessageResponse> getConversationForCustomer(Long customerId, Long staffId) {
        // Validate that customerId and staffId are different
        if (customerId != null && staffId != null && customerId.equals(staffId)) {
            System.err.println("ERROR: customerId and staffId are the same: " + customerId + ". This should not happen!");
            System.err.println("customerId should be the customer's ID, staffId should be the staff/admin's ID");
        }
        
        System.out.println("getConversationForCustomer - customerId: " + customerId + ", staffId: " + staffId);
        
        // First, mark messages as received by staff (assigns receiver_id to staff for public messages)
        try {
            markMessagesAsReceivedByStaff(customerId, staffId);
        } catch (DataNotFoundException e) {
            System.err.println("Error marking messages as received: " + e.getMessage());
        }
        
        // Then get all messages for the conversation
        List<ChatMessage> messages = chatMessageRepository.findConversationForCustomer(customerId, staffId);
        System.out.println("Total messages found: " + messages.size());
        
        // Count customer messages vs staff messages
        long customerMsgCount = messages.stream()
                .filter(m -> m.getSender() != null && m.getSender().getId().equals(customerId) && !m.getIsStaffMessage())
                .count();
        long staffMsgCount = messages.stream()
                .filter(m -> m.getIsStaffMessage())
                .count();
        System.out.println("Customer messages: " + customerMsgCount + ", Staff messages: " + staffMsgCount);
        
        messages.forEach(m -> {
            System.out.println("Message ID: " + m.getId() + 
                             ", Sender: " + (m.getSender() != null ? m.getSender().getId() : "null") +
                             ", Receiver: " + (m.getReceiver() != null ? m.getReceiver().getId() : "null") +
                             ", IsStaffMessage: " + m.getIsStaffMessage() +
                             ", Message: " + (m.getMessage() != null ? m.getMessage().substring(0, Math.min(50, m.getMessage().length())) : "null"));
        });
        return messages.stream()
                .map(ChatMessageResponse::fromChatMessage)
                .collect(Collectors.toList());
    }

    @Transactional
    public void markMessagesAsReceivedByStaff(Long customerId, Long staffId) throws DataNotFoundException {
        User staff = userRepository.findById(staffId)
                .orElseThrow(() -> new DataNotFoundException("Staff not found"));
        
        // Get all messages from customer that don't have a receiver yet (public messages)
        List<ChatMessage> messagesToUpdate = new java.util.ArrayList<>();
        
        if (customerId == null || customerId == 0) {
            // Guest user - get the first batch of guest messages (from same session if possible)
            // We'll get messages that are not already assigned
            List<ChatMessage> allGuestMessages = chatMessageRepository.findAll().stream()
                    .filter(m -> m.getSender() == null && 
                                m.getGuestSessionId() != null &&
                                m.getReceiver() == null && 
                                !m.getIsStaffMessage() && 
                                !m.getIsClosed())
                    .sorted((a, b) -> a.getCreatedAt().compareTo(b.getCreatedAt()))
                    .collect(Collectors.toList());
            
            // Group by guestSessionId and get the first session's messages
            if (!allGuestMessages.isEmpty()) {
                // Create a final variable for use in lambda
                final String guestSessionId = allGuestMessages.get(0).getGuestSessionId();
                messagesToUpdate = allGuestMessages.stream()
                        .filter(m -> guestSessionId != null && guestSessionId.equals(m.getGuestSessionId()))
                        .collect(Collectors.toList());
            }
        } else {
            // Registered user - get messages from customer that are public (receiver IS NULL)
            // Only get messages that are not already assigned to another staff
            List<ChatMessage> customerMessages = chatMessageRepository.findAll().stream()
                    .filter(m -> m.getSender() != null && 
                                m.getSender().getId().equals(customerId) && 
                                m.getReceiver() == null && 
                                !m.getIsStaffMessage() &&
                                !m.getIsClosed())
                    .collect(Collectors.toList());
            messagesToUpdate.addAll(customerMessages);
        }
        
        // Update receiver to staff for messages that don't have a receiver yet
        // This assigns the conversation to this staff member
        for (ChatMessage message : messagesToUpdate) {
            if (message.getReceiver() == null) {
                message.setReceiver(staff);
                message.setIsRead(false); // Reset read status since it's now assigned to staff
            }
        }
        
        if (!messagesToUpdate.isEmpty()) {
            chatMessageRepository.saveAll(messagesToUpdate);
        }
    }

    public List<ChatMessageResponse> getMessagesForUser(Long userId) {
        List<ChatMessage> messages = chatMessageRepository.findMessagesForUser(userId);
        return messages.stream()
                .map(ChatMessageResponse::fromChatMessage)
                .collect(Collectors.toList());
    }

    public List<ChatMessageResponse> getUnreadMessages(Long userId) {
        List<ChatMessage> messages = chatMessageRepository.findUnreadMessages(userId);
        return messages.stream()
                .map(ChatMessageResponse::fromChatMessage)
                .collect(Collectors.toList());
    }

    public List<ChatMessageResponse> getCustomerMessages() {
        List<ChatMessage> messages = chatMessageRepository.findCustomerMessages();
        return messages.stream()
                .map(ChatMessageResponse::fromChatMessage)
                .collect(Collectors.toList());
    }

    public List<ChatMessageResponse> getPublicMessages() {
        List<ChatMessage> messages = chatMessageRepository.findPublicMessages();
        return messages.stream()
                .map(ChatMessageResponse::fromChatMessage)
                .collect(Collectors.toList());
    }

    @Transactional
    public void markAsRead(Long messageId, Long userId) throws DataNotFoundException {
        ChatMessage message = chatMessageRepository.findById(messageId)
                .orElseThrow(() -> new DataNotFoundException("Message not found"));
        
        // Only mark as read if user is the receiver
        if (message.getReceiver() != null && message.getReceiver().getId().equals(userId)) {
            message.setIsRead(true);
            chatMessageRepository.save(message);
        }
    }

    @Transactional
    public void markAllAsRead(Long userId) {
        List<ChatMessage> unreadMessages = chatMessageRepository.findUnreadMessages(userId);
        for (ChatMessage message : unreadMessages) {
            message.setIsRead(true);
        }
        chatMessageRepository.saveAll(unreadMessages);
    }

    @Transactional
    public void closeConversation(Long customerId, Long staffId) throws DataNotFoundException {
        User staff = userRepository.findById(staffId)
                .orElseThrow(() -> new DataNotFoundException("Staff not found"));
        
        List<ChatMessage> messagesToClose = new java.util.ArrayList<>();
        
        // Handle guest users (customerId = 0 or null means guest)
        if (customerId == null || customerId == 0) {
            // Get all guest messages (sender IS NULL, receiver IS NULL, not closed)
            List<ChatMessage> guestMessages = chatMessageRepository.findAll().stream()
                    .filter(m -> m.getSender() == null && m.getReceiver() == null && !m.getIsClosed() && !m.getIsStaffMessage())
                    .collect(Collectors.toList());
            messagesToClose.addAll(guestMessages);
            
            // Also get staff replies to public messages (receiver IS NULL, isStaffMessage = true)
            List<ChatMessage> staffPublicReplies = chatMessageRepository.findAll().stream()
                    .filter(m -> m.getIsStaffMessage() && m.getReceiver() == null && !m.getIsClosed())
                    .collect(Collectors.toList());
            messagesToClose.addAll(staffPublicReplies);
        } else {
            // Registered user - get all messages in the conversation
            List<ChatMessage> messages = chatMessageRepository.findConversationForCustomer(customerId, staffId);
            messagesToClose.addAll(messages);
            
            // Also mark messages from customer (public messages)
            List<ChatMessage> customerMessages = chatMessageRepository.findAll().stream()
                    .filter(m -> m.getSender() != null && m.getSender().getId().equals(customerId) && m.getReceiver() == null && !m.getIsClosed())
                    .collect(Collectors.toList());
            messagesToClose.addAll(customerMessages);
        }
        
        // Mark all messages as closed
        for (ChatMessage message : messagesToClose) {
            if (!message.getIsClosed()) {
                message.setIsClosed(true);
                message.setClosedBy(staff);
                message.setClosedAt(LocalDateTime.now());
            }
        }
        
        if (!messagesToClose.isEmpty()) {
            chatMessageRepository.saveAll(messagesToClose);
        }
    }
}

