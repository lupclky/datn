package com.example.Sneakers.utils;

import com.example.Sneakers.models.Order;
import com.example.Sneakers.models.OrderDetail;
import java.text.DecimalFormat;

public class BuilderEmailContent {
    public static String buildOrderEmailContent(Order order) {
        StringBuilder content = new StringBuilder();
        content.append("<html><body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>");
        content.append("<div style='max-width: 600px; margin: 0 auto; padding: 20px;'>");
        content.append("<h1 style='color: #673AB7; border-bottom: 3px solid #673AB7; padding-bottom: 10px;'>Đặt hàng thành công từ Locker Korea</h1>");
        content.append("<p style='font-size: 16px;'><strong>Mã đơn hàng: #" + order.getId() + "</strong></p>");
        content.append("<p>Xin chào <strong>" + order.getFullName() + "</strong>,</p>");
        content.append("<p>Chúng tôi xin gửi lời cảm ơn chân thành đến bạn vì đã đặt hàng tại Locker Korea.</p>");
        content.append("<p>Đơn hàng của bạn đã được xác nhận và đang được chuẩn bị để giao đến bạn.</p>");
        content.append("<div style='background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0;'>");
        content.append("<p><strong>Địa chỉ nhận hàng:</strong> " + order.getAddress() + "</p>");
        content.append("<p><strong>Số điện thoại liên hệ:</strong> " + order.getPhoneNumber() + "</p>");
        content.append("</div>");
        content.append("<h2 style='color: #673AB7; margin-top: 30px;'>Thông tin đơn hàng:</h2>");

        // Thêm danh sách sản phẩm trong đơn hàng (nếu có)
        if (order.getOrderDetails() != null && !order.getOrderDetails().isEmpty()) {
            content.append("<table style='width: 100%; border-collapse: collapse; margin: 20px 0;'>");
            content.append("<thead><tr style='background-color: #673AB7; color: white;'>");
            content.append("<th style='padding: 12px; text-align: left;'>Sản phẩm</th>");
            content.append("<th style='padding: 12px; text-align: center;'>Số lượng</th>");
            content.append("<th style='padding: 12px; text-align: right;'>Đơn giá</th>");
            content.append("</tr></thead><tbody>");
            for (OrderDetail orderDetail : order.getOrderDetails()) {
                DecimalFormat decimalFormat = new DecimalFormat("#,###");
                String formattedPrice = decimalFormat.format(orderDetail.getProduct().getPrice());
                content.append("<tr style='border-bottom: 1px solid #eee;'>");
                content.append("<td style='padding: 12px;'>" + orderDetail.getProduct().getName() + "</td>");
                content.append("<td style='padding: 12px; text-align: center;'>" + orderDetail.getNumberOfProducts() + "</td>");
                content.append("<td style='padding: 12px; text-align: right;'>" + formattedPrice + " VND</td>");
                content.append("</tr>");
            }
            content.append("</tbody></table>");
        }

        // Định dạng tổng tiền cần thanh toán cũng có dấu phân cách ","
        DecimalFormat decimalFormat = new DecimalFormat("#,###");
        String formattedTotalMoney = decimalFormat.format(order.getTotalMoney());
        content.append("<div style='background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0; text-align: right;'>");
        content.append("<p style='font-size: 18px; margin: 0;'><strong>Tổng tiền cần thanh toán: <span style='color: #673AB7;'>" + formattedTotalMoney + " VND</span></strong></p>");
        content.append("</div>");

        content.append("<p>Nếu có bất kỳ thắc mắc hoặc vấn đề nào khác, đừng ngần ngại liên hệ với chúng tôi qua địa chỉ email này hoặc số điện thoại hỗ trợ của chúng tôi.</p>");
        content.append("<p>Chúng tôi rất mong bạn sẽ hài lòng với dịch vụ của mình. Cảm ơn bạn đã lựa chọn Locker Korea!</p>");
        content.append("<hr style='margin: 30px 0; border: none; border-top: 1px solid #eee;'/>");
        content.append("<p style='color: #666; font-size: 12px;'>Trân trọng,<br/><strong>Đội ngũ Locker Korea</strong></p>");
        content.append("</div></body></html>");

        return content.toString();
    }

