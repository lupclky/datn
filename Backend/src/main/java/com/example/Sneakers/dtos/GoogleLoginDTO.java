package com.example.Sneakers.dtos;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Data
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class GoogleLoginDTO {
    @NotBlank(message = "Google ID token is required")
    @JsonProperty("id_token")
    private String idToken;
}







