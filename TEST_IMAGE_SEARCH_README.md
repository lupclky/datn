# 🖼️ Hướng Dẫn Test Tìm Kiếm Sản Phẩm Bằng Hình Ảnh

## 📋 Yêu cầu

1. **ChromaDB** đang chạy tại `http://localhost:8000`
2. **Python Embedding Service** đang chạy tại `http://localhost:9001`
3. Python 3.8+ và các thư viện cần thiết

## 🚀 Cài đặt

### Cài đặt dependencies (cho Web App)

```bash
pip install -r requirements_test.txt
```

Hoặc cài đặt thủ công:

```bash
pip install flask requests
```

## 📝 Cách sử dụng

### Option 1: Script Command Line (Đơn giản)

```bash
# Cú pháp
python test_image_search.py <đường_dẫn_ảnh> [top_k]

# Ví dụ
python test_image_search.py image.jpg
python test_image_search.py image.jpg 10
```

**Ví dụ output:**
```
================================================================================
🖼️  TEST TÌM KIẾM SẢN PHẨM BẰNG HÌNH ẢNH - CHROMADB
================================================================================

📁 File ảnh: image.jpg
🔢 Top K: 5

📸 Bước 1: Đang đọc và mã hóa ảnh...
✅ Đã mã hóa ảnh thành base64 (123456 ký tự)

🧮 Bước 2: Đang embed ảnh thành vector...
🔄 Đang mã hóa ảnh thành vector...
✅ Mã hóa thành công! Vector có 512 chiều

🔎 Bước 3: Đang tìm kiếm trong ChromaDB...
🔍 Đang tìm kiếm trong ChromaDB (top 5)...

📊 Bước 4: Kết quả tìm kiếm:
================================================================================
✅ Tìm thấy 5 sản phẩm tương tự:
================================================================================

────────────────────────────────────────────────────────────────────────────────
Kết quả #1
────────────────────────────────────────────────────────────────────────────────
📊 Độ tương đồng: 85.23% (distance: 0.1477)
🆔 Product ID: 14
📦 Tên sản phẩm: GATEMAN F300-FH
🏷️  Danh mục: GATEMAN
💰 Giá: 7,950,000 VND
🎯 Giảm giá: 60%
📄 Loại: product_image
...
```

### Option 2: Web App (Giao diện đẹp)

```bash
# Chạy web app
python test_image_search_web.py
```

Sau đó mở trình duyệt và truy cập: **http://localhost:5000**

**Tính năng:**
- ✅ Drag & drop ảnh
- ✅ Preview ảnh trước khi search
- ✅ Hiển thị kết quả với giao diện đẹp
- ✅ Hiển thị độ tương đồng (similarity %)
- ✅ Hiển thị đầy đủ thông tin sản phẩm

## 🔍 Kiểm tra Services

### Kiểm tra ChromaDB

```bash
curl http://localhost:8000/api/v1/heartbeat
```

### Kiểm tra Embedding Service

```bash
curl http://localhost:9001/health
```

## 📊 Cấu trúc dữ liệu kết quả

Mỗi kết quả trả về gồm:

```json
{
  "id": "document-id",
  "metadata": {
    "product_id": 14,
    "product_name": "GATEMAN F300-FH",
    "category_name": "GATEMAN",
    "price": 7950000,
    "discount": 60,
    "features": "...",
    "type": "product_image"
  },
  "document": "Image of GATEMAN F300-FH",
  "distance": 0.1477
}
```

**Lưu ý:**
- `distance`: Khoảng cách cosine (càng nhỏ càng giống)
- `similarity = (1 - distance) * 100`: Phần trăm tương đồng
- `type`: `product` (text) hoặc `product_image` (image embedding)

## 🐛 Troubleshooting

### Lỗi: "Không thể kết nối đến Embedding Service"

**Nguyên nhân:** Python Embedding Service chưa chạy

**Giải pháp:**
```bash
cd python-embedding-service
python -m uvicorn app:app --host 0.0.0.0 --port 9001
```

### Lỗi: "Không thể kết nối đến ChromaDB"

**Nguyên nhân:** ChromaDB chưa chạy

**Giải pháp:**
```bash
# Docker
docker-compose up -d chroma-container

# Hoặc
chroma run --host 0.0.0.0 --port 8000
```

### Lỗi: "Không tìm thấy collection"

**Nguyên nhân:** Collection chưa được tạo hoặc chưa index dữ liệu

**Giải pháp:**
```bash
# Index dữ liệu từ Backend
POST http://localhost:8089/api/v1/ai/initialize/index-all
```

### Kết quả trống

**Nguyên nhân có thể:**
1. Ảnh không tương tự với bất kỳ sản phẩm nào trong database
2. Minimum score quá cao (đã fix trong code)
3. Chưa có dữ liệu trong ChromaDB

**Giải pháp:**
- Thử với ảnh sản phẩm thực tế từ cửa hàng
- Kiểm tra xem ChromaDB đã có dữ liệu chưa
- Giảm minimum score trong code nếu cần

## 📸 Test với ảnh mẫu

Bạn có thể test với:
1. Ảnh sản phẩm từ website/catalog
2. Ảnh chụp sản phẩm thực tế
3. Ảnh từ Google Images (tìm "GATEMAN F300-FH")

## 💡 Tips

1. **Ảnh chất lượng tốt**: Ảnh rõ nét, đủ ánh sáng sẽ cho kết quả tốt hơn
2. **Ảnh sản phẩm chính**: Ảnh chụp sản phẩm chính (không phải ảnh phụ) sẽ match tốt hơn
3. **Top K**: Tăng `top_k` nếu muốn xem nhiều kết quả hơn (mặc định 5)

## 🔄 Cập nhật

Nếu thay đổi cấu hình (URL, port, collection name), sửa trong file:
- `test_image_search.py`: Sửa các biến ở đầu file
- `test_image_search_web.py`: Sửa các biến ở đầu file

