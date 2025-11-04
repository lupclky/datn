# Hướng Dẫn Sử Dụng Chatbot AI Tư Vấn Khóa Điện Tử

## 📋 Tổng Quan

Chatbot AI tư vấn khóa điện tử là một tính năng thông minh được tích hợp vào hệ thống Locker Korea, sử dụng Google Gemini AI để tư vấn và hỗ trợ khách hàng tìm kiếm khóa vân tay, khóa điện tử phù hợp dựa trên database sản phẩm thực tế.

## 🏗️ Kiến Trúc Hệ Thống

### Backend Components:

1. **Google Gemini AI (via Vertex AI)**
   - Model: `gemini-2.0-flash-001`
   - Xử lý ngôn ngữ tự nhiên
   - Phân tích hình ảnh
   - Tạo câu trả lời thông minh

2. **Vector Database (ChromaDB)**
   - Lưu trữ embeddings của sản phẩm
   - Tìm kiếm semantic search
   - Collection: `sneakers-collection`

3. **LangChain4J Framework**
   - Tích hợp AI models
   - Quản lý embeddings
   - Vector store operations

### Frontend Components:

1. **AI Chatbot Component** (`ai-chatbot.component`)
   - UI/UX hiện đại với animations
   - Hỗ trợ text và image input
   - Real-time responses
   - Message history

2. **AI Service** (`ai.service`)
   - API integration
   - Request/response handling
   - Error management

## 🚀 Cài Đặt và Cấu Hình

### 1. Yêu Cầu Hệ Thống

```yaml
Backend:
  - Java 17+
  - Spring Boot 3.2.2
  - MySQL 8.0+
  - Google Cloud Account với Vertex AI enabled
  - ChromaDB Server

Frontend:
  - Angular 17+
  - Node.js 18+
```

### 2. Cấu Hình Google Cloud

#### Bước 1: Tạo Project trên Google Cloud

```bash
# Đăng nhập vào Google Cloud Console
# Tạo project mới hoặc sử dụng project có sẵn
# Lấy Project ID (ví dụ: thermal-micron-435515-i8)
```

#### Bước 2: Kích hoạt Vertex AI API

```bash
gcloud services enable aiplatform.googleapis.com
```

#### Bước 3: Thiết lập Authentication

```bash
# Tạo Service Account
gcloud iam service-accounts create sneakers-ai \
    --display-name="Sneakers AI Service Account"

# Cấp quyền
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:sneakers-ai@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/aiplatform.user"

# Tạo và tải xuống key
gcloud iam service-accounts keys create ~/sneakers-ai-key.json \
    --iam-account=sneakers-ai@YOUR_PROJECT_ID.iam.gserviceaccount.com

# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS=~/sneakers-ai-key.json
```

### 3. Cài Đặt ChromaDB

#### Option 1: Docker (Khuyến nghị)

```bash
# Chạy ChromaDB với Docker
docker run -d -p 8000:8000 chromadb/chroma

# Hoặc sử dụng docker-compose
```

**docker-compose.yml**:
```yaml
version: '3.8'
services:
  chromadb:
    image: chromadb/chroma
    ports:
      - "8000:8000"
    volumes:
      - chroma-data:/chroma/chroma
    environment:
      - IS_PERSISTENT=TRUE
      - ANONYMIZED_TELEMETRY=FALSE

volumes:
  chroma-data:
```

```bash
docker-compose up -d
```

#### Option 2: Python Installation

```bash
pip install chromadb
chroma run --host 0.0.0.0 --port 8000
```

### 4. Cấu Hình Backend

**application.yaml**:
```yaml
spring:
  google:
    ai:
      project-id: YOUR_PROJECT_ID  # Thay bằng Google Cloud Project ID của bạn
      location: us-central1
      model: gemini-2.0-flash-001

# Chroma Vector Database Configuration
chroma:
  collection:
    name: sneakers-collection
  base:
    url: ${CHROMA_BASE_URL:http://localhost:8000}

# AI Features Configuration
ai:
  enabled: true
```

### 5. Khởi Động Hệ Thống

#### Backend:

```bash
cd Backend

# Set environment variable cho Google Cloud credentials
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/key.json

# Build và chạy
mvn clean install
mvn spring-boot:run
```

#### Frontend:

```bash
cd Frontend
npm install
npm start
```

## 📚 Sử Dụng Chatbot

### 1. Khởi Tạo Database AI (Lần Đầu Tiên)

Sau khi khởi động hệ thống, cần index toàn bộ sản phẩm vào vector database:

**Cách 1: Qua UI**
- Mở chatbot
- Click vào icon "database" ở header
- Đợi quá trình indexing hoàn tất (có thể mất vài phút tùy số lượng sản phẩm)

**Cách 2: Qua API**
```bash
curl -X POST http://localhost:8089/api/v1/ai/initialize/index-all
```

**Kiểm tra trạng thái indexing:**
```bash
curl http://localhost:8089/api/v1/ai/initialize/status
```

Response:
```json
{
  "success": true,
  "documentCount": 150,
  "status": "initialized",
  "timestamp": 1699234567890
}
```

