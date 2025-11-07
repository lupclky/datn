package com.example.Sneakers.responses;

import com.example.Sneakers.models.ChatMessage;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ChatMessageResponse {
    private Long id;
    private Long senderId;
    private String senderName;
    private Long receiverId;
    private String receiverName;
    private String message;
    private String messageType;
    private Boolean isRead;
    private Boolean isStaffMessage;
    private Boolean isClosed;
    private String guestSessionId;
    private String fileUrl;
    private String fileName;
    
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime createdAt;
    
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime updatedAt;

    public static ChatMessageResponse fromChatMessage(ChatMessage chatMessage) {
        return ChatMessageResponse.builder()
                .id(chatMessage.getId())
                .senderId(chatMessage.getSender() != null ? chatMessage.getSender().getId() : null)
                .senderName(chatMessage.getSender() != null ? chatMessage.getSender().getFullName() : "Khách vãng lai")
                .receiverId(chatMessage.getReceiver() != null ? chatMessage.getReceiver().getId() : null)
                .receiverName(chatMessage.getReceiver() != null ? chatMessage.getReceiver().getFullName() : null)
                .message(chatMessage.getMessage())
                .messageType(chatMessage.getMessageType())
                .isRead(chatMessage.getIsRead())
                .isStaffMessage(chatMessage.getIsStaffMessage())
                .isClosed(chatMessage.getConversation() != null ? chatMessage.getConversation().getIsClosed() : false)
                .guestSessionId(chatMessage.getGuestSessionId())
                .fileUrl(chatMessage.getFileUrl())
                .fileName(chatMessage.getFileName())
                .createdAt(chatMessage.getCreatedAt())
                .updatedAt(chatMessage.getUpdatedAt())
                .build();
    }
}

