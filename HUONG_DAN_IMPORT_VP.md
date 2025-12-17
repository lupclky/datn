# Hướng Dẫn Import Biểu Đồ Lớp vào Visual Paradigm

## ⚠️ LƯU Ý QUAN TRỌNG

Visual Paradigm hỗ trợ import **PlantUML** tốt hơn XMI. Khuyến nghị sử dụng file PlantUML.

---

## Phương Pháp 1: Import PlantUML (KHUYẾN NGHỊ) ✅

### Bước 1: Kiểm tra Plugin PlantUML
1. Mở **Visual Paradigm**
2. Vào menu: **Tools** → **External Tools** → **PlantUML**
3. Nếu không thấy, cần cài đặt:
   - **Tools** → **External Tools** → **Manage External Tools...**
   - Tìm và cài **PlantUML Integration**

### Bước 2: Import File PlantUML
1. Trong Visual Paradigm, chọn: **Tools** → **External Tools** → **PlantUML** → **Import from PlantUML...**
2. Hoặc: **File** → **Import** → **Import from PlantUML...**
3. Chọn file: `LockerKorea_ClassDiagram_TheoMau.puml`
4. Nhấn **Import**
5. Visual Paradigm sẽ tự động tạo biểu đồ lớp

### Bước 3: Tùy Chỉnh Style (Nếu cần)
Sau khi import, để có style giống mẫu:
1. Chọn tất cả các lớp (Ctrl+A)
2. Right-click → **Format** → **Fill Color** → Chọn **Light Blue**
3. Right-click → **Format** → **Line Color** → Chọn **Black**
4. Để thay đổi header:
   - Right-click vào lớp → **Format** → **Font** → Chọn màu chữ trắng cho header

---

## Phương Pháp 2: Import XMI (Nếu PlantUML không hoạt động)

### Bước 1: Import XMI
1. Mở **Visual Paradigm**
2. Vào menu: **File** → **Import** → **Import from XMI...**
3. Trong hộp thoại:
   - **File**: Chọn `LockerKorea_ClassDiagram_VP.xmi`
   - **XMI Version**: Chọn **UML 2.1** hoặc **UML 2.5**
   - **Import Type**: Chọn **Class Diagram** hoặc **All**
4. Nhấn **OK**

### Bước 2: Xử Lý Lỗi (Nếu có)
Nếu gặp lỗi khi import XMI:

**Lỗi 1: "Invalid XMI format"**
- Kiểm tra encoding file (phải là UTF-8)
- Thử import lại với XMI Version khác

**Lỗi 2: "Namespace not found"**
- Đảm bảo Visual Paradigm version >= 16.0
- Thử import từng phần nhỏ

**Lỗi 3: "Classes imported but relationships missing"**
- Relationships có thể cần tạo lại thủ công
- Sử dụng **Tools** → **Model Transitor** để kiểm tra

---

## Phương Pháp 3: Tạo Thủ Công Từ PlantUML (Nếu cả 2 phương pháp trên đều lỗi)

### Bước 1: Xem Trước PlantUML
1. Mở file `LockerKorea_ClassDiagram_TheoMau.puml`
2. Sử dụng PlantUML online: http://www.plantuml.com/plantuml/uml/
3. Copy toàn bộ nội dung file và paste vào
4. Xem biểu đồ để hiểu cấu trúc

### Bước 2: Tạo Thủ Công trong Visual Paradigm
1. Tạo Class Diagram mới: **Diagram** → **New Diagram** → **Class Diagram**
2. Tạo từng lớp:
   - Kéo **Class** từ toolbar vào diagram
   - Đặt tên và thêm attributes
3. Tạo relationships:
   - Kéo từ lớp này sang lớp kia
   - Chọn **Aggregation** (hollow diamond) cho các mối quan hệ
   - Đặt multiplicity (1, *, 0..1, ...)

---

## Kiểm Tra Sau Khi Import

### ✅ Checklist:
- [ ] Tất cả các lớp đã được import
- [ ] Các thuộc tính (attributes) đã có đầy đủ
- [ ] Các mối quan hệ (relationships) đã được tạo
- [ ] Aggregation relationships có hình thoi rỗng (hollow diamond)
- [ ] Multiplicity đã được đặt đúng (1, *, 0..1, ...)

### 🔧 Sửa Lỗi Thường Gặp:

**1. Thiếu Relationships:**
- Tạo lại thủ công: Kéo từ lớp này sang lớp kia
- Chọn **Aggregation** trong properties

**2. Style không đúng:**
- Chọn tất cả lớp → **Format** → **Fill Color** → **Light Blue**
- **Format** → **Line Color** → **Black**

**3. Attributes bị thiếu:**
- Double-click vào lớp để mở **Class Specification**
- Tab **Attributes** → Thêm attributes còn thiếu

---

## File Đã Tạo

1. **`LockerKorea_ClassDiagram_TheoMau.puml`** - File PlantUML (KHUYẾN NGHỊ)
2. **`LockerKorea_ClassDiagram_VP.xmi`** - File XMI (Backup)

---

## Hỗ Trợ

Nếu vẫn gặp lỗi:
1. Kiểm tra phiên bản Visual Paradigm (khuyến nghị >= 16.0)
2. Thử import từng phần nhỏ
3. Kiểm tra log file của Visual Paradigm
4. Đảm bảo file encoding là UTF-8

---

## Lưu Ý

- **PlantUML import** thường hoạt động tốt nhất
- **XMI import** có thể mất một số thông tin (relationships, styles)
- Sau khi import, nên kiểm tra và chỉnh sửa lại để đảm bảo đầy đủ








