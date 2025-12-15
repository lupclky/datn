package com.example.Sneakers.responses;

import com.example.Sneakers.models.Order;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;

import java.time.LocalDateTime;
import java.util.stream.Collectors;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class OrderHistoryResponse {
    private Long id;

    @JsonProperty("user_id")
    private Long userId;

    private String status;

    @JsonProperty("total_money")
    private Long totalMoney;

    @JsonProperty("product_name")
    private String productName;

    @JsonProperty("order_date")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime orderDate;

    private String thumbnail;

    @JsonProperty("total_products")
    private int totalProducts;

    @JsonProperty("fullname")
    private String fullname;

    @JsonProperty("phone_number")
    private String phoneNumber;

    @JsonProperty("payment_method")
    private String paymentMethod;

    @JsonProperty("shipping_method")
    private String shippingMethod;

    @JsonProperty("address")
    private String address;

    @JsonProperty("email")
    private String email;

    @JsonProperty("assigned_staff_name")
    private String assignedStaffName;

    public static OrderHistoryResponse fromOrder(Order order){
        OrderHistoryResponseBuilder builder = OrderHistoryResponse.builder()
                .id(order.getId())
                .userId(order.getUser().getId())
                .status(order.getStatus())
                .totalMoney(order.getTotalMoney())
                .orderDate(order.getOrderDate())
                .fullname(order.getFullName())
                .phoneNumber(order.getPhoneNumber())
                .email(order.getEmail())
                .paymentMethod(order.getPaymentMethod())
                .shippingMethod(order.getShippingMethod())
                .address(order.getAddress());

        if (order.getAssignedStaff() != null) {
            builder.assignedStaffName(order.getAssignedStaff().getFullName());
        }

        if (order.getOrderDetails() != null && !order.getOrderDetails().isEmpty()) {
            // Lấy thumbnail của sản phẩm đầu tiên
            builder.thumbnail(order.getOrderDetails().get(0).getProduct().getThumbnail());
            
            // Nối tên tất cả sản phẩm
            String productNames = order.getOrderDetails().stream()
                    .map(od -> od.getProduct().getName())
                    .collect(Collectors.joining(", "));
            builder.productName(productNames);
            
            // Tính tổng số lượng sản phẩm
            long totalProducts = order.getOrderDetails().stream()
                    .mapToLong(od -> od.getNumberOfProducts())
                    .sum();
            builder.totalProducts((int) totalProducts);

        } else {
            builder.thumbnail("notfound.jpg")
                    .productName("N/A")
                    .totalProducts(0);
        }

        return builder.build();
    }
}