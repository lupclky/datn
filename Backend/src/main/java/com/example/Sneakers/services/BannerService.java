package com.example.Sneakers.services;

import com.example.Sneakers.dtos.BannerDTO;
import com.example.Sneakers.exceptions.DataNotFoundException;
import com.example.Sneakers.models.Banner;
import com.example.Sneakers.repositories.BannerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BannerService implements IBannerService {
    private final BannerRepository bannerRepository;

    @Override
    public List<BannerDTO> getAllBanners() {
        return bannerRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public List<BannerDTO> getActiveBannersInDateRange() {
        LocalDateTime now = LocalDateTime.now();
        return bannerRepository.findByIsActiveTrueAndStartDateBeforeAndEndDateAfterOrderByDisplayOrderAsc(now, now)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public BannerDTO getBannerById(Long id) throws Exception {
        Banner banner = bannerRepository.findById(id)
                .orElseThrow(() -> new DataNotFoundException("Banner not found with id: " + id));
        return convertToDTO(banner);
    }

    @Override
    @Transactional
    public BannerDTO createBanner(BannerDTO bannerDTO) {
        Banner banner = Banner.builder()
                .title(bannerDTO.getTitle())
                .description(bannerDTO.getDescription())
                .imageUrl(bannerDTO.getImageUrl())
                .buttonText(bannerDTO.getButtonText())
                .buttonLink(bannerDTO.getButtonLink())
                .buttonStyle(bannerDTO.getButtonStyle())
                .displayOrder(bannerDTO.getDisplayOrder())
                .isActive(bannerDTO.getIsActive() != null ? bannerDTO.getIsActive() : true)
                .startDate(bannerDTO.getStartDate())
                .endDate(bannerDTO.getEndDate())
                .build();

        Banner savedBanner = bannerRepository.save(banner);
        return convertToDTO(savedBanner);
    }

    @Override
    @Transactional
    public BannerDTO updateBanner(Long id, BannerDTO bannerDTO) throws Exception {
        Banner existingBanner = bannerRepository.findById(id)
                .orElseThrow(() -> new DataNotFoundException("Banner not found with id: " + id));

        existingBanner.setTitle(bannerDTO.getTitle());
        existingBanner.setDescription(bannerDTO.getDescription());
        existingBanner.setImageUrl(bannerDTO.getImageUrl());
        existingBanner.setButtonText(bannerDTO.getButtonText());
        existingBanner.setButtonLink(bannerDTO.getButtonLink());
        existingBanner.setButtonStyle(bannerDTO.getButtonStyle());
        existingBanner.setDisplayOrder(bannerDTO.getDisplayOrder());
        if (bannerDTO.getIsActive() != null) {
            existingBanner.setIsActive(bannerDTO.getIsActive());
        }
        existingBanner.setStartDate(bannerDTO.getStartDate());
        existingBanner.setEndDate(bannerDTO.getEndDate());

        Banner updatedBanner = bannerRepository.save(existingBanner);
        return convertToDTO(updatedBanner);
    }

    @Override
    @Transactional
    public void deleteBanner(Long id) throws Exception {
        Banner banner = bannerRepository.findById(id)
                .orElseThrow(() -> new DataNotFoundException("Banner not found with id: " + id));
        bannerRepository.delete(banner);
    }

    @Override
    @Transactional
    public BannerDTO toggleBannerStatus(Long id) throws Exception {
        Banner banner = bannerRepository.findById(id)
                .orElseThrow(() -> new DataNotFoundException("Banner not found with id: " + id));
        banner.setIsActive(!banner.getIsActive());
        Banner updatedBanner = bannerRepository.save(banner);
        return convertToDTO(updatedBanner);
    }

    private BannerDTO convertToDTO(Banner banner) {
        return BannerDTO.builder()
                .id(banner.getId())
                .title(banner.getTitle())
                .description(banner.getDescription())
                .imageUrl(banner.getImageUrl())
                .buttonText(banner.getButtonText())
                .buttonLink(banner.getButtonLink())
                .buttonStyle(banner.getButtonStyle())
                .displayOrder(banner.getDisplayOrder())
                .isActive(banner.getIsActive())
                .startDate(banner.getStartDate())
                .endDate(banner.getEndDate())
                .createdAt(banner.getCreatedAt())
                .updatedAt(banner.getUpdatedAt())
                .build();
    }
}