    public static String buildWaybillEmailContent(Order order) {
        StringBuilder content = new StringBuilder();
        content.append("<html><body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>");
        content.append("<div style='max-width: 600px; margin: 0 auto; padding: 20px;'>");
        content.append("<h1 style='color: #673AB7; border-bottom: 3px solid #673AB7; padding-bottom: 10px;'>Mã vận đơn của bạn - Locker Korea</h1>");
        content.append("<p>Xin chào <strong>" + order.getFullName() + "</strong>,</p>");
        content.append("<p>Đơn hàng <strong>#" + order.getId() + "</strong> của bạn đã được tạo vận đơn và đang được vận chuyển.</p>");
        
        if (order.getTrackingNumber() != null && !order.getTrackingNumber().isEmpty()) {
            content.append("<div style='background-color: #e8f5e9; border-left: 4px solid #4caf50; padding: 20px; margin: 20px 0; border-radius: 5px;'>");
            content.append("<h2 style='color: #2e7d32; margin-top: 0;'>Mã vận đơn của bạn:</h2>");
            content.append("<p style='font-size: 24px; font-weight: bold; color: #1b5e20; letter-spacing: 2px; margin: 10px 0;'>" + order.getTrackingNumber() + "</p>");
            if (order.getCarrier() != null) {
                content.append("<p style='margin: 5px 0;'><strong>Đơn vị vận chuyển:</strong> " + order.getCarrier() + "</p>");
            }
            content.append("</div>");
        }
        
        content.append("<div style='background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0;'>");
        content.append("<p><strong>Địa chỉ giao hàng:</strong> " + order.getAddress() + "</p>");
        content.append("<p><strong>Số điện thoại:</strong> " + order.getPhoneNumber() + "</p>");
        content.append("</div>");
        
        content.append("<div style='background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; border-radius: 5px;'>");
        content.append("<p style='margin: 0;'><strong>💡 Lưu ý:</strong></p>");
        content.append("<ul style='margin: 10px 0; padding-left: 20px;'>");
        content.append("<li>Bạn có thể tra cứu đơn hàng bằng mã vận đơn trên website của đơn vị vận chuyển.</li>");
        content.append("<li>Vui lòng giữ số điện thoại luôn bật để nhận cuộc gọi từ nhân viên giao hàng.</li>");
        content.append("<li>Nếu có bất kỳ thắc mắc nào, vui lòng liên hệ với chúng tôi.</li>");
        content.append("</ul>");
        content.append("</div>");
        
        content.append("<p>Cảm ơn bạn đã tin tưởng và lựa chọn Locker Korea!</p>");
        content.append("<hr style='margin: 30px 0; border: none; border-top: 1px solid #eee;'/>");
        content.append("<p style='color: #666; font-size: 12px;'>Trân trọng,<br/><strong>Đội ngũ Locker Korea</strong></p>");
        content.append("</div></body></html>");
        
        return content.toString();
    }

    public static String buildStaffAssignmentEmailContent(Order order) {
        StringBuilder content = new StringBuilder();
        content.append("<html><body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>");
        content.append("<div style='max-width: 600px; margin: 0 auto; padding: 20px;'>");
        content.append("<h1 style='color: #673AB7; border-bottom: 3px solid #673AB7; padding-bottom: 10px;'>Nhân viên lắp đặt đã được phân công - Locker Korea</h1>");
        content.append("<p>Xin chào <strong>" + order.getFullName() + "</strong>,</p>");
        content.append("<p>Chúng tôi xin thông báo rằng nhân viên lắp đặt cho đơn hàng <strong>#" + order.getId() + "</strong> của bạn đã được phân công.</p>");
        
        if (order.getAssignedStaff() != null) {
            content.append("<div style='background-color: #e3f2fd; border-left: 4px solid #2196F3; padding: 20px; margin: 20px 0; border-radius: 5px;'>");
            content.append("<h2 style='color: #1976D2; margin-top: 0;'>Thông tin nhân viên lắp đặt:</h2>");
            content.append("<p style='font-size: 18px; margin: 10px 0;'><strong>Họ tên:</strong> " + order.getAssignedStaff().getFullName() + "</p>");
            content.append("<p style='font-size: 18px; margin: 10px 0;'><strong>Số điện thoại:</strong> " + order.getAssignedStaff().getPhoneNumber() + "</p>");
            content.append("</div>");
        }
        
        content.append("<div style='background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0;'>");
        content.append("<p><strong>Mã đơn hàng:</strong> #" + order.getId() + "</p>");
        content.append("<p><strong>Địa chỉ lắp đặt:</strong> " + order.getAddress() + "</p>");
        content.append("<p><strong>Số điện thoại liên hệ:</strong> " + order.getPhoneNumber() + "</p>");
        content.append("</div>");
        
        content.append("<div style='background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; border-radius: 5px;'>");
        content.append("<p style='margin: 0;'><strong>💡 Lưu ý:</strong></p>");
        content.append("<ul style='margin: 10px 0; padding-left: 20px;'>");
        content.append("<li>Nhân viên lắp đặt sẽ liên hệ với bạn trước khi đến để xác nhận thời gian lắp đặt.</li>");
        content.append("<li>Vui lòng giữ số điện thoại luôn bật để nhận cuộc gọi từ nhân viên.</li>");
        content.append("<li>Nếu có bất kỳ thắc mắc nào, vui lòng liên hệ với chúng tôi hoặc nhân viên lắp đặt trực tiếp.</li>");
        content.append("</ul>");
        content.append("</div>");
        
        content.append("<p>Cảm ơn bạn đã tin tưởng và lựa chọn Locker Korea!</p>");
        content.append("<hr style='margin: 30px 0; border: none; border-top: 1px solid #eee;'/>");
        content.append("<p style='color: #666; font-size: 12px;'>Trân trọng,<br/><strong>Đội ngũ Locker Korea</strong></p>");
        content.append("</div></body></html>");
        
        return content.toString();
    }
}