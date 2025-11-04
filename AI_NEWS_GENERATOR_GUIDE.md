# 📰 AI News Content Generator - Hướng Dẫn

## ✨ Tính Năng

AI News Generator tự động tạo nội dung tin tức chuyên nghiệp về khóa điện tử, công nghệ an ninh sử dụng Google Gemini AI.

## 🎯 Mục Đích

- **Tiết kiệm thời gian**: Tạo nội dung 800-1200 từ trong vài giây
- **Chất lượng cao**: Nội dung chuyên nghiệp, có cấu trúc rõ ràng
- **SEO-friendly**: HTML formatting chuẩn, từ khóa tối ưu
- **Nhất quán**: Giọng văn thống nhất, phù hợp thương hiệu

## 🚀 Cách Sử Dụng

### 1. Truy Cập Quản Lý Tin Tức

```
/newsManage
```

### 2. Tạo Tin Tức Mới

1. Click **"Thêm tin tức"**
2. Nhập **Tiêu đề** (bắt buộc)
3. Nhập **Danh mục** (tùy chọn) - Giúp AI hiểu chủ đề
4. Nhập **Tóm tắt** (tùy chọn) - Cung cấp từ khóa/hướng dẫn cho AI

### 3. Generate Nội Dung

Click nút **"✨ Tạo nội dung bằng AI"**

AI sẽ:
- Phân tích tiêu đề
- Sử dụng danh mục và tóm tắt (nếu có)
- Tạo bài viết 800-1200 từ
- Format với HTML chuẩn
- Tự động điền vào editor

**Thời gian**: 10-20 giây

### 4. Chỉnh Sửa và Xuất Bản

- Xem xét nội dung AI tạo ra
- Chỉnh sửa nếu cần (sử dụng rich text editor)
- Thêm ảnh đại diện
- Chọn trạng thái
- Lưu hoặc Xuất bản

## 💡 Ví Dụ Sử Dụng

### Ví dụ 1: Bài viết giới thiệu sản phẩm

**Input:**
- Tiêu đề: "Top 5 khóa vân tay thông minh cho gia đình hiện đại"
- Danh mục: "Sản phẩm"
- Tóm tắt: "So sánh tính năng, giá cả, ưu nhược điểm"

**Output:**
AI sẽ tạo bài viết với:
- Mở bài giới thiệu xu hướng smart lock
- 5 phần chi tiết về từng loại khóa
- So sánh tính năng, giá cả
- Lời khuyên chọn mua
- Kết luận và CTA

### Ví dụ 2: Bài viết hướng dẫn

**Input:**
- Tiêu đề: "Hướng dẫn lắp đặt khóa điện tử cho người mới"
- Danh mục: "Hướng dẫn"
- Tóm tắt: "Từng bước, dụng cụ cần thiết, lưu ý an toàn"

**Output:**
AI tạo:
- Chuẩn bị dụng cụ
- Các bước lắp đặt chi tiết
- Lưu ý quan trọng
- Xử lý sự cố thường gặp
- Tips bảo trì

### Ví dụ 3: Tin tức công nghệ

**Input:**
- Tiêu đề: "Xu hướng công nghệ smart lock 2025"
- Danh mục: "Công nghệ"
- Tóm tắt: "AI, IoT, tích hợp smart home"

**Output:**
AI viết về:
- Tổng quan thị trường
- Công nghệ mới nổi bật
- Dự báo xu hướng
- Ảnh hưởng đến người dùng
- Kết luận

## 📋 Cấu Trúc Nội Dung AI Tạo Ra

```html
<h2>1. Mở Bài</h2>
<p>Giới thiệu chủ đề, thu hút người đọc...</p>

<h2>2. Nội Dung Chính</h2>
<p>Đoạn văn chi tiết với <strong>từ khóa quan trọng</strong>...</p>

<ul>
  <li>Điểm 1 với giải thích</li>
  <li>Điểm 2 với ví dụ</li>
  <li>Điểm 3 với so sánh</li>
</ul>

<h2>3. Phân Tích Chuyên Sâu</h2>
<p>Thông tin kỹ thuật, số liệu...</p>

<blockquote>
  Trích dẫn hoặc tip quan trọng
</blockquote>

<h2>4. Lời Khuyên Thực Tế</h2>
<p>Hướng dẫn cụ thể cho người dùng...</p>

<h2>5. Kết Luận</h2>
<p>Tóm tắt và призыв к действию...</p>
```

## 🎨 Đặc Điểm Nội Dung

### 1. Giọng Văn
- **Chuyên nghiệp**: Thông tin chính xác, có căn cứ
- **Thân thiện**: Dễ hiểu, gần gũi với người đọc
- **Tư vấn**: Đưa ra lời khuyên hữu ích

### 2. Nội Dung
- **Liên quan khóa điện tử**: Smart lock, vân tay, IoT
- **An ninh gia đình**: Bảo mật, công nghệ
- **Thực tế**: Tips, hướng dẫn cụ thể
- **Cập nhật**: Xu hướng công nghệ mới

### 3. HTML Formatting
- `<h2>`: Tiêu đề phụ
- `<p>`: Đoạn văn
- `<strong>`: Từ khóa quan trọng
- `<ul><li>`: Danh sách
- `<blockquote>`: Trích dẫn/highlight

### 4. SEO
- Từ khóa tự nhiên
- Cấu trúc heading rõ ràng
- Độ dài tối ưu (800-1200 từ)
- Internal linking suggestions

## ⚙️ Cấu Hình

### Backend Prompt Configuration

File: `AIChatController.java`

