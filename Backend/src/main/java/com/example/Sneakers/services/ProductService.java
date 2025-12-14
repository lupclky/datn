package com.example.Sneakers.services;

import com.example.Sneakers.ai.listeners.ProductEventListener.ProductDeleteEvent;
import com.example.Sneakers.ai.listeners.ProductEventListener.ProductSaveEvent;
import com.example.Sneakers.dtos.ProductDTO;
import com.example.Sneakers.dtos.ProductImageDTO;
import com.example.Sneakers.exceptions.DataNotFoundException;
import com.example.Sneakers.exceptions.InvalidParamException;
import com.example.Sneakers.models.Category;
import com.example.Sneakers.models.Product;
import com.example.Sneakers.models.ProductImage;
import com.example.Sneakers.repositories.*;
import com.example.Sneakers.responses.ListProductResponse;
import com.example.Sneakers.responses.ProductResponse;
import com.example.Sneakers.services.ProductFeatureService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProductService implements IProductService {
    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final ProductImageRepository productImageRepository;
    private final ProductFeatureRepository productFeatureRepository;
    private final ProductFeatureService productFeatureService;
    private final ReviewRepository reviewRepository;
    private final OrderDetailRepository orderDetailRepository;
    private final ApplicationEventPublisher eventPublisher;

    @Override
    @Transactional
    public Product createProduct(ProductDTO productDTO) throws DataNotFoundException {
        Category existingCategory = categoryRepository.findById(productDTO.getCategoryId())
                .orElseThrow(() -> new DataNotFoundException(
                        "Cannot find category with id = " + productDTO.getCategoryId()));
        Product newProduct = Product.builder()
                .name(productDTO.getName())
                .price(productDTO.getPrice())
                .thumbnail(productDTO.getThumbnail())
                .description(productDTO.getDescription())
                .category(existingCategory)
                .discount(productDTO.getDiscount())
                .quantity(productDTO.getQuantity())
                .build();
        Product savedProduct = productRepository.save(newProduct);

        // Assign features to product if provided
        if (productDTO.getFeatureIds() != null && !productDTO.getFeatureIds().isEmpty()) {
            productFeatureService.assignFeaturesToProduct(savedProduct.getId(), productDTO.getFeatureIds());
        }

        // Publish event for indexing
        eventPublisher.publishEvent(new ProductSaveEvent(savedProduct));

        return savedProduct;
    }

    @Override
    public Product getProductById(Long productId) throws Exception {
        Optional<Product> optionalProduct = productRepository.getDetailProduct(productId);
        if (optionalProduct.isPresent()) {
            return optionalProduct.get();
        }
        throw new DataNotFoundException("Cannot find product with id =" + productId);
    }

    @Override
    public Page<ProductResponse> getAllProducts(String keyword, Long categoryId, Long minPrice, Long maxPrice, PageRequest pageRequest) {
        Page<Product> productPage;

        // Check for rating sort
        boolean isSortByRating = pageRequest.getSort().stream()
                .anyMatch(order -> order.getProperty().equals("rating"));

        if (isSortByRating) {
            // 1. Get IDs sorted by rating (paginated)
            PageRequest pageRequestForIds = PageRequest.of(pageRequest.getPageNumber(), pageRequest.getPageSize());
            
            Page<Long> productIdsPage = productRepository.findProductIdsSortedByRating(categoryId, keyword, minPrice, maxPrice, pageRequestForIds);
            
            List<Long> sortedIds = productIdsPage.getContent();
            
            if (sortedIds.isEmpty()) {
                productPage = Page.empty(pageRequest);
            } else {
                // 2. Fetch full entities
                List<Product> products = productRepository.findProductsByIds(sortedIds);
                
                // 3. Re-sort in memory
                Map<Long, Product> productMap = products.stream()
                        .collect(Collectors.toMap(Product::getId, p -> p));
                
                List<Product> sortedProducts = new ArrayList<>();
                for (Long id : sortedIds) {
                    if (productMap.containsKey(id)) {
                        sortedProducts.add(productMap.get(id));
                    }
                }
                
                productPage = new PageImpl<>(sortedProducts, pageRequest, productIdsPage.getTotalElements());
            }
        } else {
            // Search with price range support
            productPage = productRepository.searchProducts(categoryId, keyword, minPrice, maxPrice, pageRequest);
        }

        // Batch fetch ratings (rest of method remains same)
        List<Long> productIds = productPage.getContent().stream()
                .map(Product::getId)
                .collect(Collectors.toList());

        Map<Long, Object[]> ratingStatsMap = new HashMap<>();
        if (!productIds.isEmpty()) {
            ratingStatsMap = reviewRepository.getRatingStatsByProductIds(productIds)
                    .stream()
                    .collect(Collectors.toMap(
                            row -> (Long) row[0],
                            row -> new Object[]{row[1], row[2]}
                    ));
        }

        final Map<Long, Object[]> finalRatingStatsMap = ratingStatsMap;
        
        // Batch fetch sold quantities for all products in the page (reuse productIds from above)
        Map<Long, Long> soldQuantityMap = new HashMap<>();
        if (!productIds.isEmpty()) {
            List<Object[]> soldQuantityResults = orderDetailRepository.getTotalSoldQuantityByProductIds(productIds);
            soldQuantityMap = soldQuantityResults.stream()
                    .collect(Collectors.toMap(
                            row -> ((Number) row[0]).longValue(),
                            row -> ((Number) row[1]).longValue()
                    ));
        }
        
        final Map<Long, Long> finalSoldQuantityMap = soldQuantityMap;
        return productPage.map(product -> {
            ProductResponse response = ProductResponse.fromProduct(product);
            // Add rating stats from batch map
            Object[] stats = finalRatingStatsMap.get(product.getId());
            if (stats != null) {
                response.setAverageRating(stats[0] != null ? (Double) stats[0] : 0.0);
                response.setTotalReviews((Long) stats[1]);
            } else {
                response.setAverageRating(0.0);
                response.setTotalReviews(0L);
            }
            // Add sold quantity
            Long soldQuantity = finalSoldQuantityMap.getOrDefault(product.getId(), 0L);
            response.setSoldQuantity(soldQuantity);
            return response;
        });
    }

    @Override
    public List<Product> allProducts() {
        return productRepository.findAllWithImages();
    }

    @Override
    @Transactional
    public Product updateProduct(Long id, ProductDTO productDTO) throws Exception {
        Product existingProduct = getProductById(id);
        if (existingProduct != null) {
            Category existingCategory = categoryRepository.findById(productDTO.getCategoryId())
                    .orElseThrow(() -> new DataNotFoundException(
                            "Cannot find category with id = " + productDTO.getCategoryId()));
            existingProduct.setName(productDTO.getName());
            existingProduct.setCategory(existingCategory);
            existingProduct.setPrice(productDTO.getPrice());
            existingProduct.setDescription(productDTO.getDescription());
            if (productDTO.getThumbnail() != null) {
                existingProduct.setThumbnail(productDTO.getThumbnail());
            }
            existingProduct.setDiscount(productDTO.getDiscount());
            // Handle quantity: if addQuantity is true, add to existing; otherwise replace
            if (productDTO.getAddQuantity() != null && productDTO.getAddQuantity()) {
                // Add quantity to existing quantity
                Long currentQuantity = existingProduct.getQuantity() != null ? existingProduct.getQuantity() : 0L;
                Long quantityToAdd = productDTO.getQuantity() != null ? productDTO.getQuantity() : 0L;
                Long newQuantity = currentQuantity + quantityToAdd;
                // Ensure quantity doesn't go below 0
                if (newQuantity < 0) {
                    throw new InvalidParamException("Số lượng sau khi cộng không được nhỏ hơn 0. Số lượng hiện tại: " + currentQuantity + ", số lượng cộng thêm: " + quantityToAdd);
                }
                existingProduct.setQuantity(newQuantity);
            } else {
                // Replace quantity with new value
                existingProduct.setQuantity(productDTO.getQuantity());
            }
            Product updatedProduct = productRepository.save(existingProduct);

            // Update features if provided
            if (productDTO.getFeatureIds() != null) {
                productFeatureService.assignFeaturesToProduct(updatedProduct.getId(), productDTO.getFeatureIds());
            }

            // Publish event for re-indexing
            eventPublisher.publishEvent(new ProductSaveEvent(updatedProduct));

            return updatedProduct;
        }
        return null;
    }

    @Override
    @Transactional
    public void deleteProduct(Long id) {
        Optional<Product> optionalProduct = productRepository.findById(id);
        if (optionalProduct.isPresent()) {
            productRepository.delete(optionalProduct.get());
            // Publish event for removing from index
            eventPublisher.publishEvent(new ProductDeleteEvent(id));
        }
    }

    @Override
    public boolean existsByName(String name) {
        return productRepository.existsByName(name);
    }

    @Override
    @Transactional
    public ProductImage createProductImage(Long productId, ProductImageDTO productImageDTO) throws Exception {
        Product existingProduct = productRepository.findById(productId)
                .orElseThrow(() -> new DataNotFoundException(
                        "Cannot find category with id = " + productImageDTO.getProductId()));
        ProductImage newProductImage = ProductImage.builder()
                .product(existingProduct)
                .imageUrl(productImageDTO.getImageUrl())
                .build();
        // Không cho insert quá 5 ảnh cho 1 sản phẩm
        int size = productImageRepository.findByProductId(productId).size();
        if (size >= ProductImage.MAXIMUM_IMAGES_PER_PRODUCT) {
            throw new InvalidParamException("Number of images must be <= "
                    + ProductImage.MAXIMUM_IMAGES_PER_PRODUCT);
        }
        return productImageRepository.save(newProductImage);
    }

    @Override
    public List<Product> findProductsByIds(List<Long> productIds) {
        return productRepository.findProductsByIds(productIds);
    }

    @Override
    public long totalProducts() {
        return productRepository.count();
    }

    // Helper method to set sold quantity for a product response
    private void setSoldQuantityForResponse(ProductResponse response, Long productId) {
        Long soldQuantity = orderDetailRepository.getTotalSoldQuantityByProductId(productId);
        response.setSoldQuantity(soldQuantity != null ? soldQuantity : 0L);
    }

    // Helper method to set sold quantity for multiple product responses (batch)
    private void setSoldQuantityForResponses(List<ProductResponse> responses, List<Product> products) {
        if (responses.isEmpty() || products.isEmpty()) return;
        
        List<Long> productIds = products.stream()
                .map(Product::getId)
                .collect(Collectors.toList());
        
        List<Object[]> soldQuantityResults = orderDetailRepository.getTotalSoldQuantityByProductIds(productIds);
        Map<Long, Long> soldQuantityMap = soldQuantityResults.stream()
                .collect(Collectors.toMap(
                        row -> ((Number) row[0]).longValue(),
                        row -> ((Number) row[1]).longValue()
                ));
        
        for (int i = 0; i < responses.size(); i++) {
            Long productId = products.get(i).getId();
            Long soldQuantity = soldQuantityMap.getOrDefault(productId, 0L);
            responses.get(i).setSoldQuantity(soldQuantity);
        }
    }

    @Override
    public ListProductResponse getProductsByPrice(Long minPrice, Long maxPrice) {
        List<ProductResponse> productResponses = new ArrayList<>();
        List<Product> products = productRepository.getProductsByPrice(minPrice, maxPrice);
        for (Product product : products) {
            ProductResponse response = ProductResponse.fromProduct(product);
            Double avgRating = reviewRepository.getAverageRatingByProductId(product.getId());
            Long totalReviews = reviewRepository.countByProductId(product.getId());
            response.setAverageRating(avgRating != null ? avgRating : 0.0);
            response.setTotalReviews(totalReviews);
            productResponses.add(response);
        }
        setSoldQuantityForResponses(productResponses, products);
        return ListProductResponse.builder()
                .products(productResponses)
                .totalProducts(productResponses.size())
                .build();
    }

    @Override
    public ListProductResponse getProductsByKeyword(String keyword) {
        List<ProductResponse> productResponses = new ArrayList<>();
        List<Product> products = productRepository.getProductsByKeyword(keyword);
        for (Product product : products) {
            ProductResponse response = ProductResponse.fromProduct(product);
            Double avgRating = reviewRepository.getAverageRatingByProductId(product.getId());
            Long totalReviews = reviewRepository.countByProductId(product.getId());
            response.setAverageRating(avgRating != null ? avgRating : 0.0);
            response.setTotalReviews(totalReviews);
            productResponses.add(response);
        }
        setSoldQuantityForResponses(productResponses, products);
        return ListProductResponse.builder()
                .products(productResponses)
                .totalProducts(productResponses.size())
                .build();
    }

    @Override
    public ListProductResponse getProductsByCategory(Long categoryId) {
        List<ProductResponse> productResponses = new ArrayList<>();
        List<Product> products = productRepository.getProductsByCategory(categoryId);
        for (Product product : products) {
            ProductResponse response = ProductResponse.fromProduct(product);
            Double avgRating = reviewRepository.getAverageRatingByProductId(product.getId());
            Long totalReviews = reviewRepository.countByProductId(product.getId());
            response.setAverageRating(avgRating != null ? avgRating : 0.0);
            response.setTotalReviews(totalReviews);
            productResponses.add(response);
        }
        setSoldQuantityForResponses(productResponses, products);
        return ListProductResponse.builder()
                .products(productResponses)
                .totalProducts(productResponses.size())
                .build();
    }

    @Override
    public ListProductResponse getRelatedProducts(Long productId) throws Exception {
        Optional<Product> optionalProduct = productRepository.findById(productId);
        List<ProductResponse> productResponses = new ArrayList<>();
        if (optionalProduct.isEmpty()) {
            throw new Exception("Cannot find product with id = " + productId);
        }

        Product targetProduct = optionalProduct.get();
        if (targetProduct.getCategory() == null) {
            // If product has no category, return empty list
            return ListProductResponse.builder()
                    .products(productResponses)
                    .totalProducts(0)
                    .build();
        }

        List<Product> products = productRepository.getProductsByCategory(
                targetProduct.getCategory().getId());
        List<Product> filteredProducts = new ArrayList<>();
        int cnt = 0;
        for (Product p : products) {
            if (!Objects.equals(p.getId(), productId)) {
                ProductResponse response = ProductResponse.fromProduct(p);
                Double avgRating = reviewRepository.getAverageRatingByProductId(p.getId());
                Long totalReviews = reviewRepository.countByProductId(p.getId());
                response.setAverageRating(avgRating != null ? avgRating : 0.0);
                response.setTotalReviews(totalReviews);
                productResponses.add(response);
                filteredProducts.add(p);
                cnt++;
            }
            if (cnt == 4)
                break;
        }
        setSoldQuantityForResponses(productResponses, filteredProducts);
        return ListProductResponse.builder()
                .products(productResponses)
                .totalProducts(productResponses.size())
                .build();
    }

    @Override
    @Transactional
    public void updateProductThumbnail(Long productId, String thumbnailUrl) throws Exception {
        Product existingProduct = getProductById(productId);
        existingProduct.setThumbnail(thumbnailUrl);
        productRepository.save(existingProduct);
    }

    @Override
    @Transactional
    public void deleteProductImage(Long id) throws Exception {
        Optional<ProductImage> productImageOptional = productImageRepository.findById(id);
        if (productImageOptional.isPresent()) {
            ProductImage productImage = productImageOptional.get();
            // Ensure the image belongs to a product to avoid unintended deletions
            if (productImage.getProduct() != null) {
                productImageRepository.deleteById(id);
                // Future enhancement: Add logic here to delete the actual file from storage
            } else {
                throw new DataNotFoundException("Image with id " + id + " is not associated with any product.");
            }
        } else {
            throw new DataNotFoundException("Cannot find product image with id: " + id);
        }
    }
}