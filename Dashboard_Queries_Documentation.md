# Dashboard Queries Documentation - LockerKorea

Tài liệu này tổng hợp tất cả các query được sử dụng cho dashboard của hệ thống LockerKorea.

## 📁 Vị trí các file

### Services
- **StatisticsService**: `Backend/src/main/java/com/example/Sneakers/services/StatisticsService.java`
- **OrderService**: `Backend/src/main/java/com/example/Sneakers/services/OrderService.java`

### Repositories
- **OrderRepository**: `Backend/src/main/java/com/example/Sneakers/repositories/OrderRepository.java`
- **OrderDetailRepository**: `Backend/src/main/java/com/example/Sneakers/repositories/OrderDetailRepository.java`
- **ProductRepository**: `Backend/src/main/java/com/example/Sneakers/repositories/ProductRepository.java`

### Controllers
- **OrderController**: `Backend/src/main/java/com/example/Sneakers/controllers/OrderController.java`
- **StatisticsController**: `Backend/src/main/java/com/example/Sneakers/controllers/StatisticsController.java`
- **AIChatController**: `Backend/src/main/java/com/example/Sneakers/ai/controllers/AIChatController.java`

---

## 📊 Các Query Dashboard

### 1. Tổng quan Dashboard (Dashboard Stats)

**Endpoint**: `GET /api/orders/dashboard-stats`

**Service Method**: `OrderService.getDashboardStats()`

**Queries sử dụng**:

#### 1.1. Tổng doanh thu
```sql
-- OrderRepository.calculateTotalRevenue()
SELECT COALESCE(SUM(total_money - COALESCE(discount_amount, 0)), 0) 
FROM orders 
WHERE status IN ('pending', 'shipped', 'delivered') 
AND active = true
```

#### 1.2. Đơn hàng hôm nay
```sql
-- OrderRepository.countOrdersByDate()
SELECT COUNT(*) 
FROM orders o 
WHERE DATE(o.order_date) = :date 
AND o.status IN ('pending', 'processing', 'delivered', 'paid') 
AND o.active = true
```

#### 1.3. Tổng sản phẩm đã bán
```sql
-- OrderRepository.countTotalProductsSold()
SELECT COALESCE(SUM(od.number_of_products), 0) 
FROM orders o 
JOIN order_details od ON o.id = od.order_id 
WHERE o.status IN ('pending', 'shipped', 'delivered') 
AND o.active = true
```

---

### 2. Thống kê Doanh thu (Revenue Statistics)

#### 2.1. Doanh thu theo ngày
**Service Method**: `StatisticsService.getDailyRevenue(LocalDate date)`

```sql
-- OrderRepository.getDailyRevenue()
SELECT COALESCE(SUM(o.total_money), 0) 
FROM orders o 
WHERE DATE(o.order_date) = :date 
AND o.status IN ('pending', 'processing', 'delivered', 'paid') 
AND o.active = true
```

#### 2.2. Doanh thu theo khoảng thời gian (Ngày)
**Service Method**: `StatisticsService.getRevenueByDateRange(LocalDate startDate, LocalDate endDate)`

```sql
-- OrderRepository.getRevenueByDateRange()
SELECT DATE(o.order_date) as order_day, 
       COALESCE(SUM(o.total_money - COALESCE(o.discount_amount, 0)), 0) 
FROM orders o 
WHERE DATE(o.order_date) BETWEEN :startDate AND :endDate 
AND o.status IN ('pending', 'shipped', 'delivered') 
AND o.active = true 
GROUP BY DATE(o.order_date) 
ORDER BY DATE(o.order_date)
```

#### 2.3. Doanh thu theo tháng
**Service Method**: `StatisticsService.getRevenueByMonthRange(String startMonth, String endMonth)`

```sql
-- OrderRepository.getRevenueByMonthRange()
SELECT YEAR(o.order_date), MONTH(o.order_date), 
       COALESCE(SUM(o.total_money - COALESCE(o.discount_amount, 0)), 0) 
FROM orders o 
WHERE o.order_date BETWEEN :startDate AND :endDate 
AND o.status IN ('pending', 'shipped', 'delivered') 
AND o.active = true 
GROUP BY YEAR(o.order_date), MONTH(o.order_date) 
ORDER BY YEAR(o.order_date), MONTH(o.order_date)
```

