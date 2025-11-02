package com.example.Sneakers.repositories;

import com.example.Sneakers.models.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface CategoryRepository extends JpaRepository<Category,Long>{
    boolean existsByName(String name);
    Optional<Category> findByName(String name);
}