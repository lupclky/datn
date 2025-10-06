package com.example.Sneakers.services;

import com.example.Sneakers.dtos.LockFeatureDTO;
import com.example.Sneakers.models.LockFeature;
import com.example.Sneakers.repositories.LockFeatureRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LockFeatureService {
    private final LockFeatureRepository lockFeatureRepository;

    public List<LockFeatureDTO> getAllFeatures() {
        List<LockFeature> features = lockFeatureRepository.findAll();
        return features.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<LockFeatureDTO> getActiveFeatures() {
        List<LockFeature> features = lockFeatureRepository.findByIsActiveTrue();
        return features.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public LockFeatureDTO getFeatureById(Long id) {
        LockFeature feature = lockFeatureRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Feature not found"));
        return convertToDTO(feature);
    }

    public LockFeatureDTO createFeature(LockFeatureDTO featureDTO) {
        LockFeature feature = LockFeature.builder()
                .name(featureDTO.getName())
                .description(featureDTO.getDescription())
                .isActive(featureDTO.getIsActive())
                .build();

        LockFeature savedFeature = lockFeatureRepository.save(feature);
        return convertToDTO(savedFeature);
    }

    public LockFeatureDTO updateFeature(Long id, LockFeatureDTO featureDTO) {
        LockFeature feature = lockFeatureRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Feature not found"));

        feature.setName(featureDTO.getName());
        feature.setDescription(featureDTO.getDescription());
        feature.setIsActive(featureDTO.getIsActive());

        LockFeature updatedFeature = lockFeatureRepository.save(feature);
        return convertToDTO(updatedFeature);
    }

    public void deleteFeature(Long id) {
        lockFeatureRepository.deleteById(id);
    }

    private LockFeatureDTO convertToDTO(LockFeature feature) {
        return LockFeatureDTO.builder()
                .id(feature.getId())
                .name(feature.getName())
                .description(feature.getDescription())
                .isActive(feature.getIsActive())
                .build();
    }
}

