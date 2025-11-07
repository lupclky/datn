# 📚 Use Case Catalog — Locker Korea (Smart Lock Store)

Updated: 2025-11-06

This document summarizes all use cases discovered from the codebase (Angular Frontend + Spring Boot Backend) and project guides. Each use case lists the actor, intent, main UI routes/components, and key backend endpoints when applicable.

## 🧩 Scope overview

- Domains: Catalog & Search, Cart & Checkout, Orders & Returns, Authentication & Profile, Reviews, Content (News), Banners, Vouchers, Product Features, Staff/Customer Chat, Statistics/Dashboard, AI Assistant (chat, image, warranty, diagnosis), Payments (Stripe/VNPay), Admin management modules.
- Tech: Angular 17 (SSR), Spring Boot 3 (Java 17), MySQL, Stripe & VNPay, Google Vertex AI + ChromaDB.

## 👥 Actors

- Guest/Visitor (chưa đăng nhập)
- Customer/User (đã đăng nhập: ROLE_USER)
- Staff/Support (StaffGuard)
- Admin (ROLE_ADMIN)
- System/AI (tác vụ nền, AI endpoints)

---

## Guest / Visitor

1) Duyệt Home và Banner
- Mục tiêu: Xem banner, nhấn CTA tới danh mục/sản phẩm.
- UI: `/Home` — `features/components/home/`, `banner` carousel.
- Backend: Banner APIs
  - GET `/api/v1/banners/active`, GET `/api/v1/banners`
- Tài liệu: `BANNER_IMAGE_GUIDE.md`, `BANNER_TROUBLESHOOTING.md`

2) Duyệt Catalog, xem chi tiết sản phẩm
- Mục tiêu: Xem danh sách, lọc, tìm kiếm, chi tiết sản phẩm và ảnh.
- UI:
  - `/allProduct` — `features/components/all-product/`
  - `/detailProduct/:id` — `features/components/detail-product/`
- Backend: Product APIs (see `ProductController.java`)
  - GET `/api/v1/products` (paging/filter), `/api/v1/products/{id}`
  - GET `/api/v1/products/search`, `/api/v1/products/price`, `/api/v1/products/category/{id}`
  - GET `/api/v1/products/images/{imageName}`

3) Đọc Tin tức (News)
- Mục tiêu: Xem danh sách và chi tiết tin đã xuất bản, tìm kiếm, theo danh mục.
- UI: `/news`, `/news/:id` — `features/components/news/`, `news-detail/`
- Backend: News (public)
  - GET `/api/v1/news/published` (list), `/api/v1/news/published/{id}` (view+auto-increment view)
  - GET `/api/v1/news/published/search?keyword=...`, `/api/v1/news/published/category/{category}`
- Tài liệu: `NEWS_FEATURE_IMPLEMENTATION.md`

4) Đăng ký / Đăng nhập / Quên mật khẩu / Đặt lại mật khẩu
- UI: `/auth-login`, `/register`, `/forgot-password`, `/reset-password`
- Backend: User/Auth (see `UserController.java`)
  - POST `/api/v1/users/register`, `/api/v1/users/login`
  - POST `/api/v1/users/forgot-password`, `/api/v1/users/reset-password`

5) AI Chatbot tư vấn sản phẩm (khách có thể sử dụng)
- Mục tiêu: Hỏi đáp tư vấn khóa điện tử, tìm sản phẩm theo tính năng/giá, phân tích ảnh.
- UI: Floating chatbot component (Angular) — `ai-chatbot.*`
- Backend (see `ai/controllers/AIChatController.java`)
  - POST `/api/v1/ai/chat/product-assistant`, `/text`, `/image`
- Tài liệu: `README_CHATBOT.md`, `AI_CHATBOT_GUIDE.md`

---

## Customer / User (đăng nhập)

6) Quản lý giỏ hàng
- Mục tiêu: Thêm/sửa/xóa, xem giỏ.
- UI: `/shoppingCart` — `features/components/shopping-cart/`
- Backend: `CartController.java`
  - POST `/api/v1/carts` (add), GET `/api/v1/carts`, PUT `/api/v1/carts/{id}`, DELETE `/api/v1/carts/{id}`, DELETE `/api/v1/carts` (clear)

7) Áp dụng Voucher vào đơn hàng
- UI: trong giỏ/checkout; `voucher-display/` (trang hiển thị), áp dụng mã
- Backend: `VoucherController.java`
  - GET `/api/v1/vouchers/homepage`, GET `/api/v1/vouchers/code/{code}`, POST `/api/v1/vouchers/apply`

8) Đặt hàng và Thanh toán
- Mục tiêu: Tạo order, thanh toán Stripe hoặc VNPay.
- UI: `/order` — `features/components/order/`; `/order-detail/:id`
- Backend: `OrderController.java`
  - POST `/api/v1/orders` (create), GET `/api/v1/orders/user`, GET `/api/v1/orders/{id}`
  - PUT `/api/v1/orders/{id}` | `/status/{id}` | `/update/{id}`
