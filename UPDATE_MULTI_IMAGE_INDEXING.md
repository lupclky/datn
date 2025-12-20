# 🖼️ Cập nhật: Index nhiều ảnh sản phẩm vào ChromaDB

## 📋 Mục tiêu

Cập nhật hệ thống để index **tất cả ảnh sản phẩm** (không chỉ thumbnail) vào ChromaDB, giúp tìm kiếm chính xác hơn khi người dùng upload ảnh.

## 🔍 Vấn đề trước đây

- Chỉ index **1 ảnh thumbnail** cho mỗi sản phẩm
- Nếu ảnh upload khác với thumbnail → độ tương đồng thấp → không tìm thấy
- Ví dụ: GATEMAN F300-FH có thumbnail khác với ảnh quảng cáo → không match

## ✅ Giải pháp đã áp dụng

### 1. Thêm method mới trong ProductRepository

**File**: `ProductRepository.java`

```java
// Method mới để load product với cả features và images
@Query("SELECT DISTINCT p FROM Product p LEFT JOIN FETCH p.productFeatures pf " +
       "LEFT JOIN FETCH pf.feature LEFT JOIN FETCH p.category " +
       "LEFT JOIN FETCH p.productImages")
List<Product> findAllWithFeaturesAndImages();

// Cập nhật method findByIdWithFeatures để cũng load images
@Query("SELECT DISTINCT p FROM Product p LEFT JOIN FETCH p.productFeatures pf " +
       "LEFT JOIN FETCH pf.feature LEFT JOIN FETCH p.category " +
       "LEFT JOIN FETCH p.productImages WHERE p.id = :productId")
Optional<Product> findByIdWithFeatures(@Param("productId") Long productId);
```

### 2. Cập nhật logic index trong VectorSearchServiceImpl

**File**: `VectorSearchServiceImpl.java`

#### Thay đổi 1: Sử dụng method mới khi load products
```java
// Trước:
List<Product> products = productRepository.findAllWithFeatures();

// Sau:
List<Product> products = productRepository.findAllWithFeaturesAndImages();
```

#### Thay đổi 2: Index tất cả ảnh thay vì chỉ thumbnail

**Trước:**
```java
// Chỉ index thumbnail
if (thumbnail != null && !thumbnail.isEmpty()) {
    // Index thumbnail...
}
```

**Sau:**
```java
// Index thumbnail (nếu có)
if (thumbnail != null && !thumbnail.isEmpty()) {
    indexSingleImage(product, thumbnail, metadata, 0, true);
}

// Index tất cả ảnh trong productImages
if (product.getProductImages() != null && !product.getProductImages().isEmpty()) {
    int imageIndex = 1;
    for (var productImage : product.getProductImages()) {
        if (!productImage.getImageUrl().equals(thumbnail)) { // Tránh duplicate
            indexSingleImage(product, productImage.getImageUrl(), metadata, imageIndex, false);
            imageIndex++;
        }
    }
}
```

#### Thay đổi 3: Tạo method helper `indexSingleImage()`

```java
private void indexSingleImage(Product product, String imageUrl, 
                              Map<String, String> baseMetadata, 
                              int imageIndex, boolean isThumbnail) {
    // Embed ảnh
    // Tạo metadata với:
    // - type: "product_image"
    // - image_index: 0 (thumbnail) hoặc 1, 2, 3... (productImages)
    // - image_url: URL của ảnh
    // - is_thumbnail: true/false
    // Lưu vào ChromaDB
}
```

## 📊 Kết quả

### Trước khi cập nhật:
- Mỗi sản phẩm: **1 document text + 1 document image** (thumbnail)
- Tổng: **2 documents/sản phẩm**

### Sau khi cập nhật:
- Mỗi sản phẩm: **1 document text + N documents image** (thumbnail + tất cả productImages)
- Ví dụ: Sản phẩm có 5 ảnh → **1 text + 5 images = 6 documents**
- Tổng: **1 + N documents/sản phẩm** (N = số ảnh)

## 🎯 Lợi ích

1. **Tìm kiếm chính xác hơn**: Nhiều góc nhìn/ảnh khác nhau → nhiều cơ hội match
2. **Giảm false negative**: Ảnh upload không giống thumbnail vẫn có thể match với ảnh khác
3. **Cải thiện recall**: Tìm được nhiều sản phẩm hơn với độ tương đồng tốt

## 🔄 Metadata mới

Mỗi document image trong ChromaDB có thêm metadata:
- `image_index`: 0 (thumbnail) hoặc 1, 2, 3... (productImages)
- `image_url`: URL của ảnh cụ thể
- `is_thumbnail`: "true" hoặc "false"

## 🚀 Cách sử dụng

### 1. Re-index tất cả dữ liệu

```bash
# Gọi API để re-index
POST /api/v1/ai/initialize/index-all
```

### 2. Re-index một sản phẩm cụ thể

```bash
# Khi update sản phẩm, hệ thống tự động re-index
PUT /api/v1/products/{id}
```

### 3. Kiểm tra số lượng documents

```bash
python check_chromadb_data.py
```

## 📝 Lưu ý

1. **Dữ liệu cũ**: Cần re-index để có nhiều ảnh cho mỗi sản phẩm
2. **Storage**: Nhiều ảnh hơn → nhiều documents hơn → tăng storage ChromaDB
3. **Performance**: Index nhiều ảnh mất thời gian hơn, nhưng search sẽ tốt hơn
4. **Duplicate check**: Logic đã tránh index thumbnail 2 lần nếu nó cũng có trong productImages

## 🔍 Test

Sau khi re-index, test với:
```bash
python test_image_search.py gateman-f300fh_2048x2048-1.jpg 10
```

Kết quả mong đợi:
- GATEMAN F300-FH sẽ xuất hiện với độ tương đồng cao hơn
- Có thể có nhiều documents của cùng 1 sản phẩm (nhưng đã filter duplicates)

## ⚠️ Breaking Changes

- **Không có**: Code backward compatible
- Chỉ cần **re-index** để có dữ liệu mới

