package com.example.Sneakers.repositories;

import com.example.Sneakers.models.LockFeature;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LockFeatureRepository extends JpaRepository<LockFeature, Long> {
    List<LockFeature> findByIsActiveTrue();
}

