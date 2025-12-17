package com.example.Sneakers.ai.services;

import com.example.Sneakers.models.Product;
import com.example.Sneakers.models.Category;
import com.example.Sneakers.models.ProductFeature;
import com.example.Sneakers.repositories.ProductRepository;
import com.example.Sneakers.repositories.CategoryRepository;
import dev.langchain4j.data.document.Document;
import dev.langchain4j.data.document.Metadata;
import dev.langchain4j.data.embedding.Embedding;
import dev.langchain4j.data.segment.TextSegment;
import dev.langchain4j.model.embedding.EmbeddingModel;
import dev.langchain4j.store.embedding.EmbeddingSearchRequest;
import dev.langchain4j.store.embedding.EmbeddingSearchResult;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;
import java.util.stream.Collectors;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.InputStream;
import java.net.URL;
import java.io.ByteArrayOutputStream;

@Service
@RequiredArgsConstructor
@Slf4j
public class VectorSearchServiceImpl implements VectorSearchService {

    private final ChromaStoreProvider chromaStoreProvider;
    private final EmbeddingModel embeddingModel;
    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final PythonEmbeddingService pythonEmbeddingService;

    // Monitoring state
    private final AtomicBoolean isIndexing = new AtomicBoolean(false);
    private final AtomicReference<String> indexingStatus = new AtomicReference<>("Idle");
    private final AtomicInteger indexingProgress = new AtomicInteger(0);

    @Override
    public boolean isIndexing() {
        return isIndexing.get();
    }

    @Override
    public String getIndexingStatus() {
        return indexingStatus.get();
    }

    @Override
    public int getIndexingProgress() {
        return indexingProgress.get();
    }

    @Override
    @Async
    public void indexAllDataAsync() {
        if (isIndexing.getAndSet(true)) {
            log.warn("Indexing already in progress, skipping request.");
            return;
        }

        try {
            indexingProgress.set(0);
            indexingStatus.set("Starting initialization...");
            log.info("Starting async indexing of all data");

            List<Product> products = productRepository.findAllWithFeatures();
            List<Category> categories = categoryRepository.findAll();
            
            int totalItems = products.size() + categories.size();
            int processedCount = 0;

            if (totalItems == 0) {
                indexingProgress.set(100);
                indexingStatus.set("No data to index.");
                return;
            }

            // Index Products
            log.info("Indexing {} products...", products.size());
            for (Product product : products) {
                try {
                    indexingStatus.set("Indexing product: " + product.getName());
                    indexProduct(product);
                } catch (Exception e) {
                    log.error("Failed to index product: {}", product.getName(), e);
                }
                processedCount++;
                updateProgress(processedCount, totalItems);
            }

            // Index Categories
            log.info("Indexing {} categories...", categories.size());
            for (Category category : categories) {
                try {
                    indexingStatus.set("Indexing category: " + category.getName());
                    indexCategory(category);
                } catch (Exception e) {
                    log.error("Failed to index category: {}", category.getName(), e);
                }
                processedCount++;
                updateProgress(processedCount, totalItems);
            }

            log.info("Completed async indexing.");
            indexingStatus.set("Completed successfully.");
            indexingProgress.set(100);

        } catch (Exception e) {
            log.error("Async indexing failed", e);
            indexingStatus.set("Failed: " + e.getMessage());
        } finally {
            isIndexing.set(false);
        }
    }

    private void updateProgress(int current, int total) {
        if (total > 0) {
            int percent = (int) (((double) current / total) * 100);
            indexingProgress.set(percent);
        }
    }