- Payment:
  - Stripe (`StripeController.java`): POST `/api/v1/payments/stripe/create-payment-intent`, `/confirm-payment/{id}`, `/create-setup-intent`, GET `/config`
  - VNPay (`VnpayController.java`): POST `/api/v1/payments/vnpay/create-payment`, POST `/refund`, GET `/payment-callback`

9) Xem lịch sử, chi tiết đơn hàng
- UI: `/history`, `/order-detail/:id` — `history-order/`, `order-detail/`
- Backend: GET `/api/v1/orders/user`, `/api/v1/orders/{id}`

10) Yêu cầu đổi/trả (Return Request) và theo dõi
- UI: `/return-request/:orderId`, `/my-returns`
- Backend: `ReturnController.java`
  - POST `/api/v1/returns` (create), GET `/api/v1/returns/my-requests`

11) Đánh giá sản phẩm (Reviews)
- UI: trong trang chi tiết sản phẩm – form comment/rating; quản lý review của mình
- Backend: `ReviewController.java`
  - POST `/api/v1/reviews` (create), PUT `/api/v1/reviews/{id}`, DELETE `/api/v1/reviews/{id}`
  - GET `/api/v1/reviews/product/{productId}`, `/paginated`, `/stats`

12) Hồ sơ người dùng và bảo mật tài khoản
- UI: `/user-profile`, `/change-password`
- Backend: `UserController.java`
  - GET `/api/v1/users/details`, PUT `/api/v1/users/details/{userId}`
  - POST `/api/v1/users/change-password`

13) Chat với nhân viên hỗ trợ (Customer-Staff Chat)
- UI: `customer-chat/` component (entry từ layout/chat icon)
- Backend: `ChatController.java`
  - POST `/api/v1/chat/send`, GET `/conversation/{otherUserId}`, GET `/messages`, GET `/unread`, POST `/send-file` (multipart)

---

## Staff / Support

14) Quản lý hội thoại khách hàng (Staff workspace)
- UI: `/staff/chat` — `features/components/staff-chat/` (StaffGuard)
- Backend: `ChatController.java`
  - GET `/api/v1/chat/staff/customers`, PUT `/read/{messageId}`, PUT `/read-all`, PUT `/close/{customerId}`

---

## Admin

15) Quản lý Sản phẩm (CRUD + ảnh)
- UI: `/productManage`, `/uploadProduct` — `product-manage/`, `upload-product/`
- Backend: `ProductController.java`
  - POST `/api/v1/products` (create), POST `/uploads/{id}` (multipart)
  - GET `/api/v1/products`, `/all`, `/by-ids`, `/related/{productId}`
  - PUT `/api/v1/products/{id}`, DELETE `/api/v1/products/{id}`
  - DELETE `/api/v1/products/images/{id}`

16) Quản lý Danh mục (Category)
- UI: `/categoryManage` — `category-manage/`
- Backend: `CategoryController.java` (CRUD)
  - POST/GET/PUT/DELETE `/api/v1/categories`, `/api/v1/categories/{id}`

17) Quản lý Tính năng khóa (Lock Features) và gán vào sản phẩm
- UI: `/featureManage` — `features/components/feature-manage/`
- Backend:
  - `LockFeatureController.java`: GET `/api/v1/lock-features`, `/active`, POST/PUT/DELETE
  - `ProductFeatureController.java`: POST `/product/{productId}`, GET `/product/{productId}`, DELETE `/product/{productId}/feature/{featureId}`

18) Quản lý Người dùng & Phân quyền
- UI: `/userManage` — `user-manage/`
- Backend: `UserController.java`
  - GET `/api/v1/users/getAll`, GET `/find`, PUT `/change-active/{userId}`, PUT `/changeRole/{userId}`, DELETE `/delete/{id}`
  - GET `/api/v1/roles` (RoleController)

19) Quản lý Đơn hàng
- UI: `/orderManage` — `order-manage/`
- Backend: `OrderController.java`
  - GET `/api/v1/orders/admin` (list), PUT `/status/{id}`, DELETE `/api/v1/orders/{id}`

20) Quản lý Đánh giá (Reviews)
- UI: `/reviewManage` — `review-manage/`
- Backend: `ReviewController.java`
  - GET `/api/v1/reviews/admin/all`, DELETE/PUT review

21) Quản lý Voucher
- UI: `/voucherManage`, trang hiển thị: `voucher-display/`
- Backend: `VoucherController.java`
  - POST/GET/PUT/DELETE `/api/v1/vouchers` và GET `/homepage`, GET `/search`

22) Quản lý Banner trang chủ
- UI: `/bannerManage` — `banner-manage/`
- Backend: `BannerController.java`
  - GET `/api/v1/banners`, `/active`, POST `/`, PUT `/{id}`, DELETE `/{id}`
  - POST `/upload` (multipart), GET `/images/{imageName}`
