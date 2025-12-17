package com.example.Sneakers.ai.services;

import dev.langchain4j.data.embedding.Embedding;
import dev.langchain4j.data.segment.TextSegment;
import dev.langchain4j.model.embedding.EmbeddingModel;
import dev.langchain4j.model.output.Response;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.Duration;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

@Service
@Slf4j
public class PythonEmbeddingService implements EmbeddingModel {

    private final RestTemplate restTemplate;

    @Value("${ai.embedding.base-url:http://localhost:9001}")
    private String baseUrl;

    public PythonEmbeddingService(RestTemplateBuilder restTemplateBuilder) {
        this.restTemplate = restTemplateBuilder
                .setConnectTimeout(Duration.ofSeconds(10))
                .setReadTimeout(Duration.ofSeconds(60))
                .build();
    }

    @Override
    public Response<Embedding> embed(String text) {
        return embed(TextSegment.from(text));
    }

    @Override
    public Response<Embedding> embed(TextSegment textSegment) {
        try {
            String url = baseUrl + "/embed/text";
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            TextRequest request = new TextRequest();
            request.setText(textSegment.text());

            PythonEmbeddingResponse response = restTemplate.postForObject(url, new HttpEntity<>(request, headers), PythonEmbeddingResponse.class);
            if (response == null || response.getEmbedding() == null || response.getEmbedding().isEmpty()) {
                throw new IllegalStateException("Empty embedding returned from Python service");
            }

            return Response.from(Embedding.from(toFloatList(response.getEmbedding())));
        } catch (Exception e) {
            log.error("Python text embedding failed (baseUrl={}): {}", baseUrl, e.getMessage(), e);
            throw new RuntimeException("Failed to embed text via Python service", e);
        }
    }

    @Override
    public Response<List<Embedding>> embedAll(List<TextSegment> textSegments) {
        List<Embedding> embeddings = new ArrayList<>();
        for (TextSegment segment : textSegments) {
            embeddings.add(embed(segment).content());
        }
        return Response.from(embeddings);
    }

    public Response<Embedding> embedImage(byte[] imageBytes) {
        try {
            String url = baseUrl + "/embed/image";
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            ImageRequest request = new ImageRequest();
            request.setImageBase64(Base64.getEncoder().encodeToString(imageBytes));

            PythonEmbeddingResponse response = restTemplate.postForObject(url, new HttpEntity<>(request, headers), PythonEmbeddingResponse.class);
            if (response == null || response.getEmbedding() == null || response.getEmbedding().isEmpty()) {
                throw new IllegalStateException("Empty embedding returned from Python service");
            }

            return Response.from(Embedding.from(toFloatList(response.getEmbedding())));
        } catch (Exception e) {
            log.error("Python image embedding failed (baseUrl={}): {}", baseUrl, e.getMessage(), e);
            throw new RuntimeException("Failed to embed image via Python service", e);
        }
    }

    private static List<Float> toFloatList(List<Double> doubles) {
        List<Float> floats = new ArrayList<>(doubles.size());
        for (Double d : doubles) {
            floats.add(d == null ? 0.0f : d.floatValue());
        }
        return floats;
    }

    @Data
    private static class TextRequest {
        private String text;
    }

    @Data
    private static class ImageRequest {
        @JsonProperty("image_base64")
        private String imageBase64;
    }

    @Data
    private static class PythonEmbeddingResponse {
        private List<Double> embedding;
    }
}
