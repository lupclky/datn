# Hướng dẫn Triển khai lên Google Cloud Platform (GCP)

Tài liệu này hướng dẫn bạn triển khai toàn bộ dự án (Frontend, Backend, MySQL, Python Service, ChromaDB) lên một máy ảo (VM) trên Google Cloud Platform. Đây là cách đơn giản và tiết kiệm chi phí nhất, tương tự như cách bạn chạy Docker trên máy cá nhân.

## 1. Tạo Máy Ảo (Compute Engine VM)

1.  Truy cập [Google Cloud Console](https://console.cloud.google.com/).
2.  Vào menu **Compute Engine** -> **VM instances**.
3.  Nhấn **Create Instance**.
4.  **Name**: `lockerkorea-server`.
5.  **Region**: Chọn `asia-southeast1` (Singapore) hoặc `asia-east1` (Taiwan) cho gần Việt Nam.
6.  **Machine configuration**:
    *   Series: **E2**.
    *   Machine type: **e2-medium** (2 vCPU, 4GB memory) - Đây là cấu hình tối thiểu để chạy mượt Java Spring Boot và MySQL.
7.  **Boot disk**:
    *   Nhấn **Change**.
    *   Operating System: **Ubuntu**.
    *   Version: **Ubuntu 22.04 LTS**.
    *   Size: **30 GB** (hoặc cao hơn nếu cần lưu nhiều ảnh).
    *   Nhấn **Select**.
8.  **Firewall**:
    *   Tích chọn **Allow HTTP traffic**.
    *   Tích chọn **Allow HTTPS traffic**.
9.  Nhấn **Create**.

## 2. Cài đặt Môi trường trên VM

Sau khi VM tạo xong, nhấn nút **SSH** để mở cửa sổ dòng lệnh kết nối vào máy chủ.

Copy và chạy lần lượt các lệnh sau để cài đặt Docker và Git:

```bash
# 1. Cập nhật hệ thống
sudo apt-get update

# 2. Cài đặt Docker
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

# 3. Cấp quyền Docker cho user hiện tại (để không phải gõ sudo mỗi lần)
sudo usermod -aG docker $USER
newgrp docker
```

## 3. Triển khai Code lần đầu

Vẫn trong cửa sổ SSH, thực hiện các bước sau:

1.  **Clone code từ GitHub**:
    *(Thay thế URL bên dưới bằng link repo của bạn)*
    ```bash
    git clone https://github.com/YOUR_USERNAME/locker_korea.git
    cd locker_korea
    ```

2.  **Tạo file môi trường (.env)**:
    Tạo file `.env` để chứa các biến mật (password DB, API Key...).
    ```bash
    nano .env
    ```
    Dán nội dung sau vào (sửa lại cho đúng):
    ```env
    DOCKERHUB_USERNAME=your_dockerhub_username
    DB_ROOT_PASSWORD=secret_root_pass
    DB_NAME=lockerkorea
    DB_USER=user
    DB_PASSWORD=user_pass
    DOMAIN_NAME=YOUR_VM_EXTERNAL_IP (Ví dụ: 34.123.45.67)
    
    # Nếu bạn vẫn dùng Azure Storage để lưu ảnh
    AZURE_STORAGE_ACCOUNT_NAME=...
    AZURE_STORAGE_ACCOUNT_KEY=...
    AZURE_STORAGE_ENDPOINT=...
    AZURE_STORAGE_CONTAINER_NAME=...
    ```
    Nhấn `Ctrl+O` -> `Enter` để lưu, `Ctrl+X` để thoát.

3.  **Chạy ứng dụng**:
    ```bash
    docker compose -f docker-compose-gcp.yml up -d --build
    ```

4.  **Kiểm tra**:
    Truy cập vào địa chỉ IP của VM (External IP) trên trình duyệt.

## 4. Cấu hình Tự động Deploy (CI/CD)

Để GitHub tự động deploy mỗi khi bạn push code, bạn cần cấu hình SSH Key.

### Bước 1: Tạo SSH Key trên máy cá nhân (hoặc Cloud Shell)
```bash
ssh-keygen -t rsa -b 4096 -C "github-actions" -f gh_deploy_key -N ""
```
Bạn sẽ có 2 file: `gh_deploy_key` (Private Key) và `gh_deploy_key.pub` (Public Key).

### Bước 2: Thêm Public Key vào VM
1.  Mở nội dung file `gh_deploy_key.pub`.
2.  Trên cửa sổ SSH của VM, chạy:
    ```bash
    nano ~/.ssh/authorized_keys
    ```
3.  Dán nội dung Public Key vào cuối file -> Lưu lại.

### Bước 3: Cấu hình GitHub Secrets
Vào Repo Settings -> Secrets -> Actions -> New repository secret:

1.  `GCP_VM_HOST`: Địa chỉ IP Public của VM.
2.  `GCP_VM_USERNAME`: Tên user SSH (thường là tên gmail của bạn bỏ phần @gmail.com, gõ lệnh `whoami` trên VM để xem).
3.  `GCP_SSH_PRIVATE_KEY`: Copy toàn bộ nội dung file `gh_deploy_key` (Private Key).
4.  `DOCKERHUB_USERNAME`: Username Docker Hub.
5.  `DOCKERHUB_TOKEN`: Access Token Docker Hub.

### Bước 4: Cập nhật Workflow
File `.github/workflows/gcp-deploy.yml` đã được tạo sẵn để tự động build và deploy lên VM này.
