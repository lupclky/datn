package com.example.Sneakers.controllers;

import com.example.Sneakers.dtos.BannerDTO;
import com.example.Sneakers.responses.BannerListResponse;
import com.example.Sneakers.responses.BannerResponse;
import com.example.Sneakers.services.IBannerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("${api.prefix}/banners")
@RequiredArgsConstructor
public class BannerController {
    private static final Logger logger = LoggerFactory.getLogger(BannerController.class);
    private final IBannerService bannerService;
    
    // Centralized upload directory path
    private Path getUploadDirectory() {
        String userDir = System.getProperty("user.dir");
        Path currentDir = Paths.get(userDir).toAbsolutePath();
        
        // Check if we're in Backend directory or root
        Path uploadsInCurrent = currentDir.resolve("uploads");
        if (Files.exists(uploadsInCurrent)) {
            return uploadsInCurrent;
        }
        
        // Try Backend subdirectory
        Path backendDir = currentDir.resolve("Backend");
        if (Files.exists(backendDir)) {
            Path uploadsInBackend = backendDir.resolve("uploads");
            if (!Files.exists(uploadsInBackend)) {
                try {
                    Files.createDirectories(uploadsInBackend);
                } catch (IOException e) {
                    logger.warn("Could not create uploads in Backend directory", e);
                }
            }
            return uploadsInBackend;
        }
        
        // Fallback: create in current directory
        if (!Files.exists(uploadsInCurrent)) {
            try {
                Files.createDirectories(uploadsInCurrent);
            } catch (IOException e) {
                logger.error("Could not create uploads directory", e);
            }
        }
        return uploadsInCurrent;
    }

    /**
     * Get all banners (public endpoint)
     */
    @GetMapping("")
    public ResponseEntity<BannerListResponse> getAllBanners() {
        List<BannerDTO> banners = bannerService.getAllBanners();
        return ResponseEntity.ok(BannerListResponse.builder()
                .message("Banners retrieved successfully")
                .banners(banners)
                .total(banners.size())
                .build());
    }

    /**
     * Get active banners (public endpoint)
     */
    @GetMapping("/active")
    public ResponseEntity<BannerListResponse> getActiveBanners() {
        List<BannerDTO> banners = bannerService.getActiveBannersInDateRange();
        return ResponseEntity.ok(BannerListResponse.builder()
                .message("Active banners retrieved successfully")
                .banners(banners)
                .total(banners.size())
                .build());
    }

    /**
     * Get banner by ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<BannerResponse> getBannerById(@PathVariable Long id) throws Exception {
        BannerDTO banner = bannerService.getBannerById(id);
        return ResponseEntity.ok(BannerResponse.builder()
                .message("Banner retrieved successfully")
                .banner(banner)
                .build());
    }

    /**
     * Create new banner (admin only)
     */
    @PostMapping("")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<BannerResponse> createBanner(@Valid @RequestBody BannerDTO bannerDTO) {
        BannerDTO createdBanner = bannerService.createBanner(bannerDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(BannerResponse.builder()
                .message("Banner created successfully")
                .banner(createdBanner)
                .build());
    }

    /**
     * Update banner (admin only)
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<BannerResponse> updateBanner(
            @PathVariable Long id,
            @Valid @RequestBody BannerDTO bannerDTO) throws Exception {
        BannerDTO updatedBanner = bannerService.updateBanner(id, bannerDTO);
        return ResponseEntity.ok(BannerResponse.builder()
                .message("Banner updated successfully")
                .banner(updatedBanner)
                .build());
    }

    /**
     * Delete banner (admin only)
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<BannerResponse> deleteBanner(@PathVariable Long id) throws Exception {
        bannerService.deleteBanner(id);
        return ResponseEntity.ok(BannerResponse.builder()
                .message("Banner deleted successfully")
                .build());
    }

    /**
     * Toggle banner status (admin only)
     */
    @PatchMapping("/{id}/toggle")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<BannerResponse> toggleBannerStatus(@PathVariable Long id) throws Exception {
        BannerDTO banner = bannerService.toggleBannerStatus(id);
        return ResponseEntity.ok(BannerResponse.builder()
                .message("Banner status toggled successfully")
                .banner(banner)
                .build());
    }

    /**
     * Upload banner image (admin only)
     */
    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> uploadBannerImage(@RequestParam("file") MultipartFile file) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().body(createErrorResponse("File is empty"));
            }
            if (file.getSize() > 5 * 1024 * 1024) {
                return ResponseEntity.status(HttpStatus.PAYLOAD_TOO_LARGE)
                        .body(createErrorResponse("File size exceeds maximum limit of 5MB"));
            }
            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                return ResponseEntity.status(HttpStatus.UNSUPPORTED_MEDIA_TYPE)
                        .body(createErrorResponse("File must be an image"));
            }

            String fileName = storeFile(file);
            Map<String, String> response = new HashMap<>();
            response.put("fileName", fileName);
            response.put("message", "Upload successful");
            response.put("url", "/api/v1/banners/images/" + fileName);
            return ResponseEntity.ok(response);
        } catch (IOException e) {
            logger.error("Error uploading banner image: ", e);
            return ResponseEntity.badRequest().body(createErrorResponse("Failed to upload image: " + e.getMessage()));
        }
    }

    /**
     * Serve banner image
     */
    @GetMapping("/images/{imageName:.+}")
    public ResponseEntity<?> viewBannerImage(@PathVariable String imageName) {
        try {
            // Remove any path prefixes if present
            String cleanImageName = imageName;
            if (imageName.contains("/")) {
                cleanImageName = imageName.substring(imageName.lastIndexOf("/") + 1);
            }
            
            // Use centralized upload directory
            Path uploadDir = getUploadDirectory();
            Path imagePath = uploadDir.resolve(cleanImageName);
            
            logger.info("Loading banner image: {} from {}", cleanImageName, imagePath.toAbsolutePath());
            
            if (Files.exists(imagePath) && Files.isReadable(imagePath)) {
                UrlResource resource = new UrlResource(imagePath.toUri());
                
                // Determine content type based on file extension
                String contentType = Files.probeContentType(imagePath);
                if (contentType == null) {
                    contentType = "image/jpeg"; // default
                }
                
                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(contentType))
                        .body(resource);
            }
            
            logger.error("Banner image not found: {} at {}", cleanImageName, imagePath.toAbsolutePath());
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            logger.error("Error loading banner image: {}", imageName, e);
            return ResponseEntity.notFound().build();
        }
    }

    private String storeFile(MultipartFile file) throws IOException {
        String filename = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
        Path uploadDir = getUploadDirectory();
        Path destination = uploadDir.resolve(filename);
        logger.info("Storing banner image to: {}", destination.toAbsolutePath());
        Files.copy(file.getInputStream(), destination, StandardCopyOption.REPLACE_EXISTING);
        return filename;
    }

    private Map<String, String> createErrorResponse(String message) {
        Map<String, String> error = new HashMap<>();
        error.put("error", message);
        return error;
    }
}