- Tài liệu: `BANNER_IMAGE_GUIDE.md`, `BANNER_TROUBLESHOOTING.md`

23) Quản lý Tin tức (News)
- UI: `/newsManage` — `news-manage/`
- Backend: `NewsController.java`
  - Admin: GET `/admin/all`, GET `/admin/{id}`, POST `/admin`, PUT `/admin/{id}`, PUT `/admin/{id}/publish`, `/archive`, DELETE `/admin/{id}`
- Tài liệu: `NEWS_FEATURE_IMPLEMENTATION.md`

24) Quản lý Yêu cầu đổi/trả
- UI: `/admin/returns` — `return-manage/`
- Backend: `ReturnController.java`
  - Admin: GET `/api/v1/returns/admin/all`, PUT `/admin/{id}/approve`, `/reject`, `/complete-refund`

25) Thống kê & Dashboard
- UI: `features/statistics-product/`, `features/best-selling-statistics/` (nếu có trong menu admin)
- Backend: `StatisticsController.java`
  - GET `/api/v1/statistics/daily-revenue/{date}`, `/revenue-by-*`, `/product-*`, `/today-overview`, `/orders-today`, `/top-*`

26) Tích hợp AI cho nội dung & chỉ mục
- Tác vụ Admin: Khởi tạo/chỉ mục dữ liệu sản phẩm cho vector search
- Backend: `ai/controllers/AIInitializationController.java`, `VectorSearchController.java`
  - POST `/api/v1/ai/initialize/index-all`, GET `/status`, DELETE `/clear-index`
  - GET `/api/v1/ai/search/products*`, POST `/index/all-products`, `/index/all-categories`

---

## System / AI Use Cases

27) AI tư vấn sản phẩm, tìm kiếm ngữ nghĩa, khuyến nghị
- POST `/api/v1/ai/chat/product-assistant` (+ by-category, compare, recommend)
- GET vector search `/api/v1/ai/search/products*`

28) Phân tích hình ảnh sản phẩm (image → gợi ý tương tự)
- POST `/api/v1/ai/chat/image` (multipart)

29) Sinh nội dung Tin tức bằng AI
- POST `/api/v1/ai/chat/generate-news`
- Tài liệu: `AI_NEWS_GENERATOR_GUIDE.md`

30) Sinh mô tả sản phẩm bằng AI
- POST `/api/v1/ai/chat/generate-product-description`

31) Tư vấn Bảo hành bằng AI
- POST `/api/v1/ai/chat/warranty-advice`
- Tài liệu: `AI_WARRANTY_DIAGNOSTIC_GUIDE.md`

32) Chẩn đoán lỗi khóa bằng AI
- POST `/api/v1/ai/chat/diagnose-issue`
- Tài liệu: `AI_WARRANTY_DIAGNOSTIC_GUIDE.md`

33) Tự động chỉ mục dữ liệu khi CRUD sản phẩm (listener)
- Product events → cập nhật ChromaDB (see AI guide notes)

---

## Data model (tóm tắt chính)

Tables (from `Backend/shopsneaker3.sql`): `products`, `product_images`, `categories`, `orders`, `order_details`, `carts`, `users`, `roles`, `reviews`, `vouchers`, `voucher_usage`, `banners`, `news`, `return_requests`, `lock_features`, `product_features`, plus auth tables (`tokens`, `social_accounts`).

---

## Notes & References

- Frontend routes: `Frontend/src/app/app.routes.ts`
- Notable components (Frontend/src/app/features/components):
  `home/`, `all-product/`, `detail-product/`, `shopping-cart/`, `order/`, `order-detail/`, `history-order/`, `return-request/`, `my-returns/`, `user-profile/`, `change-password/`, `customer-chat/`, `staff-chat/`, `voucher-display/`;
  Admin: `product-manage/`, `upload-product/`, `category-manage/`, `user-manage/`, `order-manage/`, `review-manage/`, `voucher-manage/`, `banner-manage/`, `news-manage/`, `return-manage/`.
- Backend controllers (Backend/src/main/java/com/example/Sneakers/controllers and ai/controllers):
  `ProductController`, `CategoryController`, `CartController`, `OrderController`, `OrderDetailController`, `VoucherController`, `ReviewController`, `NewsController`, `BannerController`, `ReturnController`, `ChatController`, `LockFeatureController`, `ProductFeatureController`, `StatisticsController`, `StripeController`, `VnpayController`, AI: `AIChatController`, `AIInitializationController`, `VectorSearchController`.

---

## Future/Planned (per docs)

- AI Chatbot: Voice I/O, multi-language, chat history, preference learning.
- News AI: content templates, SEO helpers, scheduling, plagiarism check, multi-language.
- More analytics dashboards; deeper integration of AI recommendations into product listing.

---

If you want this catalog broken down into UML Use Case diagrams or clickable documentation with deep links, let me know and I’ll generate it next.