### 2. Sử Dụng Chatbot

#### Ví dụ câu hỏi cơ bản:

```
✅ "Cho tôi xem khóa vân tay cho cửa nhà dưới 5 triệu"
✅ "Samsung có những mẫu khóa điện tử nào đang sale?"
✅ "So sánh khóa Samsung và Dessmann"
✅ "Tôi cần khóa có tính năng mở từ xa cho căn hộ"
✅ "Khóa điện tử nào phù hợp cho cửa kính?"
✅ "Khóa vân tay bảo mật nhất hiện nay"
```

#### Tìm kiếm theo danh mục:

```bash
POST /api/v1/ai/chat/product-assistant/by-category
{
  "query": "Giày chạy bộ tốt nhất",
  "category": "Running Shoes"
}
```

#### Tìm kiếm theo khoảng giá:

```bash
POST /api/v1/ai/chat/product-assistant/by-price-range
{
  "query": "Giày thể thao",
  "minPrice": 1000000,
  "maxPrice": 3000000
}
```

#### So sánh sản phẩm:

```bash
POST /api/v1/ai/chat/product-assistant/compare
{
  "productIds": [1, 2, 3]
}
```

#### Phân tích hình ảnh:

- Upload ảnh giày qua chatbot
- AI sẽ phân tích và tìm sản phẩm tương tự

### 3. Tự động cập nhật

Hệ thống tự động index sản phẩm mới khi:
- Tạo sản phẩm mới
- Cập nhật sản phẩm
- Xóa sản phẩm (tự động xóa khỏi index)

Nhờ **ProductEventListener** lắng nghe các sự kiện CRUD.

## 🎨 Tùy Chỉnh

### 1. Thay đổi Model AI

**GeminiConfig.java**:
```java
@Value("${spring.google.ai.model}")
private String modelName; // gemini-2.0-flash-001, gemini-pro, etc.
```

### 2. Tùy chỉnh Embedding Model

**EmbeddingConfig.java**:
```java
return VertexAiEmbeddingModel.builder()
    .modelName("text-multilingual-embedding-002") // hoặc model khác
    .outputDimensionality(512) // 128, 256, 512, 768
    .build();
```

### 3. Tùy chỉnh Search Parameters

**VectorSearchServiceImpl.java**:
```java
EmbeddingSearchRequest searchRequest = new EmbeddingSearchRequest(
    queryEmbedding,
    topK,          // Số lượng kết quả (default: 5-10)
    0.7,           // Minimum similarity score (0.0 - 1.0)
    null
);
```

### 4. Tùy chỉnh Prompts

**AIProductAssistantService.java** - Chỉnh sửa các prompt templates:

```java
private String createEnhancedPrompt(String userQuery, String productContext) {
    return String.format("""
        You are a helpful Vietnamese sneaker shopping assistant...
        [Tùy chỉnh prompt theo nhu cầu]
        """, userQuery, productContext);
}
```

### 5. Tùy chỉnh UI Chatbot

**ai-chatbot.component.scss** - Thay đổi colors, sizes, animations:

```scss
.chat-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); // Đổi màu
  width: 60px;  // Đổi kích thước
  height: 60px;
}
```

## 🔧 Troubleshooting

### Lỗi: "Failed to initialize Gemini chat model"

**Nguyên nhân:**
- Google Cloud credentials không đúng
- Vertex AI API chưa được kích hoạt
- Project ID sai

**Giải pháp:**
```bash
# Kiểm tra credentials
echo $GOOGLE_APPLICATION_CREDENTIALS

# Kiểm tra API đã được kích hoạt
gcloud services list --enabled | grep aiplatform

# Test authentication
gcloud auth application-default login
```

### Lỗi: "Cannot connect to ChromaDB"

**Nguyên nhân:**
- ChromaDB server chưa chạy
- Port 8000 bị chiếm
- URL configuration sai

**Giải pháp:**
```bash
# Kiểm tra ChromaDB đang chạy
curl http://localhost:8000/api/v1/heartbeat

# Nếu dùng Docker
docker ps | grep chroma

# Restart ChromaDB
docker restart <chroma_container_id>
```

### Lỗi: "No products indexed"

**Giải pháp:**
```bash
# Re-index toàn bộ sản phẩm
curl -X POST http://localhost:8089/api/v1/ai/initialize/index-all

# Xóa index cũ và tạo lại
curl -X DELETE http://localhost:8089/api/v1/ai/initialize/clear-index
curl -X POST http://localhost:8089/api/v1/ai/initialize/index-all
```

### Chatbot response chậm

**Tối ưu hóa:**
1. Giảm `topK` trong search (từ 10 → 5)
2. Tăng `minScore` để lọc kết quả (từ 0.7 → 0.8)
3. Sử dụng model nhẹ hơn (gemini-flash thay vì gemini-pro)
4. Cache responses cho queries phổ biến

## 📊 Monitoring và Logging

### Backend Logs

```bash
# Xem logs trong file
tail -f logs/sneakers-app.log

# Filter AI-related logs
tail -f logs/sneakers-app.log | grep "ai.services"
```

