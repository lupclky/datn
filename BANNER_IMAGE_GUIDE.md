# Hướng dẫn sử dụng hình ảnh cho Banner

## Độ phân giải khuyến nghị

### Tốt nhất (Optimal)
- **1920 x 600 pixels** - Phù hợp cho màn hình desktop hiện đại
- Tỷ lệ 16:5 (widescreen)
- File size: < 500KB để tối ưu tốc độ tải

### Các độ phân giải khác có thể sử dụng
- **1920 x 800 pixels** - Phù hợp cho banner cao hơn
- **1600 x 500 pixels** - Phù hợp cho màn hình nhỏ hơn  
- **2560 x 800 pixels** - Cho màn hình 2K/4K

## Giới hạn kỹ thuật
- **Kích thước file tối đa**: 5MB
- **Định dạng được khuyến nghị**:
  - WebP (tối ưu nhất)
  - JPEG/JPG (chất lượng tốt, dung lượng trung bình)
  - PNG (chất lượng cao nhất, dung lượng lớn)

## Vùng an toàn (Safe Zone)
Nếu banner có text hoặc nút bấm, đảm bảo chúng nằm trong vùng an toàn:
- **Left margin**: 100px từ cạnh trái
- **Right margin**: 100px từ cạnh phải  
- **Top margin**: 80px từ cạnh trên
- **Bottom margin**: 80px từ cạnh dưới

## Lưu ý khi thiết kế
1. **Contrast cao**: Đảm bảo text rõ ràng trên background
2. **Mobile responsive**: Banner sẽ tự động scale trên mobile
3. **File optimization**: Nén ảnh trước khi upload để tối ưu performance
4. **CTA Button**: Vị trí nút call-to-action nên ở giữa hoặc phía dưới banner

## Ví dụ cấu trúc Banner
```
┌────────────────────────────────────────────────┐
│  [100px margin]                                │
│  ┌──────────────────────────────────────────┐  │ 80px
│  │  TIÊU ĐỀ BANNER (Large Text)            │  │
│  │  Mô tả ngắn gọn về ưu đãi/sản phẩm       │  │
│  │                                          │  │
│  │  [XEM NGAY] ← Button                     │  │
│  └──────────────────────────────────────────┘  │ 80px
│                                  [100px margin] │
└────────────────────────────────────────────────┘
        1920px width
```

## Tools đề xuất để tạo/chỉnh sửa banner
- **Online**: Canva, Figma, Adobe Express
- **Desktop**: Photoshop, GIMP
- **Optimization**: TinyPNG, ImageOptim

## Checklist trước khi upload
- [ ] Độ phân giải đạt 1920x600px (hoặc tương đương)
- [ ] File size < 500KB
- [ ] Text/Button nằm trong vùng an toàn
- [ ] Contrast text/background đủ cao
- [ ] Định dạng file: WebP, JPG hoặc PNG
- [ ] Đã test preview trên nhiều kích thước màn hình




