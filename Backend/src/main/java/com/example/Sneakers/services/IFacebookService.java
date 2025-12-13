package com.example.Sneakers.services;

public interface IFacebookService {
    String postToPage(String message, String link, Long scheduledTime);
    boolean isPostPublished(String postId);
}
