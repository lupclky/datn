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
public class ReviewReplyDTO {
    @NotNull(message = "Review ID is required")
    private Long reviewId;
    
    @NotBlank(message = "Reply message cannot be empty")
    private String reply;
}