```java
private String createNewsGenerationPrompt(String title, String topic, String keywords) {
    // Tùy chỉnh prompt tại đây:
    // - Thay đổi độ dài (800-1200 từ)
    // - Điều chỉnh giọng văn
    // - Thêm/bớt yêu cầu formatting
    // - Tùy chỉnh chủ đề phù hợp
}
```

### Thời Gian Generate

- **Trung bình**: 10-15 giây
- **Tối đa**: 30 giây
- **Phụ thuộc vào**:
  - Độ dài tiêu đề
  - Số lượng từ khóa
  - Tải server Gemini

## 🔧 Troubleshooting

### Lỗi: "Vui lòng nhập tiêu đề"
**Nguyên nhân**: Chưa nhập tiêu đề
**Giải pháp**: Nhập tiêu đề trước khi click AI Generate

### Lỗi: "Không thể kết nối đến server AI"
**Nguyên nhân**: Backend không chạy hoặc network issue
**Giải pháp**: 
- Kiểm tra backend đang chạy
- Kiểm tra kết nối mạng
- Verify Google Cloud credentials

### Lỗi: "Lỗi server khi tạo nội dung"
**Nguyên nhân**: Google Cloud credentials sai/hết hạn
**Giải pháp**:
```bash
# Kiểm tra credentials
echo $GOOGLE_APPLICATION_CREDENTIALS

# Test authentication
gcloud auth application-default login

# Restart backend
```

### Nội dung không phù hợp
**Giải pháp**:
1. Viết tiêu đề rõ ràng, cụ thể hơn
2. Thêm thông tin vào Danh mục và Tóm tắt
3. Generate lại
4. Chỉnh sửa thủ công

### Generate chậm (>30s)
**Nguyên nhân**: 
- Gemini API bị overload
- Prompt quá phức tạp
**Giải pháp**:
- Thử lại sau vài phút
- Rút gọn tóm tắt/từ khóa

## 💰 Chi Phí

### Google Gemini API Pricing

**Gemini 2.0 Flash:**
- Input: $0.075 / 1M tokens
- Output: $0.30 / 1M tokens

**Ước tính mỗi bài:**
- Input: ~200-300 tokens ($0.00002-0.00003)
- Output: ~1500-2000 tokens ($0.00045-0.00060)
- **Tổng**: ~$0.0005 (0.5 cent) / bài

**100 bài/tháng**: ~$0.05 (rất rẻ!)

## 🎯 Best Practices

### 1. Viết Tiêu Đề Tốt
✅ **Tốt**: "5 lý do nên nâng cấp lên khóa vân tay cho căn hộ chung cư"
❌ **Không tốt**: "Khóa vân tay"

### 2. Sử Dụng Danh Mục
- "Sản phẩm" → Tập trung so sánh sản phẩm
- "Hướng dẫn" → Tập trung instructions
- "Công nghệ" → Tập trung tech trends
- "An ninh" → Tập trung security tips

### 3. Tóm Tắt Hiệu Quả
✅ **Tốt**: "So sánh Samsung vs Dessmann, tính năng vân tay, WiFi, giá cả"
❌ **Không tốt**: "Viết về khóa"

### 4. Luôn Xem Xét Lại
- AI tạo nội dung tốt nhưng cần human review
- Kiểm tra facts, số liệu
- Điều chỉnh cho phù hợp thương hiệu
- Thêm CTA, links nội bộ

### 5. Tối Ưu SEO
- Thêm meta description (từ tóm tắt)
- Tối ưu tiêu đề với từ khóa
- Thêm alt text cho ảnh
- Internal linking

## 📊 Metrics & Analytics

### Tracking Generation Stats
- Số bài được generate
- Thời gian trung bình
- Success rate
- Tỷ lệ chỉnh sửa sau generate

### Quality Metrics
- Độ dài nội dung
- Keyword density
- Readability score
- Engagement (views, shares)

## 🚀 Future Enhancements

### Planned Features
- [ ] Generate từ outline
- [ ] Multi-language support
- [ ] Custom tone/style
- [ ] SEO optimization suggestions
- [ ] Image suggestion based on content
- [ ] Auto-generate meta tags
- [ ] Plagiarism check
- [ ] Content scheduling

## 📄 API Documentation

### Endpoint

```http
POST /api/v1/ai/chat/generate-news
Content-Type: application/json

{
  "title": "string (required)",
  "topic": "string (optional)",
  "keywords": "string (optional)"
}
```

### Response

```json
{
  "content": "<h2>Title</h2><p>Content...</p>",
  "success": true,
  "timestamp": 1699234567890
}
```

### Error Response

```json
{
  "error": "Error message",
  "success": false
}
```

## 🎓 Tips & Tricks

### 1. Template Titles
Sử dụng các mẫu tiêu đề hiệu quả:
- "Top X [sản phẩm] cho [đối tượng]"
- "Hướng dẫn [hoạt động] cho người mới"
- "So sánh [A] vs [B]: Nên chọn cái nào?"
- "[Số] lý do nên [hành động]"
- "Xu hướng [chủ đề] năm 2025"

### 2. Content Variations
Generate nhiều lần với tiêu đề tương tự để có nhiều góc nhìn.

### 3. Combine with Manual
- Generate outline/structure
- Tự viết chi tiết
- Hoặc ngược lại

### 4. Batch Generation
Generate nhiều bài cùng lúc cho content calendar.

## 📞 Support

Nếu gặp vấn đề:
1. Kiểm tra logs: `logs/sneakers-app.log`
2. Xem AI Chatbot Guide: `AI_CHATBOT_GUIDE.md`
3. Liên hệ dev team

---

**Version**: 1.0.0  
**Last Updated**: 04/11/2025  
**Author**: Locker Korea Team