#### 2.4. Doanh thu theo năm
**Service Method**: `StatisticsService.getRevenueByYearRange(String startYear, String endYear)`

```sql
-- OrderRepository.getRevenueByYearRange()
SELECT YEAR(o.order_date), 
       COALESCE(SUM(o.total_money - COALESCE(o.discount_amount, 0)), 0) 
FROM orders o 
WHERE YEAR(o.order_date) BETWEEN :startYear AND :endYear 
AND o.status IN ('pending', 'shipped', 'delivered') 
AND o.active = true 
GROUP BY YEAR(o.order_date) 
ORDER BY YEAR(o.order_date)
```

---

### 3. Thống kê Sản phẩm (Product Statistics)

#### 3.1. Tổng quan sản phẩm
**Service Method**: `StatisticsService.getProductStatistics()`

**Queries**:
```sql
-- Tổng số sản phẩm
SELECT COUNT(*) FROM products

-- Số sản phẩm đã bán
SELECT COUNT(DISTINCT od.product.id) 
FROM OrderDetail od 
JOIN od.order o 
WHERE o.status IN ('pending', 'shipped', 'delivered') 
AND o.active = true

-- Tổng số lượng tồn kho
SELECT SUM(p.quantity) FROM Product p
```

#### 3.2. Top sản phẩm bán chạy (Tất cả thời gian)
**Service Method**: `StatisticsService.getTopProductSold(int topN)`

```sql
-- OrderDetailRepository.getBestSellingProductsNative()
SELECT p.id, p.name, 
       SUM(od.number_of_products) AS total_sold, 
       SUM(od.total_money) AS total_revenue 
FROM order_details od 
JOIN products p ON od.product_id = p.id 
JOIN orders o ON od.order_id = o.id 
WHERE o.status IN ('pending', 'shipped', 'delivered') 
AND o.active = true 
GROUP BY p.id, p.name 
HAVING SUM(od.number_of_products) > 0 
ORDER BY total_sold DESC 
LIMIT :limit
```

#### 3.3. Top sản phẩm bán chạy (Theo khoảng thời gian)
**Service Method**: `StatisticsService.getTopProductSoldByDateRange(int topN, String startDate, String endDate)`

```sql
-- OrderDetailRepository.getBestSellingProductsByDateRange()
SELECT p.id, p.name, 
       SUM(od.number_of_products) AS total_sold, 
       SUM(od.total_money) AS total_revenue 
FROM order_details od 
JOIN products p ON od.product_id = p.id 
JOIN orders o ON od.order_id = o.id 
WHERE o.status IN ('pending', 'shipped', 'delivered') 
AND o.active = true 
AND DATE(o.order_date) >= DATE(:startDate) 
AND DATE(o.order_date) <= DATE(:endDate) 
GROUP BY p.id, p.name 
HAVING SUM(od.number_of_products) > 0 
ORDER BY total_sold DESC 
LIMIT :limit
```

#### 3.4. Sản phẩm bán theo ngày
**Service Method**: `StatisticsService.getProductSoldByDate(LocalDate date)`

```sql
-- OrderDetailRepository.getProductSoldByDate()
SELECT od.product_id, p.name, SUM(od.number_of_products) 
FROM order_details od 
JOIN orders o ON od.order_id = o.id 
JOIN products p ON od.product_id = p.id 
WHERE DATE(o.order_date) = DATE(:date) 
AND o.status IN ('pending', 'shipped', 'delivered') 
AND o.active = true 
GROUP BY od.product_id, p.name 
HAVING SUM(od.number_of_products) > 0 
ORDER BY SUM(od.number_of_products) DESC
```

#### 3.5. Sản phẩm bán theo tháng
**Service Method**: `StatisticsService.getProductSoldByMonth(int year, int month)`

