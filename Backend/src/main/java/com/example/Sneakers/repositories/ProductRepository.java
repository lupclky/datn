package com.example.Sneakers.repositories;


import com.example.Sneakers.models.Product;
import com.example.Sneakers.models.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ProductRepository extends JpaRepository<Product,Long> {
    Page<Product> findAll(Pageable pageable); //Phân trang
    
    @Query("SELECT DISTINCT p FROM Product p LEFT JOIN FETCH p.productImages")
    List<Product> findAllWithImages();

    // Used for AI indexing to avoid LazyInitializationException
    @Query("SELECT DISTINCT p FROM Product p LEFT JOIN FETCH p.productFeatures pf LEFT JOIN FETCH pf.feature LEFT JOIN FETCH p.category")
    List<Product> findAllWithFeatures();

    // Used for AI indexing with all images to improve search accuracy
    // Note: Cannot fetch both productFeatures and productImages in same query (MultipleBagFetchException)
    // So we fetch features first, then load images separately when needed
    @Query("SELECT DISTINCT p FROM Product p LEFT JOIN FETCH p.productFeatures pf LEFT JOIN FETCH pf.feature LEFT JOIN FETCH p.category")
    List<Product> findAllWithFeaturesAndImages();
    
    // Load product with images only (for loading images separately)
    @Query("SELECT DISTINCT p FROM Product p LEFT JOIN FETCH p.productImages WHERE p.id = :productId")
    Optional<Product> findByIdWithImages(@Param("productId") Long productId);

    // Load single product with all relationships for async indexing
    // Note: Cannot fetch both productFeatures and productImages in same query
    // So we fetch features first, then load images separately
    @Query("SELECT DISTINCT p FROM Product p LEFT JOIN FETCH p.productFeatures pf LEFT JOIN FETCH pf.feature LEFT JOIN FETCH p.category WHERE p.id = :productId")
    Optional<Product> findByIdWithFeatures(@Param("productId") Long productId);

    boolean existsByName(String name);

    long countByQuantityGreaterThan(Long quantity);

    @Query("SELECT SUM(p.quantity) FROM Product p")
    Long sumTotalQuantity();

    @Query("SELECT DISTINCT p FROM Product p LEFT JOIN FETCH p.productImages WHERE " +
            "(:categoryId IS NULL OR :categoryId = 0 OR p.category.id = :categoryId) " +
            "AND (:keyword IS NULL OR :keyword = '' OR p.name LIKE %:keyword% OR p.description LIKE %:keyword%) " +
            "AND (:minPrice IS NULL OR p.price >= :minPrice) " +
            "AND (:maxPrice IS NULL OR p.price <= :maxPrice)")
    Page<Product> searchProducts(
            @Param("categoryId") Long categoryId,
            @Param("keyword") String keyword,
            @Param("minPrice") Long minPrice,
            @Param("maxPrice") Long maxPrice,
            Pageable pageable);
    @Query("SELECT p FROM Product p LEFT JOIN FETCH p.productImages WHERE p.id = :productId")
    Optional<Product> getDetailProduct(@Param("productId") Long productId);
    @Query("SELECT DISTINCT p FROM Product p LEFT JOIN FETCH p.productImages WHERE p.id IN :productIds")
    List<Product> findProductsByIds(@Param("productIds") List<Long> productIds);
    long count();
    @Query("SELECT DISTINCT p FROM Product p LEFT JOIN FETCH p.productImages " +
            "WHERE (:minPrice IS NULL OR p.price >= :minPrice) " +
            "AND (:maxPrice IS NULL OR p.price <= :maxPrice)")
    List<Product> getProductsByPrice(
            @Param("minPrice") Long minPrice,
            @Param("maxPrice") Long maxPrice);

    @Query("SELECT DISTINCT p FROM Product p LEFT JOIN FETCH p.productImages " +
                "WHERE (:keyword IS NULL OR :keyword = '' " +
                    "OR p.name LIKE %:keyword% OR p.description LIKE %:keyword%)")
    List<Product> getProductsByKeyword(
            @Param("keyword") String keyword);
            
    @Query("SELECT DISTINCT p FROM Product p LEFT JOIN FETCH p.productImages WHERE p.category.id = :categoryId")
    List<Product> getProductsByCategory(@Param("categoryId") Long categoryId);

    @Query("SELECT p.id FROM Product p LEFT JOIN Review r ON r.product = p " +
            "WHERE (:categoryId IS NULL OR :categoryId = 0 OR p.category.id = :categoryId) " +
            "AND (:keyword IS NULL OR :keyword = '' OR p.name LIKE %:keyword% OR p.description LIKE %:keyword%) " +
            "AND (:minPrice IS NULL OR p.price >= :minPrice) " +
            "AND (:maxPrice IS NULL OR p.price <= :maxPrice) " +
            "GROUP BY p.id " +
            "ORDER BY CASE WHEN p.quantity > 0 THEN 1 ELSE 0 END DESC, AVG(COALESCE(r.rating, 0)) DESC, p.id DESC")
    Page<Long> findProductIdsSortedByRating(
            @Param("categoryId") Long categoryId,
            @Param("keyword") String keyword,
            @Param("minPrice") Long minPrice,
            @Param("maxPrice") Long maxPrice,
            Pageable pageable);

    @Query("SELECT p.id, p.name, p.thumbnail, p.quantity, p.price, c.name " +
            "FROM Product p LEFT JOIN p.category c " +
            "ORDER BY p.quantity DESC")
    List<Object[]> findTopProductsByStock(Pageable pageable);
}
