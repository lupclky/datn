package com.example.Sneakers.ai.services;

import com.example.Sneakers.models.Product;
import com.example.Sneakers.models.Category;
import dev.langchain4j.data.document.Document;
import org.springframework.scheduling.annotation.Async;
import java.util.List;
import java.util.Map;

public interface VectorSearchService {

    // Monitoring methods
    boolean isIndexing();
    String getIndexingStatus();
    int getIndexingProgress(); // 0-100
    
    // Main Async Method
    void indexAllDataAsync();

    // Product indexing methods
    void indexProduct(Product product);

    void indexAllProducts();

    void updateProductIndex(Product product);

    @Async
    void updateProductIndexAsync(Long productId);

    void deleteProductFromIndex(Long productId);

    // Category indexing methods
    void indexCategory(Category category);

    void indexAllCategories();

    // Search methods
    List<Document> searchProducts(String query, int topK);

    List<Document> searchProductsByCategory(String query, String categoryName, int topK);

    List<Document> searchProductsByPriceRange(String query, Long minPrice, Long maxPrice, int topK);

    List<Document> searchByImage(byte[] imageBytes, int topK);

    // Advanced search with scores
    List<DocumentWithScore> searchProductsWithScores(String query, int topK, double minScore);

    // Utility methods
    void clearAllDocuments();

    long getDocumentCount();

    // Helper class for search results with scores
    class DocumentWithScore {
        private final Document document;
        private final double score;

        public DocumentWithScore(Document document, double score) {
            this.document = document;
            this.score = score;
        }

        public Document getDocument() {
            return document;
        }

        public double getScore() {
            return score;
        }

        public String getText() {
            return document.text();
        }

        public Map<String, Object> getMetadata() {
            return document.metadata().toMap();
        }
    }
}
