# 🔧 Sửa lỗi: AI không tìm thấy sản phẩm F300-FH trong ChromaDB

## 📋 Vấn đề

Khi khách hàng hỏi về sản phẩm "F300-FH" hoặc "GATEMAN F300-FH", AI chatbot báo không có hàng mặc dù sản phẩm đã được index vào ChromaDB.

## 🔍 Nguyên nhân

1. **Minimum score quá cao (0.6)**: 
   - Vector search chỉ trả về sản phẩm có độ tương đồng cosine >= 0.6
   - Tên model ngắn như "F300-FH" có embedding không đạt ngưỡng này

2. **Embedding của tên model ngắn**:
   - Tên "F300-FH" ngắn, có ký tự đặc biệt (dấu gạch ngang)
   - Embedding model có thể không hiểu tốt và tạo ra embedding không tương đồng với embedding đã lưu

3. **Không có fallback search**:
   - Khi vector search không tìm thấy, hệ thống không thử tìm kiếm exact/partial match trong database

## ✅ Giải pháp đã áp dụng

### 1. Giảm minimum score
- **File**: `VectorSearchServiceImpl.java`
- **Thay đổi**: Giảm minimum score từ `0.6` xuống `0.4`
- **Fallback**: Nếu không tìm thấy với 0.4, thử lại với 0.3

```java
// Trước:
0.6, // minimum score

// Sau:
0.4, // minimum score - giảm để tìm được sản phẩm có tên model ngắn
```

### 2. Thêm fallback exact/partial match search
- **File**: `AIProductAssistantService.java`
- **Thay đổi**: Thêm method `searchProductsByExactMatch()` để tìm kiếm trong database khi vector search không tìm thấy
- **Logic**: 
  - Tìm kiếm sản phẩm có tên chứa query (case-insensitive)
  - Chuyển đổi Product thành Document để tương thích với logic hiện tại

### 3. Cập nhật searchByImage
- **File**: `VectorSearchServiceImpl.java`
- **Thay đổi**: Giảm minimum score cho image search từ 0.6 xuống 0.4

## 📊 Kết quả kiểm tra

### Dữ liệu trong ChromaDB:
- ✅ Sản phẩm **GATEMAN F300-FH** (Product ID: 14) đã được index
- ⚠️ Có **20 documents trùng lặp** cho cùng một sản phẩm (cần dọn dẹp)

### Test cases:
1. Query: "F300-FH" → Sẽ tìm thấy với minimum score 0.4 hoặc fallback exact match
2. Query: "GATEMAN F300" → Sẽ tìm thấy với vector search
3. Query: "khóa vân tay F300" → Sẽ tìm thấy với vector search

## 🚀 Cách test

1. **Restart Backend** để áp dụng thay đổi
2. **Test với chatbot**:
   - Hỏi: "Tôi cần khóa F300-FH"
   - Hỏi: "Có khóa GATEMAN F300-FH không?"
   - Hỏi: "F300FH"

3. **Kiểm tra logs**:
   - Xem log có message "Vector search returned no results, trying exact/partial match fallback"
   - Xem log có message "Found X products using exact/partial match"

## 📝 Lưu ý

1. **Dọn dữ liệu trùng lặp**: Có 20 documents cho cùng product_id 14, nên xóa và re-index
2. **Monitor performance**: Giảm minimum score có thể trả về nhiều kết quả không liên quan, cần monitor và điều chỉnh
3. **Cải thiện indexing**: Có thể cải thiện cách format nội dung khi index để embedding tốt hơn cho tên model ngắn

## 🔄 Các bước tiếp theo (tùy chọn)

1. **Dọn dữ liệu trùng lặp trong ChromaDB**:
   ```bash
   # Xóa collection và re-index
   POST /api/v1/ai/initialize/clear-index
   POST /api/v1/ai/initialize/index-all
   ```

2. **Cải thiện indexing**:
   - Thêm alias/từ khóa cho tên model ngắn
   - Format nội dung index tốt hơn để embedding hiểu rõ hơn

3. **Thêm fuzzy search**:
   - Sử dụng fuzzy matching cho tên model
   - Xử lý các biến thể: "F300-FH", "F300FH", "F300 FH"