```sql
-- OrderDetailRepository.getProductSoldByMonth()
SELECT od.product_id, p.name, SUM(od.number_of_products) 
FROM order_details od 
JOIN orders o ON od.order_id = o.id 
JOIN products p ON od.product_id = p.id 
WHERE YEAR(o.order_date) = :year 
AND MONTH(o.order_date) = :month 
AND o.status IN ('pending', 'shipped', 'delivered') 
AND o.active = true 
GROUP BY od.product_id, p.name 
HAVING SUM(od.number_of_products) > 0 
ORDER BY SUM(od.number_of_products) DESC
```

#### 3.6. Sản phẩm bán theo năm
**Service Method**: `StatisticsService.getProductSoldByYear(int year)`

```sql
-- OrderDetailRepository.getProductSoldByYear()
SELECT od.product_id, p.name, SUM(od.number_of_products) 
FROM order_details od 
JOIN orders o ON od.order_id = o.id 
JOIN products p ON od.product_id = p.id 
WHERE YEAR(o.order_date) = :year 
AND o.status IN ('pending', 'shipped', 'delivered') 
AND o.active = true 
GROUP BY od.product_id, p.name 
HAVING SUM(od.number_of_products) > 0 
ORDER BY SUM(od.number_of_products) DESC
```

#### 3.7. Top sản phẩm tồn kho cao
**Service Method**: `StatisticsService.getTopStockProducts(int topN)`

```sql
-- ProductRepository.findTopProductsByStock()
SELECT p.id, p.name, p.thumbnail, p.quantity, p.price, c.name 
FROM Product p 
LEFT JOIN p.category c 
ORDER BY p.quantity DESC
```

---

### 4. Thống kê Thương hiệu (Brand Statistics)

#### 4.1. Top thương hiệu bán chạy (Tất cả thời gian)
**Service Method**: `StatisticsService.getTopBrandsSold(int topN)`

```sql
-- OrderDetailRepository.getBestSellingBrandsNative()
SELECT c.id, c.name, 
       SUM(od.number_of_products) AS total_sold, 
       SUM(od.total_money) AS total_revenue 
FROM order_details od 
JOIN products p ON od.product_id = p.id 
JOIN categories c ON p.category_id = c.id 
JOIN orders o ON od.order_id = o.id 
WHERE o.status IN ('pending', 'shipped', 'delivered') 
AND o.active = true 
GROUP BY c.id, c.name 
HAVING SUM(od.number_of_products) > 0 
ORDER BY total_sold DESC 
LIMIT :limit
```

#### 4.2. Top thương hiệu bán chạy (Theo khoảng thời gian)
**Service Method**: `StatisticsService.getTopBrandsSoldByDateRange(int topN, String startDate, String endDate)`

```sql
-- OrderDetailRepository.getBestSellingBrandsByDateRange()
SELECT c.id, c.name, 
       SUM(od.number_of_products) AS total_sold, 
       SUM(od.total_money) AS total_revenue 
FROM order_details od 
JOIN products p ON od.product_id = p.id 
JOIN categories c ON p.category_id = c.id 
JOIN orders o ON od.order_id = o.id 
WHERE o.status IN ('pending', 'shipped', 'delivered') 
AND o.active = true 
AND DATE(o.order_date) >= DATE(:startDate) 
AND DATE(o.order_date) <= DATE(:endDate) 
GROUP BY c.id, c.name 
HAVING SUM(od.number_of_products) > 0 
ORDER BY total_sold DESC 
LIMIT :limit
```

---

### 5. Tổng quan Hôm nay (Today Overview)

**Service Method**: `StatisticsService.getTodayOverview()`

**Queries**:
```sql
-- Số đơn hàng hôm nay
SELECT COUNT(*) 
FROM orders o 
WHERE DATE(o.order_date) = :date 
AND o.status IN ('pending', 'processing', 'delivered', 'paid') 
AND o.active = true

-- Doanh thu hôm nay
SELECT COALESCE(SUM(o.total_money), 0) 
FROM orders o 
WHERE DATE(o.order_date) = :date 
AND o.status IN ('pending', 'processing', 'delivered', 'paid') 
AND o.active = true
```

