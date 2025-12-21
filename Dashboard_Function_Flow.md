# Dashboard Function Flow - Tuần tự Gọi và Trả lời

Tài liệu này mô tả chi tiết tuần tự cách gọi và trả lời của các chức năng dashboard trong hệ thống LockerKorea.

---

## 📋 Mục lục

1. [Tổng quan Dashboard](#1-tổng-quan-dashboard)
2. [Thống kê Doanh thu](#2-thống-kê-doanh-thu)
3. [Thống kê Sản phẩm](#3-thống-kê-sản-phẩm)
4. [Thống kê Thương hiệu](#4-thống-kê-thương-hiệu)
5. [AI Dashboard Insights](#5-ai-dashboard-insights)

---

## 1. Tổng quan Dashboard

### 1.1. Load Dashboard Data (Khi component khởi tạo)

**Frontend**: `AdminDashboardComponent.loadDashboardData()`

```
1. Component khởi tạo (ngOnInit)
   ↓
2. Gọi loadDashboardData()
   ↓
3. Thực hiện 4 API calls song song:
```

#### Call 1: Today Overview
```
Frontend: statisticsService.getTodayOverview()
   ↓
HTTP GET: /api/statistics/today-overview
   ↓
Backend: StatisticsController.getTodayOverview()
   ↓
Backend: StatisticsService.getTodayOverview()
   ↓
   ├─> OrderRepository.countOrdersByDate(LocalDate.now())
   │   └─> SQL: SELECT COUNT(*) FROM orders WHERE DATE(order_date) = today
   │
   └─> OrderRepository.getDailyRevenue(LocalDate.now())
       └─> SQL: SELECT SUM(total_money) FROM orders WHERE DATE(order_date) = today
   ↓
Response: TodayOverviewDTO {
  ordersToday: 15,
  revenueToday: 5000000.0
}
   ↓
Frontend: Cập nhật this.ordersToday và this.dailyRevenue
```

#### Call 2: Dashboard Stats
```
Frontend: orderService.getDashboardStats()
   ↓
HTTP GET: /api/orders/dashboard-stats
   ↓
Backend: OrderController.getDashboardStats()
   ↓
Backend: OrderService.getDashboardStats()
   ↓
   ├─> OrderRepository.calculateTotalRevenue()
   │   └─> SQL: SELECT SUM(total_money - discount_amount) FROM orders
   │
   ├─> OrderRepository.countOrdersByDate(LocalDate.now())
   │   └─> SQL: SELECT COUNT(*) FROM orders WHERE DATE(order_date) = today
   │
   └─> OrderRepository.countTotalProductsSold()
       └─> SQL: SELECT SUM(number_of_products) FROM order_details JOIN orders
   ↓
Response: DashboardStatsDTO {
  totalRevenue: 500000000,
  todayOrders: 15,
  totalProductsSold: 1200
}
   ↓
Frontend: Cập nhật this.totalRevenue và this.soldProducts
```

#### Call 3: Product Statistics
```
Frontend: statisticsService.getProductStatistics()
   ↓
HTTP GET: /api/statistics/product-statistics
   ↓
Backend: StatisticsController.getProductStatistics()
   ↓
Backend: StatisticsService.getProductStatistics()
   ↓
   ├─> ProductRepository.count()
   │   └─> SQL: SELECT COUNT(*) FROM products
   │
   ├─> OrderDetailRepository.countSoldProducts()
   │   └─> SQL: SELECT COUNT(DISTINCT product_id) FROM order_details
   │
   └─> ProductRepository.sumTotalQuantity()
       └─> SQL: SELECT SUM(quantity) FROM products
   ↓
Response: ProductStatisticsDTO {
  totalProducts: 500,
  soldProducts: 450,
  availableProducts: 5000
}
   ↓
Frontend: Cập nhật this.totalProducts và this.availableProducts
```

#### Call 4: Top Stock Products
```
Frontend: statisticsService.getTopStockProducts(10)
   ↓
HTTP GET: /api/statistics/top-stock-products?topN=10
   ↓
Backend: StatisticsController.getTopStockProducts(10)
   ↓
Backend: StatisticsService.getTopStockProducts(10)
   ↓
   └─> ProductRepository.findTopProductsByStock(PageRequest.of(0, 10))
       └─> SQL: SELECT id, name, thumbnail, quantity, price, category.name 
                FROM products ORDER BY quantity DESC LIMIT 10
   ↓
Response: List<TopStockProductDTO> [
  {id: 1, name: "Khóa vân tay Samsung", quantity: 100, ...},
  ...
]
   ↓
Frontend: Cập nhật this.topStockProducts
```

#### Call 5-7: Revenue Charts (Song song)
```
5. onDateRangeSelect() → getRevenueByDateRange()
6. onMonthRangeSelect() → getRevenueByMonthRange()
7. onYearRangeSelect() → getRevenueByYearRange()
```

---

## 2. Thống kê Doanh thu

### 2.1. Doanh thu theo khoảng ngày

**Trigger**: User chọn date range trong calendar

```
Frontend: AdminDashboardComponent.onDateRangeSelect()
   ↓
   ├─> Lấy startDate và endDate từ this.dateRange
   ├─> Format: "2025-01-01"
   ↓
Frontend: statisticsService.getRevenueByDateRange(startDate, endDate)
   ↓
HTTP GET: /api/statistics/revenue-by-date-range?startDate=2025-01-01&endDate=2025-01-31
   ↓
Backend: StatisticsController.getRevenueByDateRange(startDate, endDate)
   ↓
Backend: StatisticsService.getRevenueByDateRange(startDate, endDate)
   ↓
   └─> OrderRepository.getRevenueByDateRange(startDate, endDate)
       └─> SQL: SELECT DATE(order_date), SUM(total_money - discount_amount)
                FROM orders
                WHERE DATE(order_date) BETWEEN startDate AND endDate
                GROUP BY DATE(order_date)
                ORDER BY DATE(order_date)
   ↓
Response: List<DailyRevenueDTO> [
  {date: "2025-01-01", revenue: 5000000.0},
  {date: "2025-01-02", revenue: 7500000.0},
  ...
]
   ↓
Frontend: updateDailyChart(data)
   ├─> Chuyển đổi data thành format cho Chart.js
   ├─> Cập nhật labels và datasets
   └─> Render chart
```

### 2.2. Doanh thu theo khoảng tháng

**Trigger**: User chọn month range

```
Frontend: AdminDashboardComponent.onMonthRangeSelect()
   ↓
   ├─> Lấy startMonth và endMonth từ this.monthRange
   ├─> Format: "2025-01" (YYYY-MM)
   ↓
Frontend: statisticsService.getRevenueByMonthRange(startMonth, endMonth)
   ↓
HTTP GET: /api/statistics/revenue-by-month-range?startMonth=2025-01&endMonth=2025-12
   ↓
Backend: StatisticsController.getRevenueByMonthRange(startMonth, endMonth)
   ↓
Backend: StatisticsService.getRevenueByMonthRange(startMonth, endMonth)
   ↓
   ├─> Parse startMonth và endMonth thành YearMonth
   ├─> Chuyển thành LocalDate (startDate = first day, endDate = last day)
   ↓
   └─> OrderRepository.getRevenueByMonthRange(startDate, endDate)
       └─> SQL: SELECT YEAR(order_date), MONTH(order_date), 
                SUM(total_money - discount_amount)
                FROM orders
                WHERE order_date BETWEEN startDate AND endDate
                GROUP BY YEAR(order_date), MONTH(order_date)
                ORDER BY YEAR(order_date), MONTH(order_date)
   ↓
Response: List<MonthlyRevenueDTO> [
  {month: "2025-01", revenue: 150000000.0},
  {month: "2025-02", revenue: 180000000.0},
  ...
]
   ↓
Frontend: updateMonthlyChart(data)
   └─> Render monthly chart
```

### 2.3. Doanh thu theo khoảng năm

**Trigger**: User chọn year range

```
Frontend: AdminDashboardComponent.onYearRangeSelect()
   ↓
   ├─> Lấy startYear và endYear từ this.yearRange
   ├─> Format: "2020", "2025"
   ↓
Frontend: statisticsService.getRevenueByYearRange(startYear, endYear)
   ↓
HTTP GET: /api/statistics/revenue-by-year-range?startYear=2020&endYear=2025
   ↓
Backend: StatisticsController.getRevenueByYearRange(startYear, endYear)
   ↓
Backend: StatisticsService.getRevenueByYearRange(startYear, endYear)
   ↓
   └─> OrderRepository.getRevenueByYearRange(startYear, endYear)
       └─> SQL: SELECT YEAR(order_date), SUM(total_money - discount_amount)
                FROM orders
                WHERE YEAR(order_date) BETWEEN startYear AND endYear
                GROUP BY YEAR(order_date)
                ORDER BY YEAR(order_date)
   ↓
Response: List<YearlyRevenueDTO> [
  {year: "2020", revenue: 2000000000.0},
  {year: "2021", revenue: 2500000000.0},
  ...
]
   ↓
Frontend: updateYearlyChart(data)
   └─> Render yearly chart
```

---

## 3. Thống kê Sản phẩm

### 3.1. Top sản phẩm bán chạy (Tất cả thời gian)

**Trigger**: Component load hoặc user click refresh

```
Frontend: statisticsService.getTopProductSold(10)
   ↓
HTTP GET: /api/statistics/top-product-sold?topN=10
   ↓
Backend: StatisticsController.getTopProductSold(10, null, null)
   ↓
Backend: StatisticsService.getTopProductSold(10)
   ↓
   └─> OrderDetailRepository.getBestSellingProductsNative(10)
       └─> SQL: SELECT p.id, p.name, 
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
                LIMIT 10
   ↓
Response: List<ProductSoldStatisticsDTO> [
  {
    productId: 1,
    productName: "Khóa vân tay Samsung SHP-DH538",
    totalSold: 150
  },
  ...
]
   ↓
Frontend: Hiển thị trong bảng "Top sản phẩm bán chạy"
```

### 3.2. Top sản phẩm bán chạy (Theo khoảng thời gian)

**Trigger**: User chọn date range và click "Xem thống kê"

```
Frontend: statisticsService.getTopProductSoldByDateRange(10, startDate, endDate)
   ↓
HTTP GET: /api/statistics/top-product-sold?topN=10&startDate=2025-01-01&endDate=2025-01-31
   ↓
Backend: StatisticsController.getTopProductSold(10, startDate, endDate)
   ↓
   ├─> Kiểm tra: startDate != null && endDate != null
   └─> Gọi: StatisticsService.getTopProductSoldByDateRange(10, startDate, endDate)
   ↓
   └─> OrderDetailRepository.getBestSellingProductsByDateRange(startDate, endDate, 10)
       └─> SQL: SELECT p.id, p.name, 
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
                LIMIT 10
   ↓
Response: List<ProductSoldStatisticsDTO> [...]
   ↓
Frontend: Cập nhật bảng sản phẩm bán chạy
```

### 3.3. Sản phẩm bán theo ngày

**Trigger**: User chọn một ngày cụ thể

```
Frontend: statisticsService.getProductSoldByDate(selectedDate)
   ↓
HTTP GET: /api/statistics/product-sold-by-date?date=2025-01-15
   ↓
Backend: StatisticsController.getProductSoldByDate(date)
   ↓
Backend: StatisticsService.getProductSoldByDate(date)
   ↓
   └─> OrderDetailRepository.getProductSoldByDate(date)
       └─> SQL: SELECT od.product_id, p.name, SUM(od.number_of_products)
                FROM order_details od
                JOIN orders o ON od.order_id = o.id
                JOIN products p ON od.product_id = p.id
                WHERE DATE(o.order_date) = DATE(:date)
                AND o.status IN ('pending', 'shipped', 'delivered')
                AND o.active = true
                GROUP BY od.product_id, p.name
                HAVING SUM(od.number_of_products) > 0
                ORDER BY SUM(od.number_of_products) DESC
   ↓
Response: List<ProductSoldStatisticsDTO> [...]
   ↓
Frontend: Hiển thị danh sách sản phẩm bán trong ngày
```

### 3.4. Sản phẩm bán theo tháng

```
Frontend: statisticsService.getProductSoldByMonth(year, month)
   ↓
HTTP GET: /api/statistics/product-sold-by-month?year=2025&month=1
   ↓
Backend: StatisticsController.getProductSoldByMonth(year, month)
   ↓
Backend: StatisticsService.getProductSoldByMonth(year, month)
   ↓
   └─> OrderDetailRepository.getProductSoldByMonth(year, month)
       └─> SQL: SELECT od.product_id, p.name, SUM(od.number_of_products)
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
   ↓
Response: List<ProductSoldStatisticsDTO> [...]
```

### 3.5. Sản phẩm bán theo năm

```
Frontend: statisticsService.getProductSoldByYear(year)
   ↓
HTTP GET: /api/statistics/product-sold-by-year?year=2025
   ↓
Backend: StatisticsController.getProductSoldByYear(year)
   ↓
Backend: StatisticsService.getProductSoldByYear(year)
   ↓
   └─> OrderDetailRepository.getProductSoldByYear(year)
       └─> SQL: SELECT od.product_id, p.name, SUM(od.number_of_products)
                FROM order_details od
                JOIN orders o ON od.order_id = o.id
                JOIN products p ON od.product_id = p.id
                WHERE YEAR(o.order_date) = :year
                AND o.status IN ('pending', 'shipped', 'delivered')
                AND o.active = true
                GROUP BY od.product_id, p.name
                HAVING SUM(od.number_of_products) > 0
                ORDER BY SUM(od.number_of_products) DESC
   ↓
Response: List<ProductSoldStatisticsDTO> [...]
```

---

## 4. Thống kê Thương hiệu

### 4.1. Top thương hiệu bán chạy (Tất cả thời gian)

```
Frontend: statisticsService.getTopBrandsSold(10)
   ↓
HTTP GET: /api/statistics/top-brands-sold?topN=10
   ↓
Backend: StatisticsController.getTopBrandsSold(10, null, null)
   ↓
Backend: StatisticsService.getTopBrandsSold(10)
   ↓
   └─> OrderDetailRepository.getBestSellingBrandsNative(10)
       └─> SQL: SELECT c.id, c.name,
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
                LIMIT 10
   ↓
Response: List<BrandSoldStatisticsDTO> [
  {
    brandId: 1,
    brandName: "SAMSUNG",
    totalSold: 500,
    totalRevenue: 50000000.0
  },
  ...
]
   ↓
Frontend: Hiển thị trong bảng "Top thương hiệu bán chạy"
```

### 4.2. Top thương hiệu bán chạy (Theo khoảng thời gian)

```
Frontend: statisticsService.getTopBrandsSoldByDateRange(10, startDate, endDate)
   ↓
HTTP GET: /api/statistics/top-brands-sold?topN=10&startDate=2025-01-01&endDate=2025-01-31
   ↓
Backend: StatisticsController.getTopBrandsSold(10, startDate, endDate)
   ↓
Backend: StatisticsService.getTopBrandsSoldByDateRange(10, startDate, endDate)
   ↓
   └─> OrderDetailRepository.getBestSellingBrandsByDateRange(startDate, endDate, 10)
       └─> SQL: SELECT c.id, c.name,
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
                LIMIT 10
   ↓
Response: List<BrandSoldStatisticsDTO> [...]
```

---

## 5. AI Dashboard Insights

### 5.1. Generate Dashboard Insights

**Trigger**: User click button "Phân tích ngay"

```
Frontend: AdminDashboardComponent.generateInsights()
   ├─> Set isAnalyzing = true
   ↓
Frontend: aiChatService.generateDashboardInsights()
   ↓
HTTP POST: /api/ai/dashboard-insights
   ↓
Backend: AIChatController.generateDashboardInsights()
   ↓
Backend: Thu thập dữ liệu thống kê:
   ├─> StatisticsService.getTodayOverview()
   │   └─> Trả về: ordersToday, revenueToday
   │
   ├─> StatisticsService.getRevenueByDateRange(30 days ago, today)
   │   └─> Trả về: List<DailyRevenueDTO>
   │
   └─> StatisticsService.getTopProductSold(5)
   │   └─> Trả về: List<ProductSoldStatisticsDTO>
   ↓
Backend: Tạo statsContext string:
   """
   --- TỔNG QUAN HÔM NAY ---
   - Đơn hàng hôm nay: 15
   - Doanh thu hôm nay: 5,000,000 VND
   
   --- XU HƯỚNG DOANH THU (30 NGÀY QUA) ---
   - Tổng doanh thu 30 ngày: 150,000,000 VND
   Chi tiết doanh thu từng ngày:
     + Ngày 2025-01-01: 5,000,000 VND
     ...
   
   --- TOP 5 SẢN PHẨM BÁN CHẠY ---
   - Khóa vân tay Samsung SHP-DH538 (Đã bán: 150)
   ...
   """
   ↓
Backend: AIProductAssistantService.generateDashboardInsights(statsContext)
   ├─> Tạo prompt với statsContext
   ├─> Gọi OpenAI API (GPT-4)
   └─> Nhận response từ AI
   ↓
Response: {
  insights: "Dựa trên dữ liệu thống kê...",
  success: true,
  timestamp: 1234567890
}
   ↓
Frontend: 
   ├─> Set isAnalyzing = false
   ├─> Set aiInsights = response.insights
   └─> Hiển thị insights trong markdown format
```

---

## 📊 Tổng kết Flow

### Thứ tự thực hiện khi load Dashboard:

1. **Component khởi tạo** (ngOnInit)
2. **Gọi loadDashboardData()** - Thực hiện 4 API calls song song:
   - Today Overview
   - Dashboard Stats
   - Product Statistics
   - Top Stock Products
3. **Khởi tạo date ranges** (30 ngày, tháng, năm)
4. **Load charts** (3 API calls song song):
   - Revenue by Date Range
   - Revenue by Month Range
   - Revenue by Year Range

### Xử lý lỗi:

```
Mỗi API call đều có error handler:
   ↓
catch error
   ↓
Set giá trị mặc định (0 hoặc [])
   ↓
Log error ra console
   ↓
UI vẫn hiển thị (không crash)
```

### Caching và Performance:

- **Frontend**: Sử dụng RxJS observables để quản lý async calls
- **Backend**: 
  - Native SQL queries để tối ưu performance
  - Sử dụng COALESCE để tránh NULL
  - Filter theo status và active để chỉ lấy dữ liệu hợp lệ

---

## 🔄 Luồng dữ liệu tổng quát

```
User Action
   ↓
Frontend Component
   ↓
Service (Frontend) - HTTP Request
   ↓
Controller (Backend) - @GetMapping/@PostMapping
   ↓
Service (Backend) - Business Logic
   ↓
Repository - @Query
   ↓
Database - SQL Execution
   ↓
Repository - Map Results
   ↓
Service - Transform to DTO
   ↓
Controller - ResponseEntity
   ↓
Service (Frontend) - HTTP Response
   ↓
Component - Update UI
   ↓
User sees updated data
```

---

## 📝 Ghi chú

1. **Tất cả các API calls đều bất đồng bộ** (async/await hoặc Observable)
2. **Các calls độc lập có thể chạy song song** để tối ưu thời gian load
3. **Error handling** được thực hiện ở mỗi level để đảm bảo UI không crash
4. **Data transformation** xảy ra ở Service layer để tách biệt business logic
5. **DTOs** được sử dụng để đảm bảo type safety và API contract

