# LockerKorea - Thiết kế Cơ sở Dữ liệu

## Sơ đồ ER (Entity Relationship Diagram)

```mermaid
erDiagram
    %% Bảng Quản lý Người dùng
    roles ||--o{ users : "có"
    users ||--o{ orders : "đặt"
    users ||--o{ carts : "có"
    users ||--o{ reviews : "viết"
    users ||--o{ voucher_usage : "sử dụng"
    users ||--o{ orders : "được gán xử lý"
    users ||--o{ reviews : "phản hồi"

    %% Bảng Quản lý Sản phẩm
    categories ||--o{ products : "chứa"
    products ||--o{ product_features : "có"
    products ||--o{ product_images : "có"
    products ||--o{ order_details : "trong"
    products ||--o{ carts : "trong"
    products ||--o{ reviews : "được đánh giá"
    lock_features ||--o{ product_features : "thuộc"

    %% Bảng Quản lý Đơn hàng
    orders ||--o{ order_details : "chứa"
    orders ||--o{ return_requests : "có yêu cầu"
    orders ||--o{ voucher_usage : "sử dụng"
    vouchers ||--o{ orders : "áp dụng"
    vouchers ||--o{ voucher_usage : "được sử dụng"

    %% Định nghĩa các bảng
    roles {
        int id PK
        varchar name
    }

    users {
        int id PK
        varchar fullname
        varchar phone_number
        varchar email UK
        varchar address
        varchar password
        datetime created_at
        datetime updated_at
        tinyint is_active
        datetime date_of_birth
        int facebook_account_id
        int google_account_id
        int role_id FK
        varchar reset_password_token
        datetime reset_password_token_expiry
    }

    categories {
        int id PK
        varchar name
    }

    products {
        int id PK
        varchar name
        bigint price
        varchar thumbnail
        longtext description
        datetime created_at
        datetime updated_at
        int category_id FK
        bigint discount
        bigint quantity
    }

    lock_features {
        bigint id PK
        varchar name
        text description
        tinyint is_active
        datetime created_at
        datetime updated_at
    }

    product_features {
        bigint id PK
        int product_id FK
        bigint feature_id FK
        datetime created_at
        datetime updated_at
    }

    product_images {
        bigint id PK
        int product_id FK
        varchar image_url
    }

    orders {
        int id PK
        int user_id FK
        varchar fullname
        varchar email
        varchar phone_number
        varchar address
        varchar note
        datetime order_date
        varchar status
        bigint total_money
        varchar shipping_method
        date shipping_date
        varchar payment_method
        tinyint active
        int voucher_id FK
        bigint discount_amount
        varchar payment_intent_id
        varchar vnp_txn_ref
        varchar vnp_transaction_no
        varchar tracking_number
        varchar carrier
        int district_id
        varchar ward_code
        int assigned_staff_id FK
    }

    order_details {
        bigint id PK
        int order_id FK
        int product_id FK
        bigint price
        bigint number_of_products
        bigint total_money
        bigint size
    }

    return_requests {
        bigint id PK
        int order_id FK
        text reason
        varchar status
        decimal refund_amount
        text admin_notes
        timestamp created_at
        timestamp updated_at
    }

    carts {
        bigint id PK
        int user_id FK
        int product_id FK
        bigint quantity
        bigint size
        varchar session_id
    }

    vouchers {
        int id PK
        varchar code UK
        varchar name
        text description
        int discount_percentage
        bigint min_order_value
        bigint max_discount_amount
        int quantity
        int remaining_quantity
        datetime valid_from
        datetime valid_to
        tinyint is_active
        datetime created_at
        datetime updated_at
    }

    voucher_usage {
        bigint id PK
        int voucher_id FK
        int order_id FK
        int user_id FK
        bigint discount_amount
        datetime used_at
    }

    reviews {
        bigint id PK
        int product_id FK
        int user_id FK
        int rating
        text comment
        text staff_reply
        int staff_reply_by FK
        datetime staff_reply_at
        datetime created_at
        datetime updated_at
    }

    banners {
        bigint id PK
        varchar title
        varchar description
        varchar image_url
        varchar button_text
        varchar button_link
        varchar button_style
        int display_order
        tinyint is_active
        datetime start_date
        datetime end_date
        datetime created_at
        datetime updated_at
    }

    news {
        bigint id PK
        varchar title
        text content
        varchar summary
        varchar author
        varchar category
        enum status
        varchar featured_image
        bigint views
        datetime published_at
        datetime created_at
        datetime updated_at
        varchar thumbnail
        varchar facebook_post_id
        datetime facebook_scheduled_at
    }
```

## Mô tả các bảng chính

### 1. Quản lý Người dùng
- **roles**: Vai trò người dùng (USER, ADMIN, STAFF)
- **users**: Thông tin người dùng, hỗ trợ đăng nhập Facebook/Google

### 2. Quản lý Sản phẩm
- **categories**: Danh mục sản phẩm (GATEMAN, SAMSUNG, H-Gang, EPIC, WELKOM, etc.)
- **products**: Thông tin sản phẩm khóa điện tử
- **lock_features**: Tính năng của khóa (vân tay, PIN, thẻ từ, Bluetooth, WiFi, etc.)
- **product_features**: Liên kết sản phẩm với tính năng (Many-to-Many)
- **product_images**: Hình ảnh sản phẩm

### 3. Quản lý Đơn hàng
- **orders**: Đơn hàng với trạng thái (processing, shipped, delivered, cancelled, payment_failed)
- **order_details**: Chi tiết từng sản phẩm trong đơn hàng
- **return_requests**: Yêu cầu trả hàng/hoàn tiền

### 4. Quản lý Giỏ hàng
- **carts**: Giỏ hàng (hỗ trợ cả user đăng nhập và session)

### 5. Quản lý Voucher
- **vouchers**: Mã giảm giá với điều kiện sử dụng
- **voucher_usage**: Lịch sử sử dụng voucher

### 6. Quản lý Đánh giá
- **reviews**: Đánh giá sản phẩm từ khách hàng, có thể có phản hồi từ nhân viên

### 7. Quản lý Nội dung
- **banners**: Banner trang chủ
- **news**: Tin tức, bài viết

## Các mối quan hệ chính

1. **Users ↔ Roles**: Một người dùng có một vai trò
2. **Products ↔ Categories**: Một sản phẩm thuộc một danh mục
3. **Products ↔ Features**: Nhiều-nhiều (qua bảng product_features)
4. **Orders ↔ Users**: Một người dùng có nhiều đơn hàng
5. **Orders ↔ Products**: Nhiều-nhiều (qua bảng order_details)
6. **Orders ↔ Vouchers**: Một đơn hàng có thể sử dụng một voucher
7. **Reviews**: Liên kết Products và Users, có thể có phản hồi từ Staff

## Tính năng đặc biệt

- **Thanh toán**: Hỗ trợ VNPAY và Stripe (payment_intent_id, vnp_txn_ref)
- **Vận chuyển**: Tracking number và carrier (GHN)
- **Phân quyền**: 3 vai trò (USER, ADMIN, STAFF)
- **Đăng nhập xã hội**: Facebook và Google (facebook_account_id, google_account_id)
- **Quản lý đơn hàng**: Gán nhân viên xử lý (assigned_staff_id)
- **Tích hợp Facebook**: Đăng bài tin tức lên Facebook (facebook_post_id)

