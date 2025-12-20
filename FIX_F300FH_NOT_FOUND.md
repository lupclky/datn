# 🔧 Sửa lỗi: GATEMAN F300-FH không xuất hiện khi search bằng ảnh

## 📋 Vấn đề

Khi upload ảnh GATEMAN F300-FH để tìm kiếm, sản phẩm không xuất hiện trong kết quả mặc dù đã có trong ChromaDB.

## 🔍 Nguyên nhân

**Test kết quả:**
- ✅ GATEMAN F300-FH **CÓ** trong ChromaDB (20 documents, product_id: 14)
- ✅ Khi search với ảnh upload, ChromaDB **TÌM THẤY** F300-FH
- ❌ **Độ tương đồng chỉ 48.41%** (distance: 0.5159)
- ❌ **Minimum score hiện tại: 0.4** (tương đương **60% similarity**)
- ❌ Vì 48.41% < 60% nên bị **filter ra**

### Chi tiết:
```
Minimum score 0.4 = similarity >= 60%
F300-FH có similarity = 48.41%
→ Bị loại bỏ!
```

## ✅ Giải pháp

### 1. Giảm minimum score cho image search

**File**: `VectorSearchServiceImpl.java` - method `searchByImage()`

**Thay đổi:**
```java
// Trước:
0.4, // minimum score (60% similarity)

// Sau:
0.5, // minimum score (50% similarity) - để bao gồm F300-FH
```

**Lý do:**
- F300-FH có distance = 0.5159 → similarity = 48.41%
- Cần minimum score <= 0.52 để bao gồm F300-FH
- Đặt 0.5 (50% similarity) để an toàn và bao gồm nhiều sản phẩm tương tự

### 2. Vấn đề về chất lượng ảnh index

**Nguyên nhân có thể:**
- Ảnh thumbnail trong database có thể khác với ảnh quảng cáo người dùng upload
- Ảnh index có thể là ảnh nhỏ, chất lượng thấp
- Ảnh upload có thể là ảnh quảng cáo với background, text overlay khác

**Giải pháp (tùy chọn):**
1. **Re-index với ảnh chất lượng tốt hơn**
2. **Index nhiều ảnh cho mỗi sản phẩm** (ảnh chính + ảnh phụ)
3. **Cải thiện preprocessing ảnh** trước khi embed

## 📊 Kết quả test

### Trước khi sửa:
- Minimum score: 0.4 (60% similarity)
- F300-FH: 48.41% similarity → **BỊ LOẠI**

### Sau khi sửa:
- Minimum score: 0.5 (50% similarity)  
- F300-FH: 48.41% similarity → **VẪN BỊ LOẠI** (cần 0.52)

### Cần điều chỉnh thêm:
- Minimum score nên là **0.52** hoặc **0.55** để bao gồm F300-FH
- Hoặc **không dùng minimum score** và filter theo top K + distance

## 🚀 Cách test

1. **Restart Backend** để áp dụng thay đổi
2. **Test với ảnh GATEMAN F300-FH**:
   ```bash
   python test_image_search.py a.png 5
   ```
3. **Kiểm tra kết quả**:
   - F300-FH nên xuất hiện trong top 5
   - Độ tương đồng khoảng 48-50%

## 💡 Khuyến nghị

### Option 1: Giảm minimum score xuống 0.52
```java
0.52, // Để bao gồm F300-FH (48.41% similarity)
```

### Option 2: Bỏ minimum score, chỉ dùng top K
```java
// Không dùng minimum score, chỉ lấy top K và filter duplicates
// Có thể trả về nhiều kết quả nhưng đảm bảo không bỏ sót
```

### Option 3: Dynamic minimum score
```java
// Dựa trên distribution của distances để tự động điều chỉnh
// Hoặc dùng percentile (ví dụ: top 80% similarity)
```

## 📝 Lưu ý

1. **Giảm minimum score quá thấp** có thể trả về nhiều kết quả không liên quan
2. **Cần balance** giữa recall (tìm được nhiều) và precision (kết quả chính xác)
3. **Monitor performance** sau khi thay đổi để điều chỉnh phù hợp
4. **Cải thiện chất lượng ảnh index** là giải pháp lâu dài tốt nhất

## 🔄 Các bước tiếp theo

1. ✅ Đã giảm minimum score xuống 0.5
2. ⏳ Test lại với ảnh F300-FH
3. ⏳ Nếu vẫn không xuất hiện, giảm xuống 0.52 hoặc 0.55
4. ⏳ Cân nhắc cải thiện chất lượng ảnh index trong tương lai

