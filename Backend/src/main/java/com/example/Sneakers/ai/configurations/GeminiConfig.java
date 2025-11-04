package com.example.Sneakers.ai.configurations;

import dev.langchain4j.model.chat.ChatModel;
import dev.langchain4j.model.vertexai.VertexAiGeminiChatModel;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.IOException;

@Configuration
@Slf4j
@ConditionalOnProperty(name = "ai.enabled", havingValue = "true", matchIfMissing = false)
public class GeminiConfig {

    @Value("${spring.google.ai.project-id}")
    private String projectId;

    @Value("${spring.google.ai.location}")
    private String location;

    @Value("${spring.google.ai.model}")
    private String modelName;

    @Bean
    public ChatModel geminiChatModel() throws IOException {
        log.info("Initializing Gemini chat model with project: {}, location: {}, model: {}",
                projectId, location, modelName);

        try {
            return VertexAiGeminiChatModel.builder()
                    .project(projectId)
                    .location(location)
                    .modelName(modelName)
                    .build();
        } catch (Exception e) {
            log.error("Failed to initialize Gemini chat model. Please check Google Cloud credentials.", e);
            log.error("Set GOOGLE_APPLICATION_CREDENTIALS environment variable or set ai.enabled=false to disable AI features.");
            throw e;
        }
    }
}