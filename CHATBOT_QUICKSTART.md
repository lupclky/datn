# 🚀 Chatbot AI Tư Vấn Khóa Điện Tử - Hướng Dẫn Nhanh

## Bắt Đầu Nhanh

### 1. Khởi động ChromaDB

**Windows:**
```cmd
start-chroma.bat
```

**Linux/Mac:**
```bash
chmod +x start-chroma.sh
./start-chroma.sh
```

**Hoặc dùng Docker Compose:**
```bash
docker-compose -f docker-compose-chroma.yml up -d
```

### 2. Cấu hình Google Cloud

Đảm bảo bạn đã:
- Tạo Google Cloud Project
- Kích hoạt Vertex AI API
- Tải xuống service account key JSON
- Set environment variable:

```bash
# Linux/Mac
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/key.json

# Windows
set GOOGLE_APPLICATION_CREDENTIALS=C:\path\to\your\key.json
```

### 3. Cập nhật application.yaml

```yaml
spring:
  google:
    ai:
      project-id: YOUR_PROJECT_ID  # Thay bằng project ID của bạn
      location: us-central1
      model: gemini-2.0-flash-001

chroma:
  base:
    url: http://localhost:8000
```

### 4. Khởi động Backend

```bash
cd Backend
mvn spring-boot:run
```

Hoặc:
```bash
mvn clean package
java -jar target/Sneakers-0.0.1-SNAPSHOT.jar
```

### 5. Khởi động Frontend

```bash
cd Frontend
npm install
npm start
```

### 6. Khởi tạo AI Database (Lần đầu tiên)

**Cách 1: Qua UI**
1. Mở website
2. Click vào icon chatbot (góc dưới bên phải)
3. Click vào icon database ở header chatbot
4. Xác nhận và đợi quá trình hoàn tất

**Cách 2: Qua API**
```bash
curl -X POST http://localhost:8089/api/v1/ai/initialize/index-all
```

**Kiểm tra trạng thái:**
```bash
curl http://localhost:8089/api/v1/ai/initialize/status
```

## 💬 Sử Dụng Chatbot

### Các câu hỏi mẫu:

```
✅ "Cho tôi xem khóa vân tay dưới 5 triệu"
✅ "Samsung có những mẫu khóa nào đang sale?"
✅ "So sánh khóa Samsung và Dessmann"
✅ "Tôi cần khóa có tính năng mở từ xa"
✅ "Khóa điện tử nào phù hợp cho cửa kính?"
✅ "Gợi ý khóa vân tay cho căn hộ chung cư"
```

### Tính năng:

- ✅ **Chat text**: Hỏi bất kỳ điều gì về khóa điện tử, khóa vân tay
- ✅ **Upload ảnh**: AI sẽ phân tích và tìm khóa tương tự
- ✅ **Tìm kiếm thông minh**: Vector search trong database sản phẩm
- ✅ **Đa ngôn ngữ**: Hỗ trợ tiếng Việt
- ✅ **Tư vấn an ninh chuyên nghiệp**: Dựa trên loại cửa, nhu cầu bảo mật và ngân sách
- ✅ **So sánh công nghệ**: So sánh chi tiết tính năng bảo mật giữa các khóa

## 🔧 Troubleshooting

### Lỗi: "Cannot connect to ChromaDB"

```bash
# Kiểm tra ChromaDB
curl http://localhost:8000/api/v1/heartbeat

# Nếu không chạy
docker-compose -f docker-compose-chroma.yml up -d
```

### Lỗi: "Failed to initialize Gemini"

```bash
# Kiểm tra credentials
echo $GOOGLE_APPLICATION_CREDENTIALS

# Test authentication
gcloud auth application-default login
```

### Chatbot không trả lời

1. Kiểm tra backend logs: `logs/sneakers-app.log`
2. Kiểm tra AI database đã được khởi tạo chưa
3. Kiểm tra ChromaDB đang chạy
4. Kiểm tra Google Cloud credentials

## 📊 API Endpoints

### Chat
```
POST /api/v1/ai/chat/product-assistant
Body: { "query": "your question" }
```

### Image Analysis
```
POST /api/v1/ai/chat/image
FormData: image, prompt
```

### Initialize
```
POST /api/v1/ai/initialize/index-all
GET  /api/v1/ai/initialize/status
DELETE /api/v1/ai/initialize/clear-index
```

## 📖 Tài Liệu Chi Tiết

Xem file `AI_CHATBOT_GUIDE.md` để có hướng dẫn đầy đủ.

## 🆘 Support

- Kiểm tra logs: `Backend/logs/sneakers-app.log`
- Xem docs: `AI_CHATBOT_GUIDE.md`
- Issues: GitHub repository

---

**Version:** 1.0.0  
**Last Updated:** 04/11/2025

