# Các mục trình bày kiến trúc Deployment (Locker Korea)

Dưới đây là các đầu mục (bullet points) tóm tắt kiến trúc hệ thống dựa trên sơ đồ Deployment bạn cung cấp, phù hợp để đưa vào Slide thuyết trình.

## 1. Hạ tầng Cloud (Cloud Infrastructure)
*   **Nền tảng:** Google Cloud Platform (GCP).
*   **Mô hình:** Microservices kết hợp Monolithic (Backend Java + Python AI Service).

## 2. Backend Server (Compute Engine)
Nơi xử lý chính, bao gồm 3 thành phần chạy trên cùng một máy ảo (hoặc cụm):
*   **Spring Boot Runtime:** Core backend, xử lý nghiệp vụ bán hàng, quản lý user.
*   **Python Runtime:** Microservice chuyên biệt chạy model AI (Embedding Model).
*   **ChromaDB:** Vector Database lưu trữ dữ liệu hình ảnh/text để AI tìm kiếm nhanh.
*   *Giao tiếp nội bộ:* Qua TCP port 8000 (Chroma) và 9000 (Python).

## 3. Database Server
*   **Dịch vụ:** GCP Cloud SQL.
*   **Hệ quản trị:** MySQL.
*   *Kết nối:* Backend kết nối qua TCP port 3306.

## 4. Frontend Server
*   **Công nghệ:** Angular (SSR - Server Side Rendering).
*   **Thành phần:** Chứa cả Static Assets và SSR Server để tối ưu SEO.
*   *Giao tiếp:* Gọi REST API sang Backend Spring Boot.

## 5. Dịch vụ Bên ngoài (External Services)
*   **Gemini AI:** Tích hợp để sinh câu trả lời thông minh (Gen AI).
*   **Gmail SMTP:** Dùng để gửi email xác thực, thông báo đơn hàng.

## 6. Luồng truy cập (User Flow)
*   User truy cập qua trình duyệt (**Web Browser**).
*   Kết nối bảo mật **HTTPS** tới Frontend Server.
