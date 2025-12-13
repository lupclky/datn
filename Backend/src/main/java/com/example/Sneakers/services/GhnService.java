package com.example.Sneakers.services;

import com.example.Sneakers.models.Order;
import com.example.Sneakers.models.OrderDetail;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class GhnService {

    private final RestTemplate restTemplate;

    @Value("${ghn.api.token}")
    private String ghnToken;

    @Value("${ghn.api.shop-id}")
    private String shopId;

    @Value("${ghn.api.url}")
    private String ghnUrl;

    @Value("${ghn.api.from-district-id:1454}")
    private int fromDistrictId;

    @Value("${ghn.api.from-ward-code:}")
    private String fromWardCode;

    // Get Available Services
    public Integer getAvailableServiceId(int fromDistrict, int toDistrict) {
        String url = "https://dev-online-gateway.ghn.vn/shiip/public-api/v2/shipping-order/available-services";
        HttpHeaders headers = new HttpHeaders();
        headers.set("token", ghnToken);
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> body = new HashMap<>();
        body.put("shop_id", Integer.parseInt(shopId));
        body.put("from_district", fromDistrict); // Configurable or hardcoded shop district
        body.put("to_district", toDistrict);

        HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);

        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(url, request, Map.class);
            if (response.getStatusCode() == HttpStatus.OK) {
                Map<String, Object> responseBody = (Map<String, Object>) response.getBody();
                if (responseBody != null && (int) responseBody.get("code") == 200) {
                    List<Map<String, Object>> data = (List<Map<String, Object>>) responseBody.get("data");
                    if (data != null && !data.isEmpty()) {
                        // Prefer "Chuan" (Standard) or take the first one
                        for (Map<String, Object> service : data) {
                            Object shortName = service.get("short_name");
                            if (shortName != null && (shortName.toString().contains("Chuẩn") || 
                                shortName.toString().contains("Standard"))) {
                                return (Integer) service.get("service_type_id");
                            }
                        }
                        return (Integer) data.get(0).get("service_type_id");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 2; // Default fallback to Standard
    }

    public String createOrder(Order order, Integer toDistrictId, String toWardCode, Integer length, Integer width, Integer height, Integer weight) throws Exception {
        HttpHeaders headers = new HttpHeaders();
        headers.set("token", ghnToken);
        headers.set("ShopId", shopId);
        headers.setContentType(MediaType.APPLICATION_JSON);

        // Get dynamic service ID
        // int fromDistrictId = 1454; // Use configured value
        int serviceTypeId = getAvailableServiceId(fromDistrictId, toDistrictId);

        Map<String, Object> body = new HashMap<>();
        try {
            body.put("shop_id", Integer.parseInt(shopId));
        } catch (NumberFormatException e) {
            // ignore or handle if shopId is not int
        }
        body.put("payment_type_id", 1); // 1: Bên gửi trả phí, 2: Bên nhận trả phí
        body.put("note", order.getNote() != null ? order.getNote() : "Cho xem hàng không cho thử");
        body.put("required_note", "KHONGCHOXEMHANG"); // Tùy chọn
        body.put("from_name", "Locker Korea");
        body.put("from_phone", "0909090909"); // Hardcode or config
        body.put("from_address", "Hồ Chí Minh"); // Hardcode or config
        if (fromWardCode != null && !fromWardCode.isEmpty()) {
            body.put("from_ward_code", fromWardCode);
        }
        body.put("from_district_id", fromDistrictId);
        // client_phone is often required if from_phone is not enough to identify sender profile
        body.put("client_phone", "0909090909"); 
        
        body.put("to_name", order.getFullName());
        body.put("to_phone", order.getPhoneNumber());
        body.put("to_address", order.getAddress());
        body.put("to_ward_code", toWardCode != null ? toWardCode.trim() : null);
        body.put("to_district_id", toDistrictId);
        
        // Determine COD amount based on payment method
        int codAmount = 0;
        if ("Cash".equalsIgnoreCase(order.getPaymentMethod())) {
            codAmount = order.getTotalMoney().intValue();
        }
        body.put("cod_amount", codAmount);
        
        // Items
        List<Map<String, Object>> items = new ArrayList<>();
        for (OrderDetail detail : order.getOrderDetails()) {
            Map<String, Object> item = new HashMap<>();
            item.put("name", detail.getProduct().getName());
            item.put("code", detail.getProduct().getId().toString());
            item.put("quantity", detail.getNumberOfProducts().intValue());
            item.put("price", detail.getPrice().intValue());
            item.put("weight", 200); // Default weight per item
            items.add(item);
        }
        body.put("items", items);

        // Package params (required)
        body.put("weight", weight != null ? weight : 200 * items.size());
        body.put("length", length != null ? length : 20);
        body.put("width", width != null ? width : 20);
        body.put("height", height != null ? height : 10);
        body.put("service_type_id", serviceTypeId); // Dynamic service ID

        HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);
        
        System.out.println("GHN Request Body: " + body);

        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(ghnUrl, request, Map.class);
            if (response.getStatusCode() == HttpStatus.OK) {
                Map<String, Object> responseBody = (Map<String, Object>) response.getBody();
                if (responseBody != null && (int) responseBody.get("code") == 200) {
                    Map<String, Object> data = (Map<String, Object>) responseBody.get("data");
                    return (String) data.get("order_code");
                } else {
                    System.err.println("GHN Error Response: " + responseBody);
                    throw new Exception("GHN Error: " + (responseBody != null ? responseBody.get("message_display_client") : "Unknown error"));
                }
            } else {
                throw new Exception("GHN HTTP Error: " + response.getStatusCode());
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new Exception("Failed to create GHN order: " + e.getMessage());
        }
    }
    
    // Method to get tracking info
    public Map<String, Object> getOrderInfo(String orderCode) throws Exception {
         // Endpoint: https://dev-online-gateway.ghn.vn/shiip/public-api/v2/shipping-order/detail
         String url = "https://dev-online-gateway.ghn.vn/shiip/public-api/v2/shipping-order/detail";
         
         HttpHeaders headers = new HttpHeaders();
         headers.set("token", ghnToken);
         headers.setContentType(MediaType.APPLICATION_JSON);
         
         Map<String, Object> body = new HashMap<>();
         body.put("order_code", orderCode);
         
         HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);
         
         try {
             ResponseEntity<Map> response = restTemplate.postForEntity(url, request, Map.class);
             if (response.getStatusCode() == HttpStatus.OK) {
                 Map<String, Object> responseBody = response.getBody();
                 if (responseBody != null && (int) responseBody.get("code") == 200) {
                     return (Map<String, Object>) responseBody.get("data");
                 }
             }
             return null;
         } catch (Exception e) {
             throw new Exception("Failed to get GHN order info: " + e.getMessage());
         }
    }

    // Get Provinces
    public List<Map<String, Object>> getProvinces() throws Exception {
        String url = "https://dev-online-gateway.ghn.vn/shiip/public-api/master-data/province";
        HttpHeaders headers = new HttpHeaders();
        headers.set("token", ghnToken);
        HttpEntity<String> request = new HttpEntity<>(headers);

        try {
            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.GET, request, Map.class);
            if (response.getStatusCode() == HttpStatus.OK) {
                Map<String, Object> responseBody = (Map<String, Object>) response.getBody();
                if (responseBody != null && (int) responseBody.get("code") == 200) {
                    return (List<Map<String, Object>>) responseBody.get("data");
                }
            }
            return null;
        } catch (Exception e) {
            throw new Exception("Failed to get GHN provinces: " + e.getMessage());
        }
    }

    // Get Districts
    public List<Map<String, Object>> getDistricts(int provinceId) throws Exception {
        String url = "https://dev-online-gateway.ghn.vn/shiip/public-api/master-data/district";
        HttpHeaders headers = new HttpHeaders();
        headers.set("token", ghnToken);
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> body = new HashMap<>();
        body.put("province_id", provinceId);
        
        // GHN district API usually works with GET + params or POST. 
        // Using POST based on typical GHN patterns or GET with query param.
        // Documentation says GET: /master-data/district?province_id={province_id} is also common.
        // Let's try GET with param first as it is safer for master-data.
        // Wait, standard GHN v2 uses payload for most things, but let's try constructing the URL for GET which is safer for cached data.
        
        String urlWithParams = url + "?province_id=" + provinceId;
        HttpEntity<String> request = new HttpEntity<>(headers);
        
        try {
            ResponseEntity<Map> response = restTemplate.exchange(urlWithParams, HttpMethod.GET, request, Map.class);
            if (response.getStatusCode() == HttpStatus.OK) {
                Map<String, Object> responseBody = response.getBody();
                if (responseBody != null && (int) responseBody.get("code") == 200) {
                    return (List<Map<String, Object>>) responseBody.get("data");
                }
            }
            return new ArrayList<>();
        } catch (Exception e) {
            System.err.println("Error getting GHN districts: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    // Get Wards
    public List<Map<String, Object>> getWards(int districtId) {
        String url = "https://dev-online-gateway.ghn.vn/shiip/public-api/master-data/ward";
        HttpHeaders headers = new HttpHeaders();
        headers.set("token", ghnToken);
        
        String urlWithParams = url + "?district_id=" + districtId;
        HttpEntity<String> request = new HttpEntity<>(headers);

        try {
            ResponseEntity<Map> response = restTemplate.exchange(urlWithParams, HttpMethod.GET, request, Map.class);
            if (response.getStatusCode() == HttpStatus.OK) {
                Map<String, Object> responseBody = response.getBody();
                if (responseBody != null && (int) responseBody.get("code") == 200) {
                    return (List<Map<String, Object>>) responseBody.get("data");
                }
            }
            return new ArrayList<>();
        } catch (Exception e) {
            System.err.println("Error getting GHN wards: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    // Validate if District ID exists in a Province
    public boolean isValidDistrict(int provinceId, int districtId) {
        try {
            List<Map<String, Object>> districts = getDistricts(provinceId);
            if (districts == null) return false;
            for (Map<String, Object> d : districts) {
                Object idObj = d.get("DistrictID");
                if (idObj != null && Integer.parseInt(idObj.toString()) == districtId) {
                    return true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Validate if Ward Code exists in a District
    public boolean isValidWard(int districtId, String wardCode) {
        try {
            List<Map<String, Object>> wards = getWards(districtId);
            if (wards == null) return false;
            for (Map<String, Object> w : wards) {
                Object codeObj = w.get("WardCode");
                if (codeObj != null && codeObj.toString().equals(wardCode)) {
                    return true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Lookup methods
    public Integer getProvinceIdByName(String provinceName) {
        try {
            List<Map<String, Object>> provinces = getProvinces();
            if (provinces != null) {
                for (Map<String, Object> p : provinces) {
                    // GHN returns ProvinceName and NameExtension
                    Object nameObj = p.get("ProvinceName");
                    if (compareNames(nameObj, provinceName)) return (Integer) p.get("ProvinceID");
                    
                    List<String> extensions = (List<String>) p.get("NameExtension");
                    if (extensions != null) {
                        for (String ext : extensions) {
                            if (compareNames(ext, provinceName)) return (Integer) p.get("ProvinceID");
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Integer getDistrictIdByName(int provinceId, String districtName) {
        try {
            List<Map<String, Object>> districts = getDistricts(provinceId);
            if (districts != null) {
                for (Map<String, Object> d : districts) {
                    Object nameObj = d.get("DistrictName");
                    if (compareNames(nameObj, districtName)) return (Integer) d.get("DistrictID");
                    
                    List<String> extensions = (List<String>) d.get("NameExtension");
                    if (extensions != null) {
                         for (String ext : extensions) {
                            if (compareNames(ext, districtName)) return (Integer) d.get("DistrictID");
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public String getWardCodeByName(int districtId, String wardName) {
        try {
            List<Map<String, Object>> wards = getWards(districtId);
            if (wards != null) {
                for (Map<String, Object> w : wards) {
                    Object nameObj = w.get("WardName");
                    if (compareNames(nameObj, wardName)) return (String) w.get("WardCode");
                    
                    List<String> extensions = (List<String>) w.get("NameExtension");
                    if (extensions != null) {
                         for (String ext : extensions) {
                            if (compareNames(ext, wardName)) return (String) w.get("WardCode");
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private boolean compareNames(Object nameObj, String searchName) {
        if (nameObj == null || searchName == null) return false;
        String name1 = nameObj.toString().trim().toLowerCase();
        String name2 = searchName.trim().toLowerCase();
        return name1.equals(name2) || name1.contains(name2) || name2.contains(name1);
    }
}

