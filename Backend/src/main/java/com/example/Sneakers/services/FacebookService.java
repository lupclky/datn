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

    @Override
    public boolean isPostPublished(String postId) {
        if (!StringUtils.hasText(postId) || !StringUtils.hasText(accessToken)) {
            return false;
        }
        
        // Use a simpler field 'created_time' which is available with basic permissions
        // Or try checking the post itself without specific fields first
        String url = String.format("https://graph.facebook.com/%s?fields=is_published&access_token=%s", postId, accessToken);
        
        try {
            ResponseEntity<String> response = restTemplate.getForEntity(url, String.class);
            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                // Use Jackson to parse JSON robustly
                com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
                com.fasterxml.jackson.databind.JsonNode root = mapper.readTree(response.getBody());
                
                if (root.has("is_published")) {
                    boolean isPublished = root.get("is_published").asBoolean();
                    return isPublished;
                }
            }
        } catch (org.springframework.web.client.HttpClientErrorException e) {
            // Parse error to check for specific Facebook errors
            String responseBody = e.getResponseBodyAsString();
            
            // Check for permission error (code 10)
            if (responseBody.contains("\"code\":10") || responseBody.contains("pages_read_engagement")) {
                // Fallback: Try a public endpoint or assume it is NOT published yet if we can't see it
                // However, if we can't read it, we shouldn't assume it's live.
                // Log a specific warning about permissions
                 System.err.println("Warning: Facebook Token lacks 'pages_read_engagement' permission. Cannot verify post status for " + postId);
            } else if (responseBody.contains("\"code\":190") || responseBody.contains("The session is invalid")) {
                System.err.println("Warning: Facebook Access Token is invalid or expired.");
            } else {
                System.err.println("Error checking FB post status for " + postId + ": " + e.getMessage());
            }
        } catch (Exception e) {
            System.err.println("Error checking FB post status for " + postId + ": " + e.getMessage());
        }
        return false;
    }
}
