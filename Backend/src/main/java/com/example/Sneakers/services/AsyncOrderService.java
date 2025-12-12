package com.example.Sneakers.services;

import com.example.Sneakers.models.Order;
import com.example.Sneakers.repositories.OrderRepository;
import com.example.Sneakers.utils.BuilderEmailContent;
import com.example.Sneakers.utils.Email;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AsyncOrderService {
    private final GhnService ghnService;
    private final Email emailService;
    private final OrderRepository orderRepository;

    @Async
    public void processAfterOrderCreation(Order order, Integer districtId, String wardCode) {
        // 1. Send Email
        try {
            String to = order.getEmail();
            String subject = "Đặt hàng thành công từ Locker Korea - Đơn hàng #" + order.getId();
            String content = BuilderEmailContent.buildOrderEmailContent(order);
            boolean sendMail = emailService.sendEmail(to, subject, content);

            if (!sendMail) {
                System.err.println("Warning: Failed to send order confirmation email to " + to);
            }
        } catch (Exception emailException) {
            System.err.println("Warning: Exception while sending email: " + emailException.getMessage());
        }

        // 2. Auto-create GHN Waybill if district and ward are provided and shipping method is NOT "Hỏa tốc"
        // Note: Shipping method check should match the name sent from frontend ("Nhanh", "Hỏa tốc")
        if (districtId != null && wardCode != null && !"Hỏa tốc".equalsIgnoreCase(order.getShippingMethod())) {
            try {
                // Determine COD amount based on payment method logic is handled inside GhnService.createOrder using order data
                String trackingCode = ghnService.createOrder(order, districtId, wardCode);
                
                // Update order with tracking number
                // Fetch fresh from DB to ensure we don't overwrite other parallel updates (though unlikely for new order)
                // or just use repo to update specific fields if we had a custom query.
                // Standard save is fine here.
                Order orderToUpdate = orderRepository.findById(order.getId()).orElse(null);
                if (orderToUpdate != null) {
                    orderToUpdate.setTrackingNumber(trackingCode);
                    orderToUpdate.setCarrier("GHN");
                    orderRepository.save(orderToUpdate);
                    System.out.println("Async GHN Waybill created: " + trackingCode + " for Order ID: " + order.getId());
                }
            } catch (Exception e) {
                e.printStackTrace();
                System.err.println("Failed to auto-create GHN order in background: " + e.getMessage());
            }
        }
    }
}

