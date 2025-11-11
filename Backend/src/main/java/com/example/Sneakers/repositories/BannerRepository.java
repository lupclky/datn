package com.example.Sneakers.repositories;

import com.example.Sneakers.models.Banner;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface BannerRepository extends JpaRepository<Banner, Long> {
    List<Banner> findByIsActiveTrueAndStartDateBeforeAndEndDateAfterOrderByDisplayOrderAsc(
            LocalDateTime currentDate1, LocalDateTime currentDate2);
}





