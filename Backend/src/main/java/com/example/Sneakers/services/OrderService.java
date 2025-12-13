package com.example.Sneakers.services;

import com.example.Sneakers.dtos.CartItemDTO;
import com.example.Sneakers.dtos.OrderDTO;
import com.example.Sneakers.dtos.DashboardStatsDTO;
import com.example.Sneakers.exceptions.DataNotFoundException;
import com.example.Sneakers.models.*;
import com.example.Sneakers.repositories.OrderDetailRepository;
import com.example.Sneakers.repositories.OrderRepository;
import com.example.Sneakers.repositories.ProductRepository;
import com.example.Sneakers.repositories.UserRepository;
import com.example.Sneakers.repositories.VoucherRepository;
import com.example.Sneakers.repositories.VoucherUsageRepository;
import com.example.Sneakers.responses.*;
import com.example.Sneakers.utils.Email;
import com.example.Sneakers.utils.BuilderEmailContent;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderService implements IOrderService {
    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final ModelMapper modelMapper;
    private final ProductRepository productRepository;
    private final OrderDetailRepository orderDetailRepository;
    private final UserService userService;
    private final VoucherRepository voucherRepository;
    private final VoucherUsageRepository voucherUsageRepository;
    private final GhnService ghnService;
    private final AsyncOrderService asyncOrderService;
    private final Email emailService;

    @Override
    @Transactional
    public OrderIdResponse createOrder(OrderDTO orderDTO, String token) throws Exception {
        // Tìm xem user id có tồn tại không
        String extractedToken = token.substring(7); // Loại bỏ "Bearer " từ chuỗi token
        User user = userService.getUserDetailsFromToken(extractedToken);
        // Kiểm tra xem cartItems có trống không
        if (orderDTO.getCartItems() == null || orderDTO.getCartItems().isEmpty()) {
            throw new Exception("Cart items are null or empty");
        }
        Long shippingCost = switch (orderDTO.getShippingMethod()) {
            case "Tiêu chuẩn" -> 30000L;
            case "Nhanh" -> 40000L;
            case "Hỏa tốc" -> 60000L;
            default -> throw new Exception("Shipping method is unavailable");
        };

        // Calculate base total
        Long baseTotal = orderDTO.getSubTotal();
        Long finalTotal = orderDTO.getTotalMoney();
        Voucher appliedVoucher = null;
        Long discountAmount = 0L;

        // Handle voucher if provided
        if (orderDTO.getVoucherCode() != null && !orderDTO.getVoucherCode().trim().isEmpty()) {
            // Find and validate voucher
            Voucher voucher = voucherRepository.findByCode(orderDTO.getVoucherCode())
                    .orElseThrow(() -> new Exception("Voucher không tồn tại"));

            // Check if voucher is active
            if (!voucher.getIsActive()) {
                throw new Exception("Voucher không còn hoạt động");
            }

            // Check validity period
            LocalDateTime now = LocalDateTime.now();
            if (now.isBefore(voucher.getValidFrom()) || now.isAfter(voucher.getValidTo())) {
                throw new Exception("Voucher không trong thời gian hiệu lực");
            }

            // Check minimum order value
            if (baseTotal < voucher.getMinOrderValue()) {
                throw new Exception("Giá trị đơn hàng không đủ điều kiện áp dụng voucher");
            }

            // Check remaining quantity
            if (voucher.getRemainingQuantity() <= 0) {
                throw new Exception("Voucher đã hết lượt sử dụng");
            }

            // Calculate discount
            discountAmount = (baseTotal * voucher.getDiscountPercentage()) / 100;
            if (voucher.getMaxDiscountAmount() != null && discountAmount > voucher.getMaxDiscountAmount()) {
                discountAmount = voucher.getMaxDiscountAmount();
            }

            // Apply discount to final total
            finalTotal = baseTotal - discountAmount + shippingCost;
            appliedVoucher = voucher;
        }

        // Xác định trạng thái ban đầu dựa trên phương thức thanh toán
        String initialStatus;
        if ("Cash".equalsIgnoreCase(orderDTO.getPaymentMethod())) {
            initialStatus = OrderStatus.PROCESSING; // Đơn COD vào thẳng trạng thái xử lý
        } else {
            initialStatus = OrderStatus.PAYMENT_FAILED; // Đơn online cần thanh toán
        }

        Order order = Order.builder()
                .user(user)
                .orderDate(LocalDateTime.now())
                .status(initialStatus) // Sử dụng trạng thái đã xác định
                .fullName(orderDTO.getFullName())
                .email(orderDTO.getEmail())
                .phoneNumber(orderDTO.getPhoneNumber())
                .address(orderDTO.getAddress())
                .note(orderDTO.getNote())
                .shippingMethod(orderDTO.getShippingMethod())
                .paymentMethod(orderDTO.getPaymentMethod())
                .totalMoney(finalTotal)
                .voucher(appliedVoucher)
                .discountAmount(discountAmount)
                .active(true)
                .shippingDate(LocalDate.now().plusDays(3))
                .districtId(orderDTO.getDistrictId())
                .wardCode(orderDTO.getWardCode())
                .build();

        orderRepository.save(order);

        // Track voucher usage and update remaining quantity
        if (appliedVoucher != null) {
            // Create voucher usage record
            VoucherUsage voucherUsage = VoucherUsage.builder()
                    .voucher(appliedVoucher)
                    .order(order)
                    .user(user)
                    .discountAmount(discountAmount)
                    .usedAt(LocalDateTime.now())
                    .build();
            voucherUsageRepository.save(voucherUsage);

            // Update remaining quantity
            appliedVoucher.setRemainingQuantity(appliedVoucher.getRemainingQuantity() - 1);
            voucherRepository.save(appliedVoucher);
        }

        // Tạo danh sách các đối tượng OrderDetail từ cartItems
        List<OrderDetail> orderDetails = new ArrayList<>();
        for (CartItemDTO cartItemDTO : orderDTO.getCartItems()) {
            // Tạo một đối tượng OrderDetail từ CartItemDTO
            OrderDetail orderDetail = new OrderDetail();
            orderDetail.setOrder(order);

            // Lấy thông tin sản phẩm từ cartItemDTO
            Long productId = cartItemDTO.getProductId();
            Long quantity = cartItemDTO.getQuantity();
            Long size = cartItemDTO.getSize();

            // Tìm thông tin sản phẩm từ cơ sở dữ liệu (hoặc sử dụng cache nếu cần)
            Product product = productRepository.findById(productId)
                    .orElseThrow(() -> new DataNotFoundException("Product not found with id: " + productId));

            if (product.getQuantity() < quantity) {
                throw new Exception("Product " + product.getName() + " is out of stock");
            }

            product.setQuantity(product.getQuantity() - quantity);

            // Đặt thông tin cho OrderDetail
            orderDetail.setProduct(product);
            orderDetail.setNumberOfProducts(quantity);
            orderDetail.setSize(size);

            // Các trường khác của OrderDetail nếu cần
            orderDetail.setPrice(product.getPrice());
            orderDetail.setTotalMoney(product.getPrice() * quantity);
            // Thêm OrderDetail vào danh sách
            orderDetails.add(orderDetail);
        }
        order.setOrderDetails(orderDetails);

        // Lưu danh sách OrderDetail vào cơ sở dữ liệu
        orderDetailRepository.saveAll(orderDetails);

        // Offload email sending and GHN waybill creation to async service
        asyncOrderService.processAfterOrderCreation(order, orderDTO.getDistrictId(), orderDTO.getWardCode());

        return OrderIdResponse.fromOrder(order);
    }

    @Override
    public OrderResponse getOrder(Long id) {
        Order order = orderRepository.findByIdWithDetails(id).orElse(null);
        if (order == null) return null;
        OrderResponse response = OrderResponse.fromOrder(order);
        try {
            if (order.getTrackingNumber() != null && "GHN".equals(order.getCarrier())) {
                response.setTrackingInfo(ghnService.getOrderInfo(order.getTrackingNumber()));
            }
        } catch (Exception e) {
            System.err.println("Error fetching tracking info: " + e.getMessage());
        }
        return response;
    }

    @Override
    public OrderResponse getOrderByUser(Long orderId, String token) throws Exception {
        String extractedToken = token.substring(7);
        User user = userService.getUserDetailsFromToken(extractedToken);

        Order order = orderRepository.findByIdWithDetails(orderId).orElse(null);
        if (order == null) {
             throw new Exception("Cannot find order with id = " + orderId);
        }

        // Allow ADMIN to view any order
        if (user.getRole() != null && user.getRole().getName().equals(Role.ADMIN)) {
            OrderResponse response = OrderResponse.fromOrder(order);
            try {
                if (order.getTrackingNumber() != null && "GHN".equals(order.getCarrier())) {
                    response.setTrackingInfo(ghnService.getOrderInfo(order.getTrackingNumber()));
                }
            } catch (Exception e) {
                System.err.println("Error fetching tracking info: " + e.getMessage());
            }
            return response;
        }

        // Allow STAFF to view only assigned orders
        if (user.getRole() != null && user.getRole().getName().equals(Role.STAFF)) {
            if (order.getAssignedStaff() == null || !order.getAssignedStaff().getId().equals(user.getId())) {
                throw new Exception("You can only view orders assigned to you");
            }
            OrderResponse response = OrderResponse.fromOrder(order);
            try {
                if (order.getTrackingNumber() != null && "GHN".equals(order.getCarrier())) {
                    response.setTrackingInfo(ghnService.getOrderInfo(order.getTrackingNumber()));
                }
            } catch (Exception e) {
                System.err.println("Error fetching tracking info: " + e.getMessage());
            }
            return response;
        }

        // Regular users can only view their own orders
        if (!user.getId().equals(order.getUser().getId())) {
            throw new Exception("Cannot get order of another user");
        }
        OrderResponse response = OrderResponse.fromOrder(order);
        try {
             if (order.getTrackingNumber() != null && "GHN".equals(order.getCarrier())) {
                 response.setTrackingInfo(ghnService.getOrderInfo(order.getTrackingNumber()));
             }
         } catch (Exception e) {
             System.err.println("Error fetching tracking info: " + e.getMessage());
         }
        return response;
    }

    @Override
    @Transactional
    public Order updateOrder(Long id, OrderDTO orderDTO) throws DataNotFoundException {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new DataNotFoundException("Cannot find order with id = " + id));
        User existingUser = userRepository.findById(
                orderDTO.getUserId()).orElseThrow(() -> new DataNotFoundException("Cannot find user with id: " + id));
        modelMapper.typeMap(OrderDTO.class, Order.class)
                .addMappings(mapper -> mapper.skip(Order::setId))
                .addMappings(mapper -> mapper.skip(Order::setOrderDetails));
        modelMapper.map(orderDTO, order);
        order.setUser(existingUser);
        return orderRepository.save(order);
    }

    @Override
    @Transactional
    public void deleteOrder(Long id) {
        Order order = orderRepository.findById(id).orElse(null);
        if (order != null) {
            order.setActive(false);
            orderRepository.save(order);
        }
    }

    @Override
    @Transactional(readOnly = true)
    public List<OrderHistoryResponse> findByUserId(String token) throws Exception {
        String extractedToken = token.substring(7);
        User user = userService.getUserDetailsFromToken(extractedToken);
        List<Order> orders = orderRepository.findByUserId(user.getId());
        return orders.stream().map(OrderHistoryResponse::fromOrder)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<OrderHistoryResponse> getAllOrders(String token) {
        String extractedToken = token.substring(7);
        User user;
        try {
            user = userService.getUserDetailsFromToken(extractedToken);
        } catch (Exception e) {
            throw new RuntimeException("Invalid token");
        }

        List<Order> orders;
        if (user.getRole().getName().equals(Role.ADMIN)) {
            orders = orderRepository.findAll();
        } else if (user.getRole().getName().equals(Role.STAFF)) {
            orders = orderRepository.findByAssignedStaffId(user.getId());
        } else {
            orders = new ArrayList<>();
        }

        return orders.stream()
                .map(OrderHistoryResponse::fromOrder)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void assignStaff(Long orderId, Long staffId) throws Exception {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new DataNotFoundException("Order not found"));
        User staff = userRepository.findById(staffId)
                .orElseThrow(() -> new DataNotFoundException("Staff not found"));
        
        if (staff.getRole() == null || !staff.getRole().getName().equals(Role.STAFF)) {
            throw new Exception("User is not a staff member");
        }

        order.setAssignedStaff(staff);
        Order savedOrder = orderRepository.save(order);
        
        // Send email notification to customer about assigned staff
        try {
            String to = order.getEmail();
            String subject = "Nhân viên lắp đặt đã được phân công - Đơn hàng #" + order.getId() + " - Locker Korea";
            String content = BuilderEmailContent.buildStaffAssignmentEmailContent(savedOrder);
            boolean sendMail = emailService.sendEmail(to, subject, content);
            
            if (!sendMail) {
                System.err.println("Warning: Failed to send staff assignment email to " + to);
            }
        } catch (Exception emailException) {
            System.err.println("Warning: Exception while sending staff assignment email: " + emailException.getMessage());
            // Don't throw exception - staff assignment succeeded, email failure is non-critical
        }
    }

    @Override
    public Page<Order> getOrdersByKeyword(String keyword, String status, LocalDate startDate, LocalDate endDate,
            Pageable pageable) {
        return orderRepository.findByKeyword(keyword, status, startDate, endDate, pageable);
    }

    @Override
    public Order updateOrderStatus(Long orderId, String status) throws DataNotFoundException {
        Order order = orderRepository.findById(orderId).orElseThrow(() ->
                new DataNotFoundException("Cannot find order with id: " + orderId));
        order.setStatus(status);
        return orderRepository.save(order);
    }

    @Override
    public Long getTotalRevenue() {
        return orderRepository.calculateTotalRevenue();
    }

    public DashboardStatsDTO getDashboardStats() {
        Long totalRevenue = orderRepository.calculateTotalRevenue();
        Long todayOrders = orderRepository.countOrdersByDate(LocalDate.now());
        Long totalProductsSold = orderRepository.countTotalProductsSold();

        return new DashboardStatsDTO(totalRevenue, todayOrders, totalProductsSold);
    }

    @Override
    public List<Order> findByUserId(Long userId) {
        return orderRepository.findByUserId(userId);
    }

    @Override
    public long countOrders() {
        return orderRepository.count();
    }

    @Override
    public List<Order> getOrdersByDateRange(LocalDate startDate, LocalDate endDate) {
        return orderRepository.findByOrderDateBetween(startDate, endDate);
    }

    @Override
    @Transactional
    public Order createWaybill(Long orderId, Integer districtId, String wardCode, Integer length, Integer width, Integer height, Integer weight) throws Exception {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new DataNotFoundException("Order not found"));
        
        if (order.getTrackingNumber() != null && !order.getTrackingNumber().isEmpty()) {
             throw new Exception("Order already has a waybill: " + order.getTrackingNumber());
        }

        String trackingCode = ghnService.createOrder(order, districtId, wardCode, length, width, height, weight);
        order.setTrackingNumber(trackingCode);
        order.setCarrier("GHN");
        
        // Update order district and ward if provided
        order.setDistrictId(districtId);
        order.setWardCode(wardCode);
        
        Order savedOrder = orderRepository.save(order);
        
        // Send waybill email to customer
        try {
            String to = order.getEmail();
            String subject = "Mã vận đơn đơn hàng #" + order.getId() + " - Locker Korea";
            String content = BuilderEmailContent.buildWaybillEmailContent(savedOrder);
            boolean sendMail = emailService.sendEmail(to, subject, content);
            
            if (!sendMail) {
                System.err.println("Warning: Failed to send waybill email to " + to);
            }
        } catch (Exception emailException) {
            System.err.println("Warning: Exception while sending waybill email: " + emailException.getMessage());
            // Don't throw exception - waybill creation succeeded, email failure is non-critical
        }
        
        return savedOrder;
    }

    @Override
    public Object getTrackingInfo(Long orderId) throws Exception {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new DataNotFoundException("Order not found"));
            
        if (order.getTrackingNumber() == null) {
            return null;
        }
        
        if ("GHN".equals(order.getCarrier())) {
            return ghnService.getOrderInfo(order.getTrackingNumber());
        }
        
        return null;
    }
}
