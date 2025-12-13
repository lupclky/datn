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

        // 2. Auto-create GHN Waybill
        // User request: "kể cả stripe và vnpay vẫn tạo vận đơn thủ công" -> Disable auto-creation entirely.
        // if (districtId != null && wardCode != null && !"Hỏa tốc".equalsIgnoreCase(order.getShippingMethod())) {
        //    ...
        // }
        // Keeping the code commented out or removing the logic block.
        
        /* 
        boolean isCod = "Cash".equalsIgnoreCase(order.getPaymentMethod());
        if (districtId != null && wardCode != null && !"Hỏa tốc".equalsIgnoreCase(order.getShippingMethod()) && !isCod) {
             try {
                // ... logic ...
             } catch (Exception e) {
                 // ...
             }
        }
        */
    }
}

