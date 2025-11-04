# 🐛 Fix: LocalDateTime "NaN-NaN-NaN NaN:NaN:NaN" Error

## ❌ Lỗi gốc:

```
JSON parse error: Cannot deserialize value of type `java.time.LocalDateTime` 
from String "NaN-NaN-NaN NaN:NaN:NaN": Failed to deserialize java.time.LocalDateTime: 
(java.time.format.DateTimeParseException) Text 'NaN-NaN-NaN NaN:NaN:NaN' could not be parsed at index 0
```

## 🔍 Nguyên nhân:

1. **Frontend gửi giá trị Date không hợp lệ** lên backend
2. Khi format một `Invalid Date` object trong JavaScript:
   - `getFullYear()` → `NaN`
   - `getMonth()` → `NaN`
   - `getDate()` → `NaN`
   - Kết quả: `"NaN-NaN-NaN NaN:NaN:NaN"`

3. **Backend** không thể parse chuỗi này thành `LocalDateTime`

## ✅ Giải pháp đã áp dụng:

### 1️⃣ **Kiểm tra Date hợp lệ trước khi format** (dòng 207-225)

```typescript
const formatDateForBackend = (date: Date | null | undefined): string | null => {
  if (!date) return null;
  
  const d = new Date(date);
  
  // ✅ CHECK: Kiểm tra date có hợp lệ không
  if (isNaN(d.getTime())) {
    console.warn('Invalid date provided:', date);
    return null; // Trả về null thay vì format thành "NaN-NaN-NaN"
  }
  
  const year = d.getFullYear();
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  const hours = String(d.getHours()).padStart(2, '0');
  const minutes = String(d.getMinutes()).padStart(2, '0');
  const seconds = String(d.getSeconds()).padStart(2, '0');
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
};
```

### 2️⃣ **Parse Date an toàn từ backend** (dòng 131-136)

```typescript
const parseDateSafely = (dateString: string | null | undefined): Date | null => {
  if (!dateString) return null;
  const date = new Date(dateString);
  return isNaN(date.getTime()) ? null : date; // ✅ Trả về null nếu không hợp lệ
};

this.bannerForm.patchValue({
  // ...
  start_date: parseDateSafely(banner.start_date),
  end_date: parseDateSafely(banner.end_date)
});
```

### 3️⃣ **Không gửi created_at/updated_at lên backend** (dòng 238-239)

```typescript
const bannerData: BannerDto = {
  ...this.bannerForm.value,
  start_date: formatDateForBackend(this.bannerForm.value.start_date),
  end_date: formatDateForBackend(this.bannerForm.value.end_date),
  created_at: undefined, // ✅ Backend tự quản lý
  updated_at: undefined  // ✅ Backend tự quản lý
};
```

## 📋 Files đã sửa:

- ✅ `Frontend/src/app/features/components/banner-manage/banner-manage.component.ts`

## 🧪 Cách test:

1. **Test với date hợp lệ:**
   ```
   start_date: new Date('2024-01-01')
   → "2024-01-01 00:00:00" ✅
   ```

2. **Test với date null:**
   ```
   start_date: null
   → null (không gửi) ✅
   ```

3. **Test với date không hợp lệ:**
   ```
   start_date: new Date('invalid')
   → null (thay vì "NaN-NaN-NaN") ✅
   ```

4. **Test với undefined:**
   ```
   start_date: undefined
   → null ✅
   ```

## 🎯 Kết quả:

- ✅ Không còn lỗi `"NaN-NaN-NaN NaN:NaN:NaN"`
- ✅ Backend nhận được giá trị `null` hoặc chuỗi datetime hợp lệ
- ✅ Có warning log khi phát hiện date không hợp lệ
- ✅ UX tốt hơn, không bị lỗi khi user nhập sai

## 🔐 Best Practices được áp dụng:

1. **Defensive Programming**: Luôn validate data trước khi gửi
2. **Type Safety**: Sử dụng `Date | null | undefined` thay vì `any`
3. **Separation of Concerns**: Backend chỉ nhận data hợp lệ
4. **Logging**: Console.warn để debug dễ dàng
5. **Null Safety**: Xử lý `null`/`undefined` một cách an toàn

## 📚 Tham khảo:

- [MDN: Date.prototype.getTime()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/getTime)
- [MDN: Number.isNaN()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/isNaN)
- [Spring Boot: LocalDateTime Serialization](https://www.baeldung.com/spring-boot-customize-jackson-objectmapper)

