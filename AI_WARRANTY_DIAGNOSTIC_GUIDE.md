# 🔧 AI Tư Vấn Bảo Hành & Chẩn Đoán Lỗi Khóa

## ✨ Tính Năng Mới

### 1. Tư Vấn Chính Sách Bảo Hành
AI tư vấn chuyên nghiệp về chính sách bảo hành khóa điện tử.

### 2. Chẩn Đoán Lỗi Khóa
AI chẩn đoán và đưa ra giải pháp cho các lỗi thường gặp của khóa điện tử.

## 🎯 Mục Đích

- **Tiết kiệm thời gian**: Tư vấn nhanh 24/7
- **Chính xác**: Dựa trên kiến thức chuyên môn về khóa điện tử
- **Thân thiện**: Giao tiếp tự nhiên bằng tiếng Việt
- **Thực tế**: Giải pháp cụ thể, dễ thực hiện

## 📋 API Endpoints

### 1. Tư Vấn Bảo Hành

```http
POST /api/v1/ai/chat/warranty-advice
Content-Type: application/json

{
  "query": "Khóa của tôi bảo hành bao lâu?"
}
```

**Response:**
```json
{
  "response": "Chính sách bảo hành...",
  "success": true,
  "type": "warranty-advice",
  "timestamp": 1699234567890
}
```

### 2. Chẩn Đoán Lỗi

```http
POST /api/v1/ai/chat/diagnose-issue
Content-Type: application/json

{
  "issue": "Khóa không nhận vân tay"
}
```

**Response:**
```json
{
  "response": "Chẩn đoán và giải pháp...",
  "success": true,
  "type": "diagnosis",
  "timestamp": 1699234567890
}
```

## 💡 Ví Dụ Sử Dụng

### Tư Vấn Bảo Hành

**Câu hỏi mẫu:**
```
✅ "Khóa điện tử bảo hành bao lâu?"
✅ "Những lỗi nào được bảo hành?"
✅ "Làm sao để bảo hành khóa?"
✅ "Khóa bị vào nước có được bảo hành không?"
✅ "Bảo hành có mất phí không?"
```

**Ví dụ Response:**
```
Chào bạn! 

Về chính sách bảo hành khóa điện tử tại Locker Korea:

- Thời gian bảo hành: 12-24 tháng tùy theo hãng sản xuất
- Phạm vi bảo hành: Lỗi phần cứng, phần mềm do nhà sản xuất
- Không bảo hành: Lỗi do người dùng, thiên tai, hỏng do nước

Để bảo hành, bạn cần:
1. Hóa đơn mua hàng
2. Tem bảo hành còn nguyên
3. Không tự ý sửa chữa

Nếu cần hỗ trợ, vui lòng liên hệ hotline...
```

### Chẩn Đoán Lỗi

**Mô tả lỗi mẫu:**
```
✅ "Khóa không nhận vân tay"
✅ "Khóa kêu bíp liên tục"
✅ "Khóa không kết nối app"
✅ "Khóa không có điện"
✅ "Khóa không mở bằng mật khẩu"
```

**Ví dụ Response:**
```
Khóa không nhận vân tay có thể do:

1. Cảm biến bị bẩn: Làm sạch bằng khăn mềm, không dùng hóa chất
2. Vân tay chưa đăng ký: Đăng ký lại vân tay trên khóa
3. Pin yếu: Thay pin mới (thường là pin AA 4-8 viên)
4. Cảm biến bị lỗi: Reset factory và đăng ký lại

Thử các bước trên, nếu vẫn không được, vui lòng liên hệ kỹ thuật viên.
```

## 🔧 Các Lỗi Thường Gặp

### 1. Khóa không nhận vân tay
- Làm sạch cảm biến
- Đăng ký lại vân tay
- Kiểm tra pin

### 2. Khóa không mở bằng mật khẩu
- Reset mật khẩu
- Kiểm tra pin
- Reset factory

### 3. Khóa không kết nối app
- Kiểm tra WiFi/Bluetooth
- Reset kết nối
- Cập nhật app

### 4. Khóa kêu bíp liên tục
- Pin yếu → Thay pin
- Lỗi cảm biến → Reset
- Khóa cửa sai cách → Kiểm tra lại

### 5. Khóa không có điện
- Thay pin mới
- Kiểm tra tiếp xúc pin
- Dùng chìa cơ khẩn cấp

### 6. Khóa báo lỗi
- Xem mã lỗi cụ thể
- Reset khóa
- Liên hệ kỹ thuật

## 📊 Frontend Integration

### Service Method

```typescript
// Warranty advice
this.aiService.warrantyAdvice('Khóa bảo hành bao lâu?')
  .subscribe(response => {
    console.log(response.response);
  });

// Diagnose issue
this.aiService.diagnoseIssue('Khóa không nhận vân tay')
  .subscribe(response => {
    console.log(response.response);
  });
```

### Chatbot Integration

Chatbot có thể tự động detect intent và route:

```typescript
// Detect warranty query
if (query.includes('bảo hành') || query.includes('warranty')) {
  this.aiService.warrantyAdvice(query).subscribe(...);
}

// Detect issue query
if (query.includes('lỗi') || query.includes('không') || query.includes('issue')) {
  this.aiService.diagnoseIssue(query).subscribe(...);
}
```

## 🎨 Prompt Engineering

### Warranty Prompt

- **Role**: Chuyên viên tư vấn bảo hành
- **Tone**: Chuyên nghiệp, thân thiện
- **Length**: 100-200 từ
- **Focus**: Thông tin cụ thể, rõ ràng

### Diagnostic Prompt

- **Role**: Kỹ thuật viên chẩn đoán
- **Tone**: Chuyên nghiệp, hữu ích
- **Length**: 150-250 từ
- **Focus**: Giải pháp thực tế, dễ thực hiện

## 🔍 Troubleshooting

### Lỗi: "Query cannot be empty"
**Giải pháp**: Đảm bảo gửi query/issue không rỗng

### Lỗi: "AI không hiểu câu hỏi"
**Giải pháp**: 
- Viết câu hỏi rõ ràng hơn
- Thêm context (tên khóa, model)

### Response không chính xác
**Giải pháp**:
- Cung cấp thông tin chi tiết hơn
- Kiểm tra prompt có cần update không

## 📈 Improvements

### Planned Features
- [ ] Tự động detect intent từ query
- [ ] Tích hợp với database sản phẩm để lấy thông tin bảo hành cụ thể
- [ ] Chatbot tự động suggest warranty/diagnostic khi phát hiện vấn đề
- [ ] Tạo ticket tự động khi cần hỗ trợ kỹ thuật
- [ ] Lưu lịch sử chẩn đoán để cải thiện

## 🎯 Best Practices

### Warranty Questions
- ✅ Rõ ràng: "Khóa bảo hành bao lâu?"
- ❌ Mơ hồ: "Bảo hành như thế nào?"

### Issue Descriptions
- ✅ Chi tiết: "Khóa Samsung không nhận vân tay, đã thử làm sạch"
- ❌ Quá ngắn: "Khóa bị lỗi"

## 📞 Support

Nếu cần custom prompts hoặc thêm lỗi mới:
- Sửa file: `AIProductAssistantService.java`
- Methods: `createWarrantyPrompt()`, `createDiagnosticPrompt()`

---

**Version**: 1.0.0  
**Last Updated**: 04/11/2025

