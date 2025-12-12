package com.example.Sneakers.services;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class FacebookService implements IFacebookService {

    @Value("${facebook.page-id}")
    private String pageId;

    @Value("${facebook.access-token}")
    private String accessToken;

    private final RestTemplate restTemplate;

    @Override
    public String postToPage(String message, String link, Long scheduledTime) {
        if (!StringUtils.hasText(pageId) || !StringUtils.hasText(accessToken)) {
            throw new RuntimeException("Facebook configuration is missing");
        }

        String url = String.format("https://graph.facebook.com/%s/feed", pageId);
        
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        MultiValueMap<String, String> map = new LinkedMultiValueMap<>();
        map.add("message", message);
        map.add("access_token", accessToken);
        
        if (StringUtils.hasText(link)) {
            map.add("link", link);
        }

        // Handle Scheduling
        if (scheduledTime != null) {
            // Validate time (Facebook requires scheduled time to be between 10 mins and 6 months from now)
            long now = System.currentTimeMillis() / 1000;
            if (scheduledTime < now + 600) {
                 throw new RuntimeException("Scheduled time must be at least 10 minutes in the future");
            }

            map.add("published", "false");
            map.add("scheduled_publish_time", String.valueOf(scheduledTime));
        }

        HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(map, headers);
        
        ResponseEntity<String> response = restTemplate.postForEntity(url, request, String.class);
        
        if (response.getStatusCode().is2xxSuccessful()) {
            return response.getBody();
        } else {
            throw new RuntimeException("Failed to post to Facebook: " + response.getBody());
        }
    }
}
