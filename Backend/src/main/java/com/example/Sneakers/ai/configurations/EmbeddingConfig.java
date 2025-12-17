package com.example.Sneakers.ai.configurations;

import dev.langchain4j.model.embedding.EmbeddingModel;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import lombok.extern.slf4j.Slf4j;

import com.example.Sneakers.ai.services.PythonEmbeddingService;

@Configuration
@Slf4j
@ConditionalOnProperty(name = "ai.enabled", havingValue = "true", matchIfMissing = false)
public class EmbeddingConfig {

    @Bean
    public EmbeddingModel embeddingModel(PythonEmbeddingService pythonEmbeddingService) {
        return pythonEmbeddingService;
    }
}