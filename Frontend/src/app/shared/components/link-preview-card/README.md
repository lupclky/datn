# Link Preview Card Component

Component để hiển thị link dưới dạng card preview đẹp mắt.

## Cách sử dụng:

### 1. Import component:
```typescript
import { LinkPreviewCardComponent, LinkPreview } from '@app/shared/components/link-preview-card/link-preview-card.component';

@Component({
  imports: [LinkPreviewCardComponent]
})
```

### 2. Sử dụng trong template:

#### Chế độ đầy đủ (Full Mode):
```html
<app-link-preview-card [linkData]="linkData"></app-link-preview-card>
```

#### Chế độ compact (Nhỏ gọn):
```html
<app-link-preview-card [linkData]="linkData" [compact]="true"></app-link-preview-card>
```

### 3. Chuẩn bị dữ liệu:

```typescript
linkData: LinkPreview = {
  url: 'https://tinhte.vn/article',
  title: 'Thử nhanh Apple Intelligence tiếng Việt',
  description: 'Bà con ơi, làng nước ơi, Apple AI có tiếng Việt rồi...',
  image: 'https://tinhte.vn/image.jpg',
  favicon: 'https://tinhte.vn/favicon.ico',
  siteName: 'tinhte.vn'
};
```

### 4. Ví dụ trong News Component:

```typescript
// news.component.ts
export class NewsComponent {
  news: NewsDto = {
    // ... other fields
  };

  get newsLinkPreview(): LinkPreview {
    return {
      url: `/news/${this.news.id}`,
      title: this.news.title,
      description: this.news.summary,
      image: this.getImageUrl(this.news.featured_image),
      siteName: 'Your Site Name'
    };
  }
}
```

```html
<!-- news.component.html -->
<app-link-preview-card [linkData]="newsLinkPreview"></app-link-preview-card>
```

## Props:

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| linkData | LinkPreview | required | Dữ liệu của link |
| compact | boolean | false | Chế độ hiển thị nhỏ gọn |

## LinkPreview Interface:

```typescript
interface LinkPreview {
  url: string;           // URL của link (required)
  title?: string;        // Tiêu đề
  description?: string;  // Mô tả
  image?: string;        // URL ảnh preview
  favicon?: string;      // URL favicon
  siteName?: string;     // Tên website
}
```

## Features:

- ✅ Hiển thị ảnh preview
- ✅ Tiêu đề và mô tả
- ✅ Favicon và site name
- ✅ Hover effects
- ✅ Click để mở link trong tab mới
- ✅ Responsive design
- ✅ 2 chế độ: Full và Compact
- ✅ Fallback image khi ảnh lỗi
- ✅ Text truncation thông minh

