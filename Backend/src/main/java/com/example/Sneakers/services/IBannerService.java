package com.example.Sneakers.services;

import com.example.Sneakers.dtos.BannerDTO;

import java.util.List;

public interface IBannerService {
    List<BannerDTO> getAllBanners();
    List<BannerDTO> getActiveBannersInDateRange();
    BannerDTO getBannerById(Long id) throws Exception;
    BannerDTO createBanner(BannerDTO bannerDTO);
    BannerDTO updateBanner(Long id, BannerDTO bannerDTO) throws Exception;
    void deleteBanner(Long id) throws Exception;
    BannerDTO toggleBannerStatus(Long id) throws Exception;
}



