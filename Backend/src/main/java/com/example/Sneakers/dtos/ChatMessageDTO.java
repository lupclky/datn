package com.example.Sneakers.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Data
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ChatMessageDTO {
    private Long id;
    
    private Long senderId; // NULL for guest users
    
    private String guestSessionId; // Session ID for guest users (from localStorage)
    
    private Long receiverId; // NULL for public messages
    
    @NotBlank(message = "Message cannot be empty")
    private String message;
    
    private String messageType; // TEXT, IMAGE, FILE
    
    private Boolean isRead;
    
    @NotNull(message = "isStaffMessage is required")
    private Boolean isStaffMessage;
}

