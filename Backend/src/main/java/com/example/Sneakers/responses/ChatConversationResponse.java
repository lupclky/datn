package com.example.Sneakers.responses;

import com.example.Sneakers.models.ChatConversation;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ChatConversationResponse {
    private Long id;
    
    @JsonProperty("customer_id")
    private Long customerId;
    
    @JsonProperty("customer_name")
    private String customerName;
    
    @JsonProperty("customer_email")
    private String customerEmail;
    
    @JsonProperty("staff_id")
    private Long staffId;
    
    @JsonProperty("staff_name")
    private String staffName;
    
    @JsonProperty("guest_session_id")
    private String guestSessionId;
    
    @JsonProperty("is_closed")
    private Boolean isClosed;
    
    @JsonProperty("closed_by_id")
    private Long closedById;
    
    @JsonProperty("closed_by_name")
    private String closedByName;
    
    @JsonProperty("closed_at")
    private LocalDateTime closedAt;
    
    @JsonProperty("first_message_at")
    private LocalDateTime firstMessageAt;
    
    @JsonProperty("last_message_at")
    private LocalDateTime lastMessageAt;
    
    @JsonProperty("created_at")
    private LocalDateTime createdAt;
    
    @JsonProperty("updated_at")
    private LocalDateTime updatedAt;
    
    public static ChatConversationResponse fromChatConversation(ChatConversation conversation) {
        return ChatConversationResponse.builder()
                .id(conversation.getId())
                .customerId(conversation.getCustomer() != null ? conversation.getCustomer().getId() : null)
                .customerName(conversation.getCustomer() != null ? conversation.getCustomer().getFullName() : null)
                .customerEmail(conversation.getCustomer() != null ? conversation.getCustomer().getEmail() : null)
                .staffId(conversation.getStaff() != null ? conversation.getStaff().getId() : null)
                .staffName(conversation.getStaff() != null ? conversation.getStaff().getFullName() : null)
                .guestSessionId(conversation.getGuestSessionId())
                .isClosed(conversation.getIsClosed())
                .closedById(conversation.getClosedBy() != null ? conversation.getClosedBy().getId() : null)
                .closedByName(conversation.getClosedBy() != null ? conversation.getClosedBy().getFullName() : null)
                .closedAt(conversation.getClosedAt())
                .firstMessageAt(conversation.getFirstMessageAt())
                .lastMessageAt(conversation.getLastMessageAt())
                .createdAt(conversation.getCreatedAt())
                .updatedAt(conversation.getUpdatedAt())
                .build();
    }
}
