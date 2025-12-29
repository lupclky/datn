# Hướng dẫn Cài đặt Azure Thủ công (Giao diện Web)

Tài liệu này hướng dẫn bạn tạo các tài nguyên Azure cần thiết cho dự án Locker Korea bằng giao diện web (Azure Portal), phù hợp với gói **Azure for Students**.

## 1. Đăng nhập Azure Portal
Truy cập [https://portal.azure.com](https://portal.azure.com) và đăng nhập bằng tài khoản sinh viên của bạn.

## 2. Tạo Resource Group (Nhóm tài nguyên)
Resource Group giúp quản lý tất cả tài nguyên của dự án trong một nơi.

1.  Tìm kiếm **"Resource groups"** trên thanh tìm kiếm.
2.  Nhấn **+ Create**.
3.  **Subscription**: Chọn *Azure for Students*.
4.  **Resource group**: Nhập `rg-lockerkorea`.
5.  **Region**: Chọn khu vực gần bạn (ví dụ: `Southeast Asia` hoặc `East Asia`).
6.  Nhấn **Review + create** -> **Create**.

## 3. Tạo App Service Plan (Gói dịch vụ ứng dụng)
Đây là máy chủ ảo sẽ chạy cả Frontend và Backend.

1.  Tìm kiếm **"App Service Plans"**.
2.  Nhấn **+ Create**.
3.  **Resource Group**: Chọn `rg-lockerkorea`.
4.  **Name**: Nhập `plan-lockerkorea`.
5.  **Operating System**: Chọn **Linux**.
6.  **Region**: Chọn cùng region với Resource Group (`Southeast Asia`).
7.  **Pricing Plan**:
    *   Nhấn **Explore pricing plans**.
    *   Chọn tab **Basic**.
    *   Chọn **B1** (Đây là gói rẻ nhất hỗ trợ tốt cho Java/Node.js và ổn định hơn gói Free F1).
    *   Nhấn **Select**.
8.  Nhấn **Review + create** -> **Create**.

## 4. Tạo Web App cho Frontend (Node.js)
1.  Tìm kiếm **"App Services"**.
2.  Nhấn **+ Create** -> **Web App**.
3.  **Resource Group**: Chọn `rg-lockerkorea`.
4.  **Name**: Nhập tên duy nhất, ví dụ: `lockerkorea-frontend-123` (thêm số ngẫu nhiên nếu bị trùng).
5.  **Publish**: Chọn **Code**.
6.  **Runtime stack**: Chọn **Node 18 LTS**.
7.  **Operating System**: **Linux**.
8.  **Region**: `Southeast Asia`.
9.  **Linux Plan**: Chọn `plan-lockerkorea` (đã tạo ở bước 3).
10. Nhấn **Review + create** -> **Create**.

## 5. Tạo Web App cho Backend (Java Spring Boot)
1.  Vào lại **"App Services"**.
2.  Nhấn **+ Create** -> **Web App**.
3.  **Resource Group**: Chọn `rg-lockerkorea`.
4.  **Name**: Nhập tên duy nhất, ví dụ: `lockerkorea-backend-123`.
5.  **Publish**: Chọn **Code**.
6.  **Runtime stack**: Chọn **Java 17**.
7.  **Java web server stack**: Chọn **Java SE (Embedded Web Server)**.
8.  **Operating System**: **Linux**.
9.  **Region**: `Southeast Asia`.
10. **Linux Plan**: Chọn `plan-lockerkorea`.
11. Nhấn **Review + create** -> **Create**.

## 6. Tạo MySQL Flexible Server (Cơ sở dữ liệu)
1.  Tìm kiếm **"Azure Database for MySQL flexible servers"**.
2.  Nhấn **+ Create**.
3.  **Resource Group**: Chọn `rg-lockerkorea`.
4.  **Server name**: Nhập tên, ví dụ: `lockerkorea-db-123`.
5.  **Region**: `Southeast Asia`.
6.  **Workload type**: Chọn **Development or Hobby projects**.
7.  **Compute + storage**:
    *   Nhấn **Configure server**.
    *   Chọn **Burstable** (B series).
    *   Chọn **Standard_B1ms** (Gói này tiết kiệm chi phí và đủ dùng).
    *   Nhấn **Save**.
8.  **MySQL version**: **8.0** (hoặc 5.7 tùy code của bạn, mặc định 8.0 là tốt).
9.  **Authentication**:
    *   Chọn **MySQL authentication only**.
    *   **Admin username**: `adminuser`.
    *   **Password**: Tạo mật khẩu mạnh (ví dụ: `LockerKorea@2025`). **Lưu lại mật khẩu này!**
10. Chuyển sang tab **Networking**:
    *   Tích chọn **Allow public access from any Azure service within Azure to this server** (Quan trọng để Backend kết nối được).
    *   Nhấn **+ Add current client IP address** (Để bạn có thể kết nối từ máy tính cá nhân).
11. Nhấn **Review + create** -> **Create**.

## 7. Tạo Storage Account (Lưu trữ ảnh)
1.  Tìm kiếm **"Storage accounts"**.
2.  Nhấn **+ Create**.
3.  **Resource Group**: Chọn `rg-lockerkorea`.
4.  **Storage account name**: Nhập tên duy nhất (chữ thường, không dấu, không khoảng trắng), ví dụ: `lockerkoreastore123`.
5.  **Region**: `Southeast Asia`.
6.  **Performance**: **Standard**.
7.  **Redundancy**: **Locally-redundant storage (LRS)** (Rẻ nhất).
8.  Nhấn **Review + create** -> **Create**.

### Tạo Container
1.  Sau khi tạo xong, nhấn **Go to resource**.
2.  Ở menu bên trái, chọn **Data storage** -> **Containers**.
3.  Nhấn **+ Container**.
4.  **Name**: `lockerkorea-images`.
5.  **Public access level**: Chọn **Blob (anonymous read access for blobs only)** (Để người dùng xem được ảnh).
6.  Nhấn **Create**.

## 8. Lấy thông tin cấu hình (Để điền vào GitHub Secrets)
Sau khi tạo xong, bạn cần lấy các thông tin sau để cấu hình CI/CD:

1.  **Tên Web App Frontend**: (Ví dụ: `lockerkorea-frontend-123`)
2.  **Tên Web App Backend**: (Ví dụ: `lockerkorea-backend-123`)
3.  **MySQL Hostname**: Vào MySQL resource -> Overview -> Server name (Ví dụ: `lockerkorea-db-123.mysql.database.azure.com`).
4.  **Storage Account Name & Key**:
    *   Vào Storage Account -> Security + networking -> **Access keys**.
    *   Copy **Key 1**.

## 9. (Tùy chọn) Tạo Azure Container Instances (Cho AI & ChromaDB)
Thông thường, CI/CD pipeline sẽ tự động tạo các container này. Tuy nhiên, nếu bạn muốn tạo thủ công để test hoặc đảm bảo chúng tồn tại trước:

### A. Tạo ChromaDB (Cơ sở dữ liệu Vector)
1.  Tìm kiếm **"Container instances"**.
2.  Nhấn **+ Create**.
3.  **Resource Group**: `rg-lockerkorea`.
4.  **Container name**: `lockerkorea-chroma`.
5.  **Region**: `Southeast Asia`.
6.  **Image source**: **Other registry**.
7.  **Image**: `chromadb/chroma:latest` (Image chính thức từ Docker Hub).
8.  **OS type**: **Linux**.
9.  **Size**: Để mặc định (1 vCPU, 1.5 GiB memory) là đủ.
10. Chuyển sang tab **Networking**:
    *   **Networking type**: **Public**.
    *   **DNS name label**: Nhập tên duy nhất, ví dụ: `lockerkorea-chroma-123` (Đây sẽ là địa chỉ truy cập).
    *   **Ports**: Thêm port **8000** (TCP).
11. Nhấn **Review + create** -> **Create**.
12. **Lưu địa chỉ**: `http://lockerkorea-chroma-123.southeastasia.azurecontainer.io:8000` (Dùng cho biến `CHROMA_BASE_URL` ở Backend).

### B. Tạo Python Embedding Service
*Lưu ý: Bạn cần có Docker Image của service này trên Docker Hub trước. Nếu chưa có, hãy để CI/CD pipeline chạy lần đầu để build và tạo tự động.*

Nếu bạn đã có image (ví dụ: `username/lockerkorea-python:latest`):
1.  Tạo Container Instance tương tự như trên.
2.  **Container name**: `lockerkorea-python`.
3.  **Image**: `username/lockerkorea-python:latest` (Thay username bằng tài khoản Docker Hub của bạn).
4.  **Networking**:
    *   **DNS name label**: Ví dụ `lockerkorea-python-123`.
    *   **Ports**: **8000**.
5.  **Lưu địa chỉ**: `http://lockerkorea-python-123.southeastasia.azurecontainer.io:8000` (Dùng cho biến `AI_EMBEDDING_BASE_URL` ở Backend).

## 10. Lấy Publish Profile (Thay thế cho AZURE_CREDENTIALS)
Do tài khoản sinh viên bị giới hạn quyền tạo Service Principal, chúng ta sẽ dùng **Publish Profile** để cấp quyền deploy cho GitHub Actions.

### 1. Lấy Profile cho Frontend
1.  Vào **App Services** -> Chọn Web App Frontend của bạn (ví dụ: `lockerkorea-frontend-123`).
2.  Ở trang **Overview**, trên thanh công cụ trên cùng, nhấn **Get publish profile**.
3.  Một file `.publishsettings` sẽ được tải xuống.
4.  Mở file này bằng Notepad (hoặc VS Code), copy **toàn bộ nội dung** bên trong.
5.  Vào GitHub Repo -> Settings -> Secrets -> Actions -> New repository secret.
    *   Name: `AZURE_FRONTEND_PUBLISH_PROFILE`
    *   Value: (Dán nội dung file vừa copy)

### 2. Lấy Profile cho Backend
1.  Vào **App Services** -> Chọn Web App Backend của bạn (ví dụ: `lockerkorea-backend-123`).
2.  Nhấn **Get publish profile** để tải file về.
3.  Mở file và copy toàn bộ nội dung.
4.  Vào GitHub Repo -> Settings -> Secrets -> Actions -> New repository secret.
    *   Name: `AZURE_BACKEND_PUBLISH_PROFILE`
    *   Value: (Dán nội dung file vừa copy)

---
**Lưu ý:** Vì không có `AZURE_CREDENTIALS`, phần deploy tự động cho Python Service và ChromaDB sẽ bị tắt. Bạn cần đảm bảo đã tạo chúng thủ công theo **Bước 9** ở trên.
