package com.example.Sneakers.responses;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class LoginResponse {
    @JsonProperty("message")
    private String message;

    @JsonProperty("token")
    private String token;

    @JsonProperty("is_new_user")
    private Boolean isNewUser;

    @JsonProperty("google_email")
    private String googleEmail;

    @JsonProperty("google_name")
    private String googleName;
}