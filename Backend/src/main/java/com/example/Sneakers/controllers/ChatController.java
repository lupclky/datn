package com.example.Sneakers.controllers;

import com.example.Sneakers.dtos.ChatMessageDTO;
import com.example.Sneakers.exceptions.DataNotFoundException;
import com.example.Sneakers.models.ChatConversation;
import com.example.Sneakers.responses.ChatConversationResponse;
import com.example.Sneakers.responses.ChatMessageResponse;
import com.example.Sneakers.services.ChatServiceV2;
import com.example.Sneakers.services.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("${api.prefix}/chat")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ChatController {
    private final ChatServiceV2 chatService;
    private final UserService userService;

    @PostMapping("/send")
    public ResponseEntity<?> sendMessage(
            @Valid @RequestBody ChatMessageDTO chatMessageDTO,
            @RequestHeader(value = "Authorization", required = false) String token,
            @RequestHeader(value = "X-Guest-Session-Id", required = false) String guestSessionId) {
        try {
            Long senderId = null;
            
            // If token is provided, extract sender ID
            if (token != null && token.startsWith("Bearer ")) {
                try {
                    String extractedToken = token.substring(7);
                    senderId = userService.getUserDetailsFromToken(extractedToken).getId();
                    chatMessageDTO.setSenderId(senderId);
                } catch (Exception e) {
                    // If token is invalid, treat as guest user
                    senderId = null;
                }
            }
            
            // If no sender ID (guest user), use guest session ID from header
            if (senderId == null && guestSessionId != null && !guestSessionId.trim().isEmpty()) {
                chatMessageDTO.setGuestSessionId(guestSessionId);
            }
            
            ChatMessageResponse response = chatService.sendMessage(chatMessageDTO, senderId);
            return ResponseEntity.ok(response);
        } catch (DataNotFoundException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Internal server error: " + e.getMessage()));
        }
    }

    @GetMapping("/conversation/{otherUserId}")
    public ResponseEntity<?> getConversation(
            @PathVariable Long otherUserId,
            @RequestHeader("Authorization") String token) {
        try {
            String extractedToken = token.substring(7);
            Long currentUserId = userService.getUserDetailsFromToken(extractedToken).getId();
            
            System.out.println("ChatController.getConversation - otherUserId (customerId): " + otherUserId + ", currentUserId (staffId): " + currentUserId);
            
            // Check if current user is staff/admin, use different query
            com.example.Sneakers.models.User currentUser = userService.getUserDetailsFromToken(extractedToken);
            if (currentUser.getRole() != null && 
                (currentUser.getRole().getId() == 2L || currentUser.getRole().getId() == 3L)) {
                // Staff or Admin - get conversation for customer
                // otherUserId = customerId (from URL path)
                // currentUserId = staffId (from token)
                // markMessagesAsReceivedByStaff is now called inside getConversationForCustomer
                List<ChatMessageResponse> messages = chatService.getConversationForCustomer(otherUserId, currentUserId);
                return ResponseEntity.ok(messages);
            } else {
                // Regular user - get conversation between two users
                List<ChatMessageResponse> messages = chatService.getConversation(currentUserId, otherUserId);
                return ResponseEntity.ok(messages);
            }
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Internal server error: " + e.getMessage()));
        }
    }

    @GetMapping("/messages")
    public ResponseEntity<?> getMessages(@RequestHeader(value = "Authorization", required = false) String token) {
        try {
            if (token != null && token.startsWith("Bearer ")) {
                try {
                    String extractedToken = token.substring(7);
                    Long userId = userService.getUserDetailsFromToken(extractedToken).getId();
                    List<ChatMessageResponse> messages = chatService.getMessagesForUser(userId);
                    return ResponseEntity.ok(messages);
                } catch (Exception e) {
                    // If token is invalid, return public messages
                    List<ChatMessageResponse> messages = chatService.getPublicMessages();
                    return ResponseEntity.ok(messages);
                }
            } else {
                // No token, return public messages
                List<ChatMessageResponse> messages = chatService.getPublicMessages();
                return ResponseEntity.ok(messages);
            }
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Internal server error: " + e.getMessage()));
        }
    }

    @GetMapping("/unread")
    public ResponseEntity<?> getUnreadMessages(@RequestHeader("Authorization") String token) {
        try {
            String extractedToken = token.substring(7);
            Long userId = userService.getUserDetailsFromToken(extractedToken).getId();
            
            List<ChatMessageResponse> messages = chatService.getUnreadMessages(userId);
            return ResponseEntity.ok(messages);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Internal server error: " + e.getMessage()));
        }
    }

    @GetMapping("/staff/customers")
    @PreAuthorize("hasRole('ROLE_STAFF') or hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> getCustomerMessages(@RequestHeader("Authorization") String token) {
        try {
            List<ChatMessageResponse> messages = chatService.getCustomerMessages();
            return ResponseEntity.ok(messages);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Internal server error: " + e.getMessage()));
        }
    }

    @PutMapping("/read/{messageId}")
    public ResponseEntity<?> markAsRead(
            @PathVariable Long messageId,
            @RequestHeader("Authorization") String token) {
        try {
            String extractedToken = token.substring(7);
            Long userId = userService.getUserDetailsFromToken(extractedToken).getId();
            
            chatService.markAsRead(messageId, userId);
            return ResponseEntity.ok(Map.of("message", "Message marked as read"));
        } catch (DataNotFoundException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Internal server error: " + e.getMessage()));
        }
    }

    @PutMapping("/read-all")
    public ResponseEntity<?> markAllAsRead(@RequestHeader("Authorization") String token) {
        try {
            String extractedToken = token.substring(7);
            Long userId = userService.getUserDetailsFromToken(extractedToken).getId();
            
            chatService.markAllAsRead(userId);
            return ResponseEntity.ok(Map.of("message", "All messages marked as read"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Internal server error: " + e.getMessage()));
        }
    }

    @PutMapping("/close/{customerId}")
    @PreAuthorize("hasRole('ROLE_STAFF') or hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> closeConversation(
            @PathVariable Long customerId,
            @RequestHeader("Authorization") String token) {
        try {
            String extractedToken = token.substring(7);
            Long staffId = userService.getUserDetailsFromToken(extractedToken).getId();
            
            chatService.closeConversation(customerId, staffId);
            return ResponseEntity.ok(Map.of("message", "Conversation closed successfully"));
        } catch (DataNotFoundException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Internal server error: " + e.getMessage()));
        }
    }

    @PostMapping(value = "/send-file", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> sendFileMessage(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "receiverId", required = false) Long receiverId,
            @RequestParam(value = "message", required = false) String message,
            @RequestParam("messageType") String messageType,
            @RequestParam("isStaffMessage") Boolean isStaffMessage,
            @RequestHeader(value = "Authorization", required = false) String token,
            @RequestHeader(value = "X-Guest-Session-Id", required = false) String guestSessionId) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "File is empty"));
            }

            // Validate file size (max 10MB)
            if (file.getSize() > 10 * 1024 * 1024) {
                return ResponseEntity.status(HttpStatus.PAYLOAD_TOO_LARGE)
                        .body(Map.of("error", "File size exceeds maximum limit of 10MB"));
            }

            // Store file
            String fileName = storeFile(file);
            String fileUrl = "/api/v1/chat/files/" + fileName;

            Long senderId = null;
            if (token != null && token.startsWith("Bearer ")) {
                try {
                    String extractedToken = token.substring(7);
                    senderId = userService.getUserDetailsFromToken(extractedToken).getId();
                } catch (Exception e) {
                    // If token is invalid, treat as guest user
                    senderId = null;
                }
            }

            ChatMessageDTO chatMessageDTO = ChatMessageDTO.builder()
                    .senderId(senderId)
                    .guestSessionId(senderId == null && guestSessionId != null && !guestSessionId.trim().isEmpty() ? guestSessionId : null)
                    .receiverId(receiverId)
                    .message(message != null ? message : file.getOriginalFilename())
                    .messageType(messageType)
                    .isStaffMessage(isStaffMessage)
                    .build();

            ChatMessageResponse response = chatService.sendFileMessage(chatMessageDTO, senderId, fileUrl, file.getOriginalFilename());
            return ResponseEntity.ok(response);
        } catch (DataNotFoundException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (IOException e) {
            return ResponseEntity.status(500).body(Map.of("error", "Failed to store file: " + e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Internal server error: " + e.getMessage()));
        }
    }

    @GetMapping("/files/{fileName:.+}")
    public ResponseEntity<?> getFile(@PathVariable String fileName) {
        try {
            // Create uploads/chat directory if it doesn't exist
            Path uploadDir = Paths.get("uploads/chat");
            if (!Files.exists(uploadDir)) {
                Files.createDirectories(uploadDir);
            }
            
            Path filePath = uploadDir.resolve(fileName);
            if (!Files.exists(filePath)) {
                System.err.println("File not found: " + filePath.toAbsolutePath());
                return ResponseEntity.notFound().build();
            }

            org.springframework.core.io.Resource resource = new org.springframework.core.io.UrlResource(filePath.toUri());
            if (!resource.exists() || !resource.isReadable()) {
                System.err.println("File is not readable: " + filePath.toAbsolutePath());
                return ResponseEntity.notFound().build();
            }
            
            String contentType = Files.probeContentType(filePath);
            if (contentType == null) {
                // Try to determine from file extension
                String lowerFileName = fileName.toLowerCase();
                if (lowerFileName.endsWith(".png")) {
                    contentType = "image/png";
                } else if (lowerFileName.endsWith(".jpg") || lowerFileName.endsWith(".jpeg")) {
                    contentType = "image/jpeg";
                } else if (lowerFileName.endsWith(".gif")) {
                    contentType = "image/gif";
                } else if (lowerFileName.endsWith(".pdf")) {
                    contentType = "application/pdf";
                } else {
                    contentType = "application/octet-stream";
                }
            }
            
            // Encode filename for Content-Disposition header to support Unicode characters
            String encodedFileName = java.net.URLEncoder.encode(fileName, "UTF-8")
                    .replaceAll("\\+", "%20");
            
            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    .header("Content-Disposition", "inline; filename*=UTF-8''" + encodedFileName)
                    .body(resource);
        } catch (Exception e) {
            System.err.println("Error serving file: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.notFound().build();
        }
    }

    private String storeFile(MultipartFile file) throws IOException {
        String fileName = StringUtils.cleanPath(Objects.requireNonNull(file.getOriginalFilename()));
        String uniqueFileName = UUID.randomUUID().toString() + "_" + fileName;
        Path uploadDir = Paths.get("uploads/chat");
        
        if (!Files.exists(uploadDir)) {
            Files.createDirectories(uploadDir);
        }
        
        Path destination = uploadDir.resolve(uniqueFileName);
        Files.copy(file.getInputStream(), destination, StandardCopyOption.REPLACE_EXISTING);
        
        return uniqueFileName;
    }

    // ===== NEW CONVERSATION-BASED ENDPOINTS =====

    /**
     * Get all active conversations (for staff dashboard)
     */
    @GetMapping("/conversations/active")
    @PreAuthorize("hasRole('ROLE_STAFF') or hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> getAllActiveConversations() {
        try {
            List<ChatConversation> conversations = chatService.getAllActiveConversations();
            List<ChatConversationResponse> responses = conversations.stream()
                    .map(ChatConversationResponse::fromChatConversation)
                    .collect(Collectors.toList());
            return ResponseEntity.ok(responses);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Internal server error: " + e.getMessage()));
        }
    }

    /**
     * Get all conversations for a specific customer
     */
    @GetMapping("/conversations/customer/{customerId}")
    @PreAuthorize("hasRole('ROLE_STAFF') or hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> getCustomerConversations(@PathVariable Long customerId) {
        try {
            List<ChatConversation> conversations = chatService.getCustomerConversations(customerId);
            List<ChatConversationResponse> responses = conversations.stream()
                    .map(ChatConversationResponse::fromChatConversation)
                    .collect(Collectors.toList());
            return ResponseEntity.ok(responses);
        } catch (DataNotFoundException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Internal server error: " + e.getMessage()));
        }
    }

    /**
     * Get all messages in a specific conversation
     */
    @GetMapping("/conversations/{conversationId}/messages")
    public ResponseEntity<?> getConversationMessages(@PathVariable Long conversationId) {
        try {
            List<ChatMessageResponse> messages = chatService.getConversationMessages(conversationId);
            return ResponseEntity.ok(messages);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Internal server error: " + e.getMessage()));
        }
    }

    /**
     * Close a conversation by ID
     */
    @PutMapping("/conversations/{conversationId}/close")
    @PreAuthorize("hasRole('ROLE_STAFF') or hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> closeConversationById(
            @PathVariable Long conversationId,
            @RequestHeader("Authorization") String token) {
        try {
            String extractedToken = token.substring(7);
            Long staffId = userService.getUserDetailsFromToken(extractedToken).getId();
            
            chatService.closeConversation(conversationId, staffId);
            return ResponseEntity.ok(Map.of("message", "Conversation closed successfully"));
        } catch (DataNotFoundException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Internal server error: " + e.getMessage()));
        }
    }

    /**
     * Mark all messages in a conversation as read
     */
    @PutMapping("/conversations/{conversationId}/mark-read")
    public ResponseEntity<?> markConversationAsRead(
            @PathVariable Long conversationId,
            @RequestHeader("Authorization") String token) {
        try {
            String extractedToken = token.substring(7);
            Long userId = userService.getUserDetailsFromToken(extractedToken).getId();
            
            chatService.markConversationAsRead(conversationId, userId);
            return ResponseEntity.ok(Map.of("message", "Conversation marked as read"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Internal server error: " + e.getMessage()));
        }
    }

    /**
     * Get unread message count for current user
     */
    @GetMapping("/unread-count")
    public ResponseEntity<?> getUnreadCount(@RequestHeader("Authorization") String token) {
        try {
            String extractedToken = token.substring(7);
            Long userId = userService.getUserDetailsFromToken(extractedToken).getId();
            
            Long count = chatService.getUnreadCount(userId);
            return ResponseEntity.ok(Map.of("count", count));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Internal server error: " + e.getMessage()));
        }
    }

    /**
     * Customer closes their own active conversation and starts a new session
     */
    @PostMapping("/end-session")
    public ResponseEntity<?> endCustomerSession(@RequestHeader("Authorization") String token) {
        try {
            String extractedToken = token.substring(7);
            Long customerId = userService.getUserDetailsFromToken(extractedToken).getId();
            
            chatService.endCustomerSession(customerId);
            return ResponseEntity.ok(Map.of("message", "Session ended successfully. A new session will be created on your next message."));
        } catch (DataNotFoundException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Internal server error: " + e.getMessage()));
        }
    }

    /**
     * Check if customer has any active conversations or if last conversation was closed by staff
     */
    @GetMapping("/conversation-status")
    public ResponseEntity<?> getConversationStatus(@RequestHeader("Authorization") String token) {
        try {
            String extractedToken = token.substring(7);
            Long customerId = userService.getUserDetailsFromToken(extractedToken).getId();
            
            Map<String, Object> status = chatService.getCustomerConversationStatus(customerId);
            return ResponseEntity.ok(status);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Internal server error: " + e.getMessage()));
        }
    }
}

