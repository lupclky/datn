package com.example.Sneakers.controllers;

import com.example.Sneakers.services.GhnService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("${api.prefix}/ghn")
@RequiredArgsConstructor
public class GhnController {
    private final GhnService ghnService;

    @GetMapping("/provinces")
    public ResponseEntity<?> getProvinces() {
        try {
            List<Map<String, Object>> provinces = ghnService.getProvinces();
            return ResponseEntity.ok(provinces);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping("/districts")
    public ResponseEntity<?> getDistricts(@RequestParam("province_id") int provinceId) {
        try {
            List<Map<String, Object>> districts = ghnService.getDistricts(provinceId);
            return ResponseEntity.ok(districts);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping("/wards")
    public ResponseEntity<?> getWards(@RequestParam("district_id") int districtId) {
        try {
            List<Map<String, Object>> wards = ghnService.getWards(districtId);
            return ResponseEntity.ok(wards);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}











