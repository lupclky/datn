package com.example.Sneakers.ai.services;

import com.example.Sneakers.models.Product;
import com.example.Sneakers.models.Category;
import com.example.Sneakers.models.ProductFeature;
import com.example.Sneakers.models.ProductImage;
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

            // Load products with both features and images for better indexing
            List<Product> products = productRepository.findAllWithFeaturesAndImages();
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
            
            // Load all product IDs first
            List<Long> productIds = products.stream()
                    .map(Product::getId)
                    .collect(Collectors.toList());
            
            // Batch load all images for all products to avoid N+1 queries
            Map<Long, List<ProductImage>> imagesMap = new HashMap<>();
            if (!productIds.isEmpty()) {
                List<Product> productsWithImages = productRepository.findProductsByIds(productIds);
                for (Product p : productsWithImages) {
                    if (p.getProductImages() != null) {
                        imagesMap.put(p.getId(), p.getProductImages());
                    }
                }
            }
            
            // Index each product with its images
            for (Product product : products) {
                try {
                    indexingStatus.set("Indexing product: " + product.getName());
                    // Set images from the map
                    List<ProductImage> images = imagesMap.get(product.getId());
                    if (images != null) {
                        product.setProductImages(images);
                    }
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

        // Index all product images for better search accuracy
        // Index thumbnail first (if available)
        String thumbnail = metadata.get("thumbnail");
        if (thumbnail != null && !thumbnail.isEmpty()) {
            indexSingleImage(product, thumbnail, metadata, 0, true);
        }
        
        // Index all product images from productImages list
        if (product.getProductImages() != null && !product.getProductImages().isEmpty()) {
            log.debug("Indexing {} images for product {}: {}", product.getProductImages().size(), product.getId(), product.getName());
            int imageIndex = 1; // Start from 1, 0 is for thumbnail
            
            for (var productImage : product.getProductImages()) {
                if (productImage.getImageUrl() != null && !productImage.getImageUrl().isEmpty()) {
                    // Skip if this is the same as thumbnail to avoid duplicate
                    if (!productImage.getImageUrl().equals(thumbnail)) {
                        indexSingleImage(product, productImage.getImageUrl(), metadata, imageIndex, false);
                        imageIndex++;
                    }
                }
            }
            
            log.debug("Indexed {} images for product: {}", imageIndex, product.getName());
        }
    }
    
    /**
     * Index a single image for a product
     * @param product The product
     * @param imageUrl The image URL/path
     * @param baseMetadata Base metadata from product
     * @param imageIndex Index of the image (0 for thumbnail, 1+ for productImages)
     * @param isThumbnail Whether this is the thumbnail image
     */
    private void indexSingleImage(Product product, String imageUrl, Map<String, String> baseMetadata, int imageIndex, boolean isThumbnail) {
        try {
            log.debug("Indexing image {} for product {}: {}", isThumbnail ? "thumbnail" : "#" + imageIndex, product.getId(), imageUrl);
            byte[] imageBytes = readImage(imageUrl);
            if (imageBytes != null) {
                log.debug("Read image bytes for product {} ({} bytes)", product.getId(), imageBytes.length);
                Embedding imageEmbedding = pythonEmbeddingService.embedImage(imageBytes).content();
                Map<String, String> imageMetadata = new HashMap<>(baseMetadata);
                imageMetadata.put("type", "product_image");
                imageMetadata.put("image_index", String.valueOf(imageIndex));
                imageMetadata.put("image_url", imageUrl);
                imageMetadata.put("is_thumbnail", String.valueOf(isThumbnail));
                
                // We store a descriptive text segment for the image
                String imageDescription = isThumbnail 
                    ? "Thumbnail image of " + product.getName()
                    : "Product image #" + imageIndex + " of " + product.getName();
                TextSegment imageSegment = TextSegment.from(imageDescription, Metadata.from(imageMetadata));
                chromaStoreProvider.add(imageEmbedding, imageSegment);
                log.debug("Indexed {} for product: {}", isThumbnail ? "thumbnail" : "image #" + imageIndex, product.getName());
            } else {
                log.warn("Could not read image bytes for product {}: {}", product.getId(), imageUrl);
            }
        } catch (Exception e) {
            log.error("Failed to index image {} for product {}: {}", imageUrl, product.getName(), e.getMessage());
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
            // Reload product from database with features to avoid detached entity issues
            Optional<Product> productOpt = productRepository.findByIdWithFeatures(productId);
            if (productOpt.isEmpty()) {
                log.warn("Product not found for indexing: {}", productId);
                return;
            }
            
            Product product = productOpt.get();
            
            // Load images separately to avoid MultipleBagFetchException
            Optional<Product> productWithImages = productRepository.findByIdWithImages(productId);
            if (productWithImages.isPresent()) {
                product.setProductImages(productWithImages.get().getProductImages());
            }
            
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

        // Giảm minimum score từ 0.6 xuống 0.4 để tìm được nhiều sản phẩm hơn
        // Đặc biệt với tên model ngắn như "F300-FH"
        EmbeddingSearchRequest searchRequest = new EmbeddingSearchRequest(
                queryEmbedding,
                topK,
                0.4, // minimum score - giảm từ 0.6 để tìm được sản phẩm có tên model ngắn
                null // no filter
        );

        EmbeddingSearchResult<TextSegment> searchResult = chromaStoreProvider.search(searchRequest);
        
        // Filter để loại bỏ duplicates theo product_id
        Map<Long, Document> uniqueProducts = new HashMap<>();
        Map<Long, Double> productScores = new HashMap<>();
        
        for (var match : searchResult.matches()) {
            Map<String, Object> metadata = match.embedded().metadata().toMap();
            Object productIdObj = metadata.get("product_id");
            
            if (productIdObj != null) {
                try {
                    Long productId = Long.parseLong(productIdObj.toString());
                    double score = match.score();
                    
                    // Chỉ giữ document có score cao nhất cho mỗi product
                    if (!productScores.containsKey(productId) || score > productScores.get(productId)) {
                        productScores.put(productId, score);
                        uniqueProducts.put(productId, Document.from(
                            match.embedded().text(), 
                            match.embedded().metadata()
                        ));
                    }
                } catch (NumberFormatException e) {
                    log.warn("Invalid product_id in metadata: {}", productIdObj);
                }
            }
        }
        
        // Sắp xếp theo score và lấy topK
        List<Document> results = uniqueProducts.entrySet().stream()
                .sorted((e1, e2) -> Double.compare(
                    productScores.get(e2.getKey()), 
                    productScores.get(e1.getKey())
                ))
                .limit(topK)
                .map(Map.Entry::getValue)
                .collect(Collectors.toList());
        
        // Nếu không tìm thấy kết quả, thử tìm với minimum score thấp hơn nữa
        if (results.isEmpty()) {
            log.debug("No results with minScore 0.4, trying with minScore 0.3");
            EmbeddingSearchRequest fallbackRequest = new EmbeddingSearchRequest(
                    queryEmbedding,
                    topK * 3, // Lấy nhiều hơn để có đủ sau khi filter
                    0.3, // minimum score thấp hơn nữa
                    null
            );
            EmbeddingSearchResult<TextSegment> fallbackResult = chromaStoreProvider.search(fallbackRequest);
            
            // Filter duplicates cho fallback results
            uniqueProducts.clear();
            productScores.clear();
            
            for (var match : fallbackResult.matches()) {
                Map<String, Object> metadata = match.embedded().metadata().toMap();
                Object productIdObj = metadata.get("product_id");
                
                if (productIdObj != null) {
                    try {
                        Long productId = Long.parseLong(productIdObj.toString());
                        double score = match.score();
                        
                        if (!productScores.containsKey(productId) || score > productScores.get(productId)) {
                            productScores.put(productId, score);
                            uniqueProducts.put(productId, Document.from(
                                match.embedded().text(), 
                                match.embedded().metadata()
                            ));
                        }
                    } catch (NumberFormatException e) {
                        log.warn("Invalid product_id in metadata: {}", productIdObj);
                    }
                }
            }
            
            results = uniqueProducts.entrySet().stream()
                    .sorted((e1, e2) -> Double.compare(
                        productScores.get(e2.getKey()), 
                        productScores.get(e1.getKey())
                    ))
                    .limit(topK)
                    .map(Map.Entry::getValue)
                    .collect(Collectors.toList());
        }
        
        log.debug("Found {} unique products from {} matches", results.size(), searchResult.matches().size());
        return results;
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
            
            // Tăng topK lên để có đủ kết quả sau khi filter duplicates
            EmbeddingSearchRequest searchRequest = new EmbeddingSearchRequest(
                    imageEmbedding,
                    topK * 3, // Lấy nhiều hơn để có đủ sau khi filter
                    0.52, // Minimum score 0.52 (48% similarity) để bao gồm F300-FH và các sản phẩm tương tự
                    null
            );
            
            EmbeddingSearchResult<TextSegment> searchResult = chromaStoreProvider.search(searchRequest);
            
            // Filter để loại bỏ duplicates theo product_id
            // Chỉ giữ document có score cao nhất cho mỗi product_id
            Map<Long, Document> uniqueProducts = new HashMap<>();
            Map<Long, Double> productScores = new HashMap<>();
            
            for (var match : searchResult.matches()) {
                Map<String, Object> metadata = match.embedded().metadata().toMap();
                Object productIdObj = metadata.get("product_id");
                
                if (productIdObj != null) {
                    try {
                        Long productId = Long.parseLong(productIdObj.toString());
                        double score = match.score();
                        
                        // Chỉ giữ document có score cao nhất cho mỗi product
                        if (!productScores.containsKey(productId) || score > productScores.get(productId)) {
                            productScores.put(productId, score);
                            uniqueProducts.put(productId, Document.from(
                                match.embedded().text(), 
                                match.embedded().metadata()
                            ));
                        }
                    } catch (NumberFormatException e) {
                        log.warn("Invalid product_id in metadata: {}", productIdObj);
                    }
                }
            }
            
            // Sắp xếp theo score và lấy topK
            List<Document> results = uniqueProducts.entrySet().stream()
                    .sorted((e1, e2) -> Double.compare(
                        productScores.get(e2.getKey()), 
                        productScores.get(e1.getKey())
                    ))
                    .limit(topK)
                    .map(Map.Entry::getValue)
                    .collect(Collectors.toList());
            
            log.debug("Found {} unique products from {} matches", results.size(), searchResult.matches().size());
            return results;
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