    @Override
    @Transactional(readOnly = true)
    public void indexProduct(Product product) {
        log.debug("Indexing product: {}", product.getName());

        String content = formatProductContent(product);
        Map<String, String> metadata = createProductMetadata(product);

        try {
            Embedding embedding = embeddingModel.embed(content).content();
            TextSegment segment = TextSegment.from(content, Metadata.from(metadata));
            chromaStoreProvider.add(embedding, segment);
        } catch (Exception e) {
            log.error("Failed to embed product text: {}", product.getName(), e);
        }

        // Index Image if available
        String thumbnail = metadata.get("thumbnail");
        if (thumbnail != null && !thumbnail.isEmpty()) {
            try {
                log.debug("Indexing thumbnail for product {}: {}", product.getId(), thumbnail);
                byte[] imageBytes = readImage(thumbnail);
                if (imageBytes != null) {
                    log.debug("Read image bytes for product {} ({} bytes)", product.getId(), imageBytes.length);
                    Embedding imageEmbedding = pythonEmbeddingService.embedImage(imageBytes).content();
                    Map<String, String> imageMetadata = new HashMap<>(metadata);
                    imageMetadata.put("type", "product_image");
                    
                    // We store a dummy text segment for the image because Chroma/LangChain4j expects one
                    TextSegment imageSegment = TextSegment.from("Image of " + product.getName(), Metadata.from(imageMetadata));
                    chromaStoreProvider.add(imageEmbedding, imageSegment);
                    log.debug("Indexed image for product: {}", product.getName());
                }
            } catch (Exception e) {
                log.error("Failed to index image for product {}", product.getName(), e);
            }
        }
    }

    private byte[] readImage(String imagePath) {
        try {
            if (imagePath == null) return null;

            String normalized = imagePath.trim();
            if (normalized.isEmpty()) return null;

            // Remove query string / fragment if present (common for URLs)
            int qIndex = normalized.indexOf('?');
            if (qIndex >= 0) normalized = normalized.substring(0, qIndex);
            int hashIndex = normalized.indexOf('#');
            if (hashIndex >= 0) normalized = normalized.substring(0, hashIndex);

            // Normalize separators and strip leading slash/backslash to avoid Windows drive-root paths like "\\uploads\\..."
            normalized = normalized.replace('\\', '/');
            while (normalized.startsWith("/")) normalized = normalized.substring(1);

            // 1) If it's a URL, try downloading first; if that fails, fall back to local path probing
            if (imagePath.startsWith("http")) {
                try {
                    URL url = new URL(imagePath);
                    try (InputStream in = url.openStream();
                         ByteArrayOutputStream out = new ByteArrayOutputStream()) {
                        byte[] buffer = new byte[8192];
                        int n;
                        while ((n = in.read(buffer)) != -1) {
                            out.write(buffer, 0, n);
                        }
                        return out.toByteArray();
                    }
                } catch (Exception e) {
                    log.debug("Failed to download image URL, will try local paths: {}", imagePath);
                }
            }

            // 2) Try local file system with multiple candidate roots.
            // This handles running the app from either repo root or Backend/.
            String candidateRel = normalized;
            if (candidateRel.startsWith("uploads/")) candidateRel = candidateRel.substring("uploads/".length());
            if (candidateRel.startsWith("Image_upload/")) candidateRel = candidateRel.substring("Image_upload/".length());

            Path cwd = Paths.get("").toAbsolutePath().normalize();

            Path[] candidates = new Path[] {
                    Paths.get(normalized),
                    Paths.get("uploads").resolve(candidateRel),
                    Paths.get("Image_upload").resolve(candidateRel),
                    Paths.get("Backend").resolve(normalized),
                    Paths.get("Backend", "uploads").resolve(candidateRel),
                    Paths.get("Backend", "Image_upload").resolve(candidateRel)
            };

            for (Path candidate : candidates) {
                try {
                    if (candidate != null && Files.exists(candidate)) {
                        return Files.readAllBytes(candidate);
                    }
                } catch (Exception ignored) {
                    // continue to next candidate
                }
            }

            log.warn(
                    "Image file not found for thumbnail='{}'. CWD='{}'. Tried: {}, {}, {}, {}, {}, {}",
                    imagePath,
                    cwd,
                    candidates[0],
                    candidates[1],
                    candidates[2],
                    candidates[3],
                    candidates[4],
                    candidates[5]
            );
            return null;
        } catch (Exception e) {
            log.warn("Failed to read image: {}", imagePath, e);
            return null;
        }
    }

