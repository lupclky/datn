# 🤖 AI Chatbot Tư Vấn Khóa Điện Tử - Locker Korea

## ✨ Tính Năng

Chatbot AI thông minh tích hợp Google Gemini để tư vấn khóa điện tử, khóa vân tay:

- 🔐 **Tư vấn chuyên sâu**: Phân tích nhu cầu an ninh và đề xuất khóa phù hợp
- 🔍 **Tìm kiếm thông minh**: Vector search với ChromaDB
- 📸 **Nhận diện hình ảnh**: Upload ảnh khóa để tìm sản phẩm tương tự
- 💬 **Chat tiếng Việt**: Giao tiếp tự nhiên bằng tiếng Việt
- ⚡ **Real-time**: Trả lời nhanh chóng dựa trên database thực tế
- 🎯 **Cá nhân hóa**: Tư vấn dựa trên loại cửa, ngân sách, tính năng ưu tiên

## 🏗️ Công Nghệ

- **AI Model**: Google Gemini 2.0 Flash (Vertex AI)
- **Embedding**: Vertex AI Text Multilingual Embedding 002
- **Vector DB**: ChromaDB
- **Framework**: LangChain4J
- **Backend**: Spring Boot 3.2.2 + Java 17
- **Frontend**: Angular 17

## 🚀 Bắt Đầu Nhanh

### 1. Khởi động ChromaDB
```bash
# Windows
start-chroma.bat

# Linux/Mac
./start-chroma.sh
```

### 2. Cấu hình Google Cloud
```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/key.json
```

### 3. Chạy Backend
```bash
cd Backend
mvn spring-boot:run
```

### 4. Chạy Frontend
```bash
cd Frontend
npm start
```

### 5. Khởi tạo AI Database
```bash
curl -X POST http://localhost:8089/api/v1/ai/initialize/index-all
```

## 💡 Ví Dụ Sử Dụng

### Tìm kiếm theo ngân sách
```
"Cho tôi xem khóa vân tay dưới 5 triệu VND"
```

### Tìm theo tính năng
```
"Tôi cần khóa có tính năng mở từ xa và thông báo qua app"
```

### So sánh sản phẩm
```
"So sánh khóa Samsung SHP-DR708 và Dessmann S510"
```

### Tư vấn theo loại cửa
```
"Khóa nào phù hợp cho cửa kính văn phòng?"
```

### Tìm khóa bảo mật cao
```
"Khóa vân tay bảo mật nhất cho cửa chính căn hộ"
```

## 📚 Tài Liệu

- **Hướng dẫn đầy đủ**: [AI_CHATBOT_GUIDE.md](AI_CHATBOT_GUIDE.md)
- **Hướng dẫn nhanh**: [CHATBOT_QUICKSTART.md](CHATBOT_QUICKSTART.md)

## 🎯 Kịch Bản Tư Vấn

### 1. Khách hàng mới mua nhà
```
User: "Tôi vừa mua nhà mới, cần tư vấn khóa cửa chính"
Bot: Phân tích nhu cầu → Đề xuất 3-5 khóa phù hợp → Giải thích tính năng
```

### 2. Nâng cấp bảo mật
```
User: "Muốn thay khóa cơ sang khóa điện tử, ngân sách 7 triệu"
Bot: Tìm khóa trong tầm giá → So sánh tính năng → Tư vấn lắp đặt
```

### 3. Căn hộ chung cư
```
User: "Khóa nào phù hợp cho cửa chung cư, cần mở bằng app"
Bot: Lọc khóa có WiFi/Bluetooth → Kiểm tra loại cửa → Đề xuất
```

### 4. Văn phòng
```
User: "Cần khóa cho 5 phòng văn phòng, quản lý tập trung"
Bot: Đề xuất hệ thống khóa thông minh → Giải thích quản lý quyền
```

## 🔧 API Endpoints

### Chat
```http
POST /api/v1/ai/chat/product-assistant
Content-Type: application/json

{
  "query": "Khóa vân tay dưới 5 triệu"
}
```

### Image Analysis
```http
POST /api/v1/ai/chat/image
Content-Type: multipart/form-data

image: [file]
prompt: "Đây là khóa gì?"
```

### Initialize AI
```http
POST /api/v1/ai/initialize/index-all
GET  /api/v1/ai/initialize/status
```

## 🎨 UI/UX

- **Floating button**: Icon chatbot góc dưới bên phải
- **Modern design**: Gradient purple, smooth animations
- **Responsive**: Hỗ trợ mobile và desktop
- **Real-time typing**: Hiệu ứng typing indicator
- **Image preview**: Xem trước ảnh trước khi gửi
- **Error handling**: Thông báo lỗi rõ ràng bằng tiếng Việt

## 📊 Kiến Trúc

```
┌─────────────┐
│   Angular   │  Frontend
│  Chatbot UI │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Spring     │  Backend
│   Boot      │
└──────┬──────┘
       │
       ├─────────────────┐
       │                 │
       ▼                 ▼
┌─────────────┐   ┌─────────────┐
│   Gemini    │   │  ChromaDB   │
│  (Vertex AI)│   │ Vector Store│
└─────────────┘   └─────────────┘
       │                 │
       └────────┬────────┘
                ▼
         Database Products
```

## 🔐 Bảo Mật

- ✅ Input validation
- ✅ Rate limiting (khuyến nghị)
- ✅ API authentication
- ✅ Google Cloud credentials encryption
- ✅ ChromaDB không public exposure

## 📈 Performance

- **Response time**: < 3s cho text chat
- **Image analysis**: < 5s
- **Vector search**: < 500ms
- **Indexing**: ~2s/sản phẩm

## 🆘 Troubleshooting

### Chatbot không trả lời
1. Kiểm tra backend logs
2. Verify ChromaDB running: `curl http://localhost:8000/api/v1/heartbeat`
3. Check Google credentials: `echo $GOOGLE_APPLICATION_CREDENTIALS`

### Kết quả tìm kiếm không chính xác
1. Re-index database: `POST /api/v1/ai/initialize/index-all`
2. Tăng `topK` parameter (số kết quả)
3. Giảm `minScore` (độ tương đồng tối thiểu)

## 🌟 Tính Năng Sắp Có

- [ ] Voice input/output
- [ ] Multi-language (English, Korean)
- [ ] Product comparison table view
- [ ] Chat history
- [ ] User preference learning
- [ ] Integration with order system

## 📄 License

Copyright © 2025 Locker Korea

---

**Version**: 1.0.0  
**Last Updated**: 04/11/2025  
**Contact**: Locker Korea Support Team

