# Hướng dẫn Triển khai lên Google Cloud Platform (GCP)

Tài liệu này hướng dẫn bạn triển khai toàn bộ dự án (Frontend, Backend, MySQL, Python Service, ChromaDB) lên một máy ảo (VM) trên Google Cloud Platform.

## 1. Tạo Máy Ảo (Compute Engine VM)

1.  Truy cập [Google Cloud Console](https://console.cloud.google.com/).
2.  Vào menu **Compute Engine** -> **VM instances**.
3.  Nhấn **Create Instance**.
4.  **Name**: `lockerkorea-server`.
5.  **Region**: Chọn `asia-southeast1` (Singapore) hoặc `asia-east1` (Taiwan).
6.  **Machine configuration**:
    *   Series: **E2**.
    *   Machine type: **e2-medium** (2 vCPU, 4GB memory).
7.  **Boot disk**:
    *   Operating System: **Ubuntu**.
    *   Version: **Ubuntu 22.04 LTS**.
    *   Size: **30 GB**.
8.  **Firewall**:
    *   Tích chọn **Allow HTTP traffic**.
    *   Tích chọn **Allow HTTPS traffic**.
9.  **Identity and API access**:
    *   Service account: Chọn **Compute Engine default service account**.
    *   Access scopes: Chọn **Allow full access to all Cloud APIs** (Để VM có quyền truy cập Storage).
10. Nhấn **Create**.

## 1.1. Mở Port cho phpMyAdmin (Quan trọng)
Để truy cập phpMyAdmin, bạn cần mở port 8081 trên Firewall của GCP:
1.  Vào menu **VPC network** -> **Firewall**.
2.  Nhấn **Create Firewall Rule**.
3.  **Name**: `allow-phpmyadmin`.
4.  **Targets**: `All instances in the network`.
5.  **Source IPv4 ranges**: `0.0.0.0/0`.
6.  **Protocols and ports**:
    *   Chọn **Specified protocols and ports**.
    *   Tích chọn **TCP** và điền: `8081`.
7.  Nhấn **Create**.

## 2. Tạo Google Cloud Storage Bucket (Lưu ảnh)

1.  Vào menu **Cloud Storage** -> **Buckets**.
2.  Nhấn **Create**.
3.  **Name**: `lockerkorea-images` (hoặc tên duy nhất khác).
4.  **Location type**: **Region** (chọn cùng region với VM).
5.  **Access control**: Bỏ chọn "Enforce public access prevention on this bucket" (Để có thể public ảnh).
6.  Nhấn **Create**.
7.  **Cấp quyền Public**:
    *   Vào tab **Permissions**.
    *   Nhấn **Grant Access**.
    *   New principals: `allUsers`.
    *   Role: **Storage Object Viewer**.
    *   Nhấn **Save**.

## 3. Cài đặt Môi trường trên VM

Nhấn nút **SSH** để kết nối vào VM và chạy lệnh:

```bash
# Cài đặt Docker
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Cấp quyền Docker
sudo usermod -aG docker $USER
newgrp docker
```

## 4. Triển khai Code

1.  **Clone code** (Nhánh `gcp`):
    ```bash
    git clone -b gcp https://github.com/YOUR_USERNAME/locker_korea.git
    cd locker_korea
    ```

2.  **Tạo file .env**:
    ```bash
    nano .env
    ```
    Nội dung:
    ```env
    DOCKERHUB_USERNAME=your_dockerhub_username
    DB_ROOT_PASSWORD=secret_root_pass
    DB_NAME=lockerkorea
    DB_USER=user
    DB_PASSWORD=user_pass
    DOMAIN_NAME=YOUR_VM_EXTERNAL_IP
    GCP_STORAGE_BUCKET_NAME=lockerkorea-images
    ```

3.  **Chạy ứng dụng**:
    ```bash
    docker compose -f docker-compose-gcp.yml up -d --build
    ```

## 5. Cấu hình CI/CD (GitHub Actions)

### Bước 1: Tạo SSH Key
Bạn nên chạy lệnh này trên **terminal của VS Code** (máy cá nhân) để dễ quản lý file.

```bash
ssh-keygen -t rsa -b 4096 -C "github-actions" -f gh_deploy_key -N ""
```
Lệnh này sẽ tạo ra 2 file ngay tại thư mục hiện tại:
*   `gh_deploy_key`: Private Key (Dùng cho GitHub Secret).
*   `gh_deploy_key.pub`: Public Key (Dùng để cài vào VM).

### Bước 2: Lấy nội dung Key
*   **Để lấy Private Key**: Mở file `gh_deploy_key` bằng VS Code hoặc chạy lệnh:
    *   Windows (PowerShell): `Get-Content gh_deploy_key`
    *   Mac/Linux: `cat gh_deploy_key`
    *   *Copy toàn bộ nội dung (bao gồm cả `-----BEGIN OPENSSH PRIVATE KEY-----`)*.

*   **Để lấy Public Key**: Mở file `gh_deploy_key.pub` hoặc chạy lệnh:
    *   Windows (PowerShell): `Get-Content gh_deploy_key.pub`
    *   Mac/Linux: `cat gh_deploy_key.pub`

### Bước 3: Thêm Public Key vào VM
1.  Copy nội dung **Public Key** vừa lấy ở trên.
2.  Trên cửa sổ SSH của VM (trên Google Cloud Console), chạy lệnh:
    ```bash
    nano ~/.ssh/authorized_keys
    ```
3.  Dán nội dung Public Key vào dòng cuối cùng.
4.  Nhấn `Ctrl+O` -> `Enter` để lưu, `Ctrl+X` để thoát.

### Bước 4: Thêm GitHub Secrets
Vào Repo Settings -> Secrets -> Actions -> New repository secret:
    *   `GCP_VM_HOST`: IP Public của VM.
    *   `GCP_VM_USERNAME`: Username SSH (gõ lệnh `whoami` trên VM để xem).
    *   `GCP_SSH_PRIVATE_KEY`: Dán nội dung **Private Key** (`gh_deploy_key`) vào đây.
    *   `DOCKERHUB_USERNAME`: Username Docker Hub.
    *   `DOCKERHUB_TOKEN`: Token Docker Hub.

## 6. Truy cập Website (Qua Cloudflare Tunnel - Khuyên dùng)

Sử dụng Cloudflare Tunnel giúp bạn không cần mở port trên Firewall (trừ port SSH), bảo mật hơn và có HTTPS miễn phí ngay lập tức.

### Bước 1: Lấy Token
1.  Truy cập [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/).
2.  Vào **Networks** -> **Tunnels** -> **Create a tunnel**.
3.  Chọn **Cloudflared** -> Next.
4.  Đặt tên Tunnel (ví dụ: `lockerkorea-gcp`) -> Save.
5.  Tại màn hình "Install and run a connector", tìm đoạn code cài đặt.
6.  Copy chuỗi token dài nằm sau đoạn `tunnel run --token`. Ví dụ: `eyJhIjoi...`

### Bước 2: Cấu hình Public Hostname (Trên Cloudflare Dashboard)
Chuyển sang tab **Public Hostname** và thêm các domain trỏ về service trong Docker:

1.  **Frontend** (Web chính - `lap123.click`):
    *   Subdomain: `@` (Root domain) hoặc `www`
    *   Domain: `lap123.click`
    *   Service: `http://lockerkorea-frontend:80` (Lưu ý: Tên container là `lockerkorea-frontend`)

2.  **Backend API** (`api.lap123.click`):
    *   Subdomain: `api`
    *   Domain: `lap123.click`
    *   Service: `http://lockerkorea-backend:8089`

3.  **phpMyAdmin** (`db.lap123.click`):
    *   Subdomain: `db`
    *   Domain: `lap123.click`
    *   Service: `http://lockerkorea-phpmyadmin:80`

### Bước 3: Cập nhật .env trên VM
Thêm dòng này vào file `.env` trên VM:
```env
CLOUDFLARE_TUNNEL_TOKEN=eyJhIjoi... (Token bạn vừa copy)
```

## 7. Truy cập Website (Qua IP - Cách cũ)

Sau khi triển khai thành công, bạn có thể truy cập website thông qua địa chỉ IP Public của máy ảo (VM).

Sau khi triển khai thành công, bạn có thể truy cập website thông qua địa chỉ IP Public của máy ảo (VM).

1.  **Lấy địa chỉ IP**:
    *   Vào Google Cloud Console -> **Compute Engine** -> **VM instances**.
    *   Tìm cột **External IP** của máy ảo `lockerkorea-server`.
    *   Copy địa chỉ IP này (ví dụ: `34.123.45.67`).

2.  **Truy cập**:
    *   Mở trình duyệt web.
    *   Nhập địa chỉ IP vào thanh địa chỉ: `http://34.123.45.67` (Thay bằng IP của bạn).

### Lưu ý về Domain (Tên miền)
Hiện tại bạn đang truy cập bằng IP. Nếu bạn muốn có tên miền đẹp (ví dụ: `lockerkorea.com`):
1.  Mua tên miền từ nhà cung cấp (Namecheap, GoDaddy...).
2.  Vào trang quản lý DNS của tên miền, tạo bản ghi **A Record**:
    *   Host: `@`
    *   Value: `Địa chỉ IP Public của VM`
3.  Sau đó bạn có thể truy cập bằng `http://lockerkorea.com`.