    @Override
    @Transactional(readOnly = true)
    public void indexAllProducts() {
        // Synchronous wrapper or deprecated
        indexAllDataAsync();
    }

    @Override
    @Transactional(readOnly = true)
    public void updateProductIndex(Product product) {
        deleteProductFromIndex(product.getId());
        indexProduct(product);
    }

    @Override
    @Async
    public void updateProductIndexAsync(Long productId) {
        try {
            // Reload product from database with all relationships to avoid detached entity issues
            Optional<Product> productOpt = productRepository.findByIdWithFeatures(productId);
            if (productOpt.isEmpty()) {
                log.warn("Product not found for indexing: {}", productId);
                return;
            }
            
            Product product = productOpt.get();
            log.info("Async indexing product: {} (ID: {})", product.getName(), productId);
            updateProductIndex(product);
            log.info("Successfully indexed product: {} (ID: {})", product.getName(), productId);
        } catch (Exception e) {
            log.error("Failed to index product asynchronously (ID: {}): {}", productId, e.getMessage(), e);
        }
    }

    @Override
    public void deleteProductFromIndex(Long productId) {
        log.info("Deleting product from index: {}", productId);
        // ChromaDB specific implementation needed for real delete
    }

    @Override
    @Transactional(readOnly = true)
    public void indexCategory(Category category) {
        log.debug("Indexing category: {}", category.getName());

        String content = String.format("Category: %s", category.getName());
        Map<String, String> metadata = new HashMap<>();
        metadata.put("type", "category");
        metadata.put("category_id", category.getId().toString());
        metadata.put("category_name", category.getName());

        Embedding embedding = embeddingModel.embed(content).content();
        TextSegment segment = TextSegment.from(content, Metadata.from(metadata));

        chromaStoreProvider.add(embedding, segment);
    }

    @Override
    @Transactional(readOnly = true)
    public void indexAllCategories() {
        // Already handled in indexAllDataAsync
    }

    @Override
    public List<Document> searchProducts(String query, int topK) {
        log.debug("Searching products with query: {}", query);

        Embedding queryEmbedding = embeddingModel.embed(query).content();

        EmbeddingSearchRequest searchRequest = new EmbeddingSearchRequest(
                queryEmbedding,
                topK,
                0.6, // minimum score
                null // no filter
        );

        EmbeddingSearchResult<TextSegment> searchResult = chromaStoreProvider.search(searchRequest);

        return searchResult.matches().stream()
                .map(match -> Document.from(match.embedded().text(), match.embedded().metadata()))
                .collect(Collectors.toList());
    }

    @Override
    public List<Document> searchProductsByCategory(String query, String categoryName, int topK) {
        log.debug("Searching products in category: {} with query: {}", categoryName, query);
        String enhancedQuery = String.format("%s in %s category", query, categoryName);
        return searchProducts(enhancedQuery, topK);
    }

    @Override
    public List<Document> searchByImage(byte[] imageBytes, int topK) {
        log.debug("Searching products by image");
        try {
            Embedding imageEmbedding = pythonEmbeddingService.embedImage(imageBytes).content();
            
            EmbeddingSearchRequest searchRequest = new EmbeddingSearchRequest(
                    imageEmbedding,
                    topK,
                    0.6,
                    null
            );
            
            EmbeddingSearchResult<TextSegment> searchResult = chromaStoreProvider.search(searchRequest);
            
            return searchResult.matches().stream()
                    .map(match -> Document.from(match.embedded().text(), match.embedded().metadata()))
                    .collect(Collectors.toList());
        } catch (Exception e) {
            log.error("Failed to search by image", e);
            return List.of();
        }
    }