### ChromaDB Logs

```bash
# Nếu dùng Docker
docker logs <chroma_container_id> -f
```

### Metrics

**Kiểm tra số lượng documents:**
```bash
curl http://localhost:8089/api/v1/ai/initialize/status
```

## 🔐 Security Best Practices

1. **Google Cloud Credentials:**
   - Không commit `*.json` key files vào Git
   - Sử dụng environment variables
   - Rotate keys định kỳ

2. **API Endpoints:**
   - Thêm authentication cho admin endpoints (initialize, clear-index)
   - Rate limiting cho chat endpoints
   - Input validation

3. **ChromaDB:**
   - Không expose port 8000 ra public
   - Sử dụng authentication nếu deploy production
   - Backup data định kỳ

## 📈 Performance Optimization

### 1. Caching Strategy

Implement Redis cache cho:
- Popular queries
- Product metadata
- Embedding results

### 2. Batch Processing

Index products in batches:
```java
// VectorSearchServiceImpl.java
public void indexAllProducts() {
    List<Product> products = productRepository.findAll();
    
    // Process in batches of 50
    Lists.partition(products, 50).forEach(batch -> {
        batch.parallelStream().forEach(this::indexProduct);
    });
}
```

### 3. Database Indexing

```sql
-- Tối ưu queries
CREATE INDEX idx_product_name ON product(name);
CREATE INDEX idx_product_price ON product(price);
CREATE INDEX idx_product_category ON product(category_id);
```

## 🚀 Production Deployment

### 1. Environment Variables

```bash
# .env file
GOOGLE_APPLICATION_CREDENTIALS=/path/to/prod/key.json
CHROMA_BASE_URL=http://chroma-service:8000
SPRING_PROFILES_ACTIVE=production
```

### 2. Docker Deployment

**Dockerfile (Backend)**:
```dockerfile
FROM openjdk:17-jdk-slim
COPY target/Sneakers-0.0.1-SNAPSHOT.jar app.jar
COPY google-credentials.json /app/google-credentials.json
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/google-credentials.json
ENTRYPOINT ["java","-jar","/app.jar"]
```

### 3. Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sneakers-backend
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: backend
        image: sneakers-backend:latest
        env:
        - name: CHROMA_BASE_URL
          value: "http://chromadb-service:8000"
        volumeMounts:
        - name: google-credentials
          mountPath: /app/credentials
      volumes:
      - name: google-credentials
        secret:
          secretName: google-ai-credentials
```

## 📝 API Documentation

### Chat Endpoints

#### 1. Text Chat
```http
POST /api/v1/ai/chat/text
Content-Type: application/json

{
  "message": "Hello"
}

Response:
{
  "response": "Hi! How can I help you today?",
  "success": true,
  "timestamp": 1699234567890
}
```

#### 2. Product Assistant
```http
POST /api/v1/ai/chat/product-assistant
Content-Type: application/json

{
  "query": "Show me running shoes under 3 million"
}

Response:
{
  "response": "Here are some great running shoes...",
  "success": true,
  "type": "product-assistant",
  "timestamp": 1699234567890
}
```

#### 3. Image Analysis
```http
POST /api/v1/ai/chat/image
Content-Type: multipart/form-data

image: [file]
prompt: "What sneaker is this?"

Response:
{
  "response": "This appears to be a Nike Air Max...",
  "success": true,
  "timestamp": 1699234567890
}
```

### Initialization Endpoints

#### 1. Index All Products
```http
POST /api/v1/ai/initialize/index-all

Response:
{
  "success": true,
  "message": "Successfully indexed all products and categories",
  "timestamp": 1699234567890
}
```

#### 2. Get Status
```http
GET /api/v1/ai/initialize/status

Response:
{
  "success": true,
  "documentCount": 150,
  "status": "initialized",
  "timestamp": 1699234567890
}
```

#### 3. Clear Index
```http
DELETE /api/v1/ai/initialize/clear-index

Response:
{
  "success": true,
  "message": "Successfully cleared all indexed documents",
  "timestamp": 1699234567890
}
```

## 🎯 Roadmap

### Phase 1 ✅ (Completed)
- [x] Tích hợp Gemini AI
- [x] Vector search với ChromaDB
- [x] Chatbot UI component
- [x] Product indexing
- [x] Image analysis

### Phase 2 🚧 (In Progress)
- [ ] Multi-language support (Vietnamese, English, Korean)
- [ ] Product recommendation system
- [ ] Conversation history
- [ ] User preferences learning

### Phase 3 📋 (Planned)
- [ ] Voice input/output
- [ ] AR product visualization
- [ ] Integration with order system
- [ ] Analytics dashboard
- [ ] A/B testing framework

## 📞 Support

Nếu gặp vấn đề, vui lòng:
1. Kiểm tra logs: `logs/sneakers-app.log`
2. Xem issues trên GitHub
3. Liên hệ dev team

## 📄 License

Copyright © 2025 Locker Korea Sneakers Shop

---

**Phiên bản:** 1.0.0  
**Cập nhật:** 04/11/2025  
**Tác giả:** Locker Korea Team

