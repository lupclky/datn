package com.example.Sneakers.repositories;

import com.example.Sneakers.models.ProductFeature;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ProductFeatureRepository extends JpaRepository<ProductFeature, Long> {
    List<ProductFeature> findByProductId(Long productId);

    List<ProductFeature> findByFeatureId(Long featureId);

    void deleteByProductId(Long productId);

    @Query("SELECT pf FROM ProductFeature pf JOIN FETCH pf.feature WHERE pf.product.id = :productId")
    List<ProductFeature> findByProductIdWithFeature(@Param("productId") Long productId);

    @Query("SELECT pf FROM ProductFeature pf WHERE pf.product.id = :productId AND pf.feature.id = :featureId")
    Optional<ProductFeature> findByProductIdAndFeatureId(@Param("productId") Long productId, @Param("featureId") Long featureId);
}