---

### 6. Thống kê Số lượng bán của Sản phẩm

#### 6.1. Tổng số lượng đã bán của một sản phẩm
**Method**: `OrderDetailRepository.getTotalSoldQuantityByProductId()`

```sql
SELECT COALESCE(SUM(od.number_of_products), 0) 
FROM order_details od 
JOIN orders o ON od.order_id = o.id 
WHERE od.product_id = :productId 
AND o.status IN ('pending', 'shipped', 'delivered', 'paid') 
AND o.active = true
```

#### 6.2. Tổng số lượng đã bán của nhiều sản phẩm (Batch)
**Method**: `OrderDetailRepository.getTotalSoldQuantityByProductIds()`

```sql
SELECT od.product_id, COALESCE(SUM(od.number_of_products), 0) AS total_sold 
FROM order_details od 
JOIN orders o ON od.order_id = o.id 
WHERE od.product_id IN :productIds 
AND o.status IN ('pending', 'shipped', 'delivered', 'paid') 
AND o.active = true 
GROUP BY od.product_id
```

---

## 📝 Lưu ý quan trọng

### Trạng thái đơn hàng được tính
Các query chỉ tính các đơn hàng có trạng thái:
- `'pending'`
- `'processing'`
- `'shipped'`
- `'delivered'`
- `'paid'`

Và phải có `active = true`

### Công thức tính doanh thu
```sql
total_money - COALESCE(discount_amount, 0)
```
Doanh thu = Tổng tiền - Số tiền giảm giá (nếu có)

### Định dạng kết quả
- **Doanh thu**: `Double` hoặc `Long` (VND)
- **Số lượng**: `Long`
- **Ngày tháng**: `LocalDate` hoặc `String` (format: "YYYY-MM-DD")

---

## 🔗 API Endpoints

### Dashboard Stats
```
GET /api/orders/dashboard-stats
Response: DashboardStatsDTO {
  totalRevenue: Long,
  todayOrders: Long,
  totalProductsSold: Long
}
```

### Today Overview
```
GET /api/statistics/today-overview
Response: TodayOverviewDTO {
  ordersToday: Long,
  revenueToday: Double
}
```

### Revenue by Date Range
```
GET /api/statistics/revenue/date-range?startDate=2025-01-01&endDate=2025-01-31
Response: List<DailyRevenueDTO>
```

### Revenue by Month Range
```
GET /api/statistics/revenue/month-range?startMonth=2025-01&endMonth=2025-12
Response: List<MonthlyRevenueDTO>
```

### Revenue by Year Range
```
GET /api/statistics/revenue/year-range?startYear=2020&endYear=2025
Response: List<YearlyRevenueDTO>
```

### Top Products Sold
```
GET /api/statistics/products/top-sold?topN=10
Response: List<ProductSoldStatisticsDTO>
```

### Top Brands Sold
```
GET /api/statistics/brands/top-sold?topN=10
Response: List<BrandSoldStatisticsDTO>
```

### Product Statistics
```
GET /api/statistics/products
Response: ProductStatisticsDTO {
  totalProducts: Long,
  soldProducts: Long,
  availableProducts: Long
}
```

### Top Stock Products
```
GET /api/statistics/products/top-stock?topN=10
Response: List<TopStockProductDTO>
```

---

## 🎯 Sử dụng trong Frontend

Các query này được gọi từ:
- **AdminDashboardComponent**: `Frontend/src/app/features/admin/admin-dashboard/admin-dashboard.component.ts`
- **StatisticsService** (Frontend): `Frontend/src/app/core/services/statistics.service.ts`
- **OrderService** (Frontend): `Frontend/src/app/core/services/order.service.ts`

---

## 📌 Ghi chú

1. Tất cả các query đều sử dụng **native SQL** để tối ưu hiệu suất
2. Các query đều có xử lý `COALESCE` để tránh `NULL`
3. Các query đều filter theo `active = true` để chỉ lấy đơn hàng còn hiệu lực
4. Các query về doanh thu đều trừ đi `discount_amount` để tính doanh thu thực tế