    @Override
    public List<Document> searchProductsByPriceRange(String query, Long minPrice, Long maxPrice, int topK) {
        log.debug("Searching products with price range: {} - {} and query: {}", minPrice, maxPrice, query);
        // Simplified filtering
        return searchProducts(query, topK * 2).stream()
                .filter(doc -> {
                    try {
                        Map<String, Object> metadata = doc.metadata().toMap();
                        Object priceObj = metadata.get("price");
                        if (priceObj != null) {
                            Long price = Long.parseLong(priceObj.toString());
                            return price >= minPrice && price <= maxPrice;
                        }
                        return false;
                    } catch (NumberFormatException e) {
                        return false;
                    }
                })
                .limit(topK)
                .collect(Collectors.toList());
    }

    @Override
    public List<DocumentWithScore> searchProductsWithScores(String query, int topK, double minScore) {
        log.debug("Searching products with scores, query: {}, minScore: {}", query, minScore);

        Embedding queryEmbedding = embeddingModel.embed(query).content();

        EmbeddingSearchRequest searchRequest = new EmbeddingSearchRequest(
                queryEmbedding,
                topK,
                minScore,
                null);

        EmbeddingSearchResult<TextSegment> searchResult = chromaStoreProvider.search(searchRequest);

        return searchResult.matches().stream()
                .map(match -> new DocumentWithScore(
                        Document.from(match.embedded().text(), match.embedded().metadata()),
                        match.score()))
                .collect(Collectors.toList());
    }

    @Override
    public void clearAllDocuments() {
        log.warn("Clearing all documents from vector store");
        // Placeholder
    }

    @Override
    public long getDocumentCount() {
        // Placeholder
        return 0;
    }

    private String formatProductContent(Product product) {
        String productName = product.getName() != null && !product.getName().trim().isEmpty()
                ? product.getName().trim()
                : "Unknown";

        String description = product.getDescription() != null ? product.getDescription().trim() : "";
        if (description.isEmpty()) {
            description = "No description provided";
        }

        long price = product.getPrice() != null ? product.getPrice() : 0L;
        long discount = product.getDiscount() != null ? product.getDiscount() : 0L;

        StringBuilder featuresBuilder = new StringBuilder();
        if (product.getProductFeatures() != null && !product.getProductFeatures().isEmpty()) {
            for (ProductFeature pf : product.getProductFeatures()) {
                if (pf.getFeature() != null) {
                    featuresBuilder.append(pf.getFeature().getName()).append(", ");
                }
            }
        }
        
        String features = featuresBuilder.length() > 0 
            ? featuresBuilder.substring(0, featuresBuilder.length() - 2) 
            : "Standard features";

        return String.format("""
                Product: %s
                Description: %s
                Category: %s
                Price: %d VND
                Discount: %d%%
                Features: %s
                """,
            productName,
            description,
                product.getCategory() != null ? product.getCategory().getName() : "Unknown",
            price,
            discount,
                features);
    }

    private Map<String, String> createProductMetadata(Product product) {
        Map<String, String> metadata = new HashMap<>();
        metadata.put("type", "product");
        metadata.put("product_id", product.getId().toString());
        metadata.put("product_name", product.getName() != null ? product.getName() : "");
        metadata.put("price", product.getPrice() != null ? product.getPrice().toString() : "0");
        metadata.put("category_id", product.getCategory() != null ? product.getCategory().getId().toString() : "");
        metadata.put("category_name", product.getCategory() != null ? product.getCategory().getName() : "");
        metadata.put("discount", product.getDiscount() != null ? product.getDiscount().toString() : "0");
        metadata.put("thumbnail", product.getThumbnail() != null ? product.getThumbnail() : "");
        
        StringBuilder featuresBuilder = new StringBuilder();
        if (product.getProductFeatures() != null && !product.getProductFeatures().isEmpty()) {
            for (ProductFeature pf : product.getProductFeatures()) {
                if (pf.getFeature() != null) {
                    featuresBuilder.append(pf.getFeature().getName()).append(", ");
                }
            }
        }
        if (featuresBuilder.length() > 0) {
             metadata.put("features", featuresBuilder.substring(0, featuresBuilder.length() - 2));
        }

        return metadata;
    }
}
