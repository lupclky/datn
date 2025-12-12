## Sequence diagrams — Use Cases 26–33

### 26) Tích hợp AI cho nội dung & chỉ mục
```mermaid
sequenceDiagram
    actor Admin
    participant AdminUI as Admin UI
    participant API as AIInitializationController
    participant Indexer as IndexService
    participant Chroma as ChromaDB
    Admin->>AdminUI: Click "Index all products"
    AdminUI->>API: POST /api/v1/ai/initialize/index-all
    API->>Indexer: triggerIndexAll()
    loop For each product/category
        Indexer->>Chroma: Upsert vectors
    end
    Chroma-->>Indexer: Ack
    Indexer-->>API: Indexing status
    API-->>AdminUI: 200 + status
    AdminUI-->>Admin: Show success/progress
```

### 27) AI tư vấn sản phẩm / tìm kiếm ngữ nghĩa / khuyến nghị
```mermaid
sequenceDiagram
    actor User
    participant ChatUI as Chatbot UI
    participant API as AIChatController
    participant Vertex as VertexAI
    participant Chroma as ChromaDB
    User->>ChatUI: Nhập câu hỏi
    ChatUI->>API: POST /api/v1/ai/chat/product-assistant
    API->>Chroma: Semantic search (products)
    Chroma-->>API: Top K matches
    API->>Vertex: Prompt + context (matches)
    Vertex-->>API: LLM response
    API-->>ChatUI: Answer + references
    ChatUI-->>User: Hiển thị trả lời/gợi ý
```

### 28) Phân tích hình ảnh sản phẩm
```mermaid
sequenceDiagram
    actor User
    participant ChatUI as Chatbot UI
    participant API as AIChatController
    participant Vertex as VertexAI Vision
    participant Chroma as ChromaDB
    User->>ChatUI: Upload ảnh sản phẩm
    ChatUI->>API: POST /api/v1/ai/chat/image (multipart)
    API->>Vertex: Vision analyze(image)
    Vertex-->>API: Labels/features
    API->>Chroma: Similarity search with features
    Chroma-->>API: Candidate products
    API-->>ChatUI: Recommendations
    ChatUI-->>User: Hiển thị gợi ý tương tự
```

### 29) Sinh nội dung Tin tức bằng AI
```mermaid
sequenceDiagram
    actor Admin
    participant AdminUI
    participant API as AIChatController
    participant Vertex as VertexAI
    Admin->>AdminUI: Nhập chủ đề bài viết
    AdminUI->>API: POST /api/v1/ai/chat/generate-news
    API->>Vertex: Prompt generate news
    Vertex-->>API: Draft content
    API-->>AdminUI: Draft + metadata
    AdminUI-->>Admin: Cho phép chỉnh sửa/lưu
```

### 30) Sinh mô tả sản phẩm bằng AI
```mermaid
sequenceDiagram
    actor Admin
    participant AdminUI
    participant API as AIChatController
    participant Vertex as VertexAI
    Admin->>AdminUI: Chọn sản phẩm, yêu cầu mô tả
    AdminUI->>API: POST /api/v1/ai/chat/generate-product-description
    API->>Vertex: Prompt với thông tin sản phẩm
    Vertex-->>API: Generated description
    API-->>AdminUI: Description text
    AdminUI-->>Admin: Review/ghi đè mô tả sản phẩm
```

### 31) Tư vấn Bảo hành bằng AI
```mermaid
sequenceDiagram
    actor User
    participant ChatUI
    participant API as AIChatController
    participant Vertex as VertexAI
    User->>ChatUI: Mô tả vấn đề bảo hành
    ChatUI->>API: POST /api/v1/ai/chat/warranty-advice
    API->>Vertex: Prompt với tri thức bảo hành
    Vertex-->>API: Advice steps
    API-->>ChatUI: Hướng dẫn bảo hành
    ChatUI-->>User: Trả lời + bước thực hiện
```

### 32) Chẩn đoán lỗi khóa bằng AI
```mermaid
sequenceDiagram
    actor User
    participant ChatUI
    participant API as AIChatController
    participant Vertex as VertexAI
    User->>ChatUI: Mô tả triệu chứng khóa
    ChatUI->>API: POST /api/v1/ai/chat/diagnose-issue
    API->>Vertex: Prompt với kịch bản lỗi
    Vertex-->>API: Diagnosis + fix suggestions
    API-->>ChatUI: Kết quả chẩn đoán
    ChatUI-->>User: Hiển thị chẩn đoán/khuyến nghị
```

### 33) Tự động chỉ mục dữ liệu khi CRUD sản phẩm (listener)
```mermaid
sequenceDiagram
    participant ProductSvc as ProductController/Service
    participant EventBus as Domain Event
    participant Indexer as VectorIndexService
    participant Chroma as ChromaDB
    ProductSvc-->>EventBus: Emit ProductCreated/Updated/Deleted
    EventBus-->>Indexer: Deliver event
    alt Created/Updated
        Indexer->>Chroma: Upsert product vectors
    else Deleted
        Indexer->>Chroma: Remove product vectors
    end
    Chroma-->>Indexer: Ack
    Indexer-->>EventBus: Success/failure status
```


