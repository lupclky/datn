# Hướng dẫn cấu hình Credentials cho Vertex AI trên GCP

Có 3 cách để cấu hình xác thực cho Vertex AI khi chạy trên Google Cloud Platform (GCP).

## Cách 1: Sử dụng Service Account của VM (Khuyên dùng - Best Practice)
Nếu bạn đang chạy ứng dụng trên **Google Compute Engine (GCE)** hoặc **Google Kubernetes Engine (GKE)**, bạn **KHÔNG CẦN** file JSON.

1. **Tạo Service Account** trên GCP Console.
2. Cấp quyền **Vertex AI User** cho Service Account này.
3. Gán Service Account này cho VM (Compute Engine instance) đang chạy ứng dụng.
   - Vào Compute Engine -> VM instances -> Chọn VM -> Edit -> Kéo xuống phần "Service Account" -> Chọn Service Account vừa tạo.
4. Ứng dụng sẽ tự động nhận diện quyền mà không cần biến môi trường hay file JSON nào cả.

---

## Cách 2: Mount file JSON vào Docker (Nếu chạy Docker Compose)
Nếu bạn vẫn muốn dùng file JSON (ví dụ: chạy test, hoặc không dùng Service Account của VM), bạn cần mount file đó vào container.

1. Upload file JSON (ví dụ: `credentials.json`) lên server, đặt cùng thư mục với `docker-compose-gcp.yml`.
2. Sửa file `docker-compose-gcp.yml`:

```yaml
  backend:
    # ...
    environment:
      - GOOGLE_APPLICATION_CREDENTIALS=/app/credentials.json # Trỏ đến đường dẫn TRONG container
      # ...
    volumes:
      - ./credentials.json:/app/credentials.json # Mount file từ ngoài vào trong
```

---

## Cách 3: Dùng biến môi trường chứa nội dung file (Linux Variable)
Nếu bạn muốn lưu nội dung file JSON vào một biến môi trường (ví dụ: để dùng trong CI/CD pipeline), bạn cần encode nó sang Base64 rồi decode lại khi chạy.

### Bước 1: Encode file JSON sang Base64
Trên máy cá nhân (Linux/Mac/Git Bash):
```bash
base64 -w 0 credentials.json > credentials.b64
```
Copy nội dung trong `credentials.b64`.

### Bước 2: Đặt biến môi trường
Trong `docker-compose-gcp.yml` hoặc cấu hình server:
```yaml
  backend:
    environment:
      - GCP_CREDENTIALS_BASE64=...nội_dung_base64_rất_dài...
```

### Bước 3: Sửa Entrypoint để decode (Cần sửa Dockerfile hoặc script khởi động)
Bạn cần tạo một script `entrypoint.sh`:
```bash
#!/bin/sh
if [ ! -z "$GCP_CREDENTIALS_BASE64" ]; then
  echo $GCP_CREDENTIALS_BASE64 | base64 -d > /app/credentials.json
  export GOOGLE_APPLICATION_CREDENTIALS=/app/credentials.json
fi
exec java -jar app.jar
```
Và sửa Dockerfile để dùng script này.

**Tóm lại:** Nếu bạn đã deploy lên GCP, hãy dùng **Cách 1**. Nó an toàn và đơn giản nhất.
