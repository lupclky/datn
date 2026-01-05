# Biểu đồ tuần tự: AI Tư vấn sản phẩm (Product Assistant)

## Sequence Diagram (Mermaid)

```mermaid
sequenceDiagram
    autonumber
    actor User as Người dùng
    participant FE as Frontend (Angular)<br/>AiChatbotComponent
    participant BE as Backend (Spring Boot)<br/>AIChatController
    participant Service as AI Service<br/>AIProductAssistantService
    participant Vector as Vector Search<br/>VectorSearchService
    participant Embed as Embedding Service<br/>(Python/CLIP)
    participant DB as ChromaDB<br/>(Vector Database)
    participant LLM as Google Gemini<br/>(LangChain4J)

    Note over User, FE: Bắt đầu phiên tư vấn

    User->>FE: Nhập câu hỏi (VD: "Khóa vân tay nào tốt?")
    FE->>BE: POST /api/v1/ai/chat/product-assistant<br/>{ "query": "Khóa vân tay nào tốt?" }
    
    activate BE
    BE->>Service: answerProductQuery(query)
    
    activate Service
    Service->>Vector: searchProducts(query, topK=10)
    
    activate Vector
    Vector->>Embed: embed(text)
    activate Embed
    Embed-->>Vector: Trả về Vector Embedding [0.1, 0.5, ...]
    deactivate Embed
    
    Vector->>DB: Query(embedding, limit=10)
    activate DB
    DB-->>Vector: Trả về danh sách Documents (Sản phẩm liên quan)
    deactivate DB
    
    Vector-->>Service: List<Document>
    deactivate Vector

    alt Không tìm thấy sản phẩm (Vector Search)
        Service->>Service: searchProductsByExactMatch(query)<br/>(Fallback tìm kiếm theo từ khóa trong DB SQL)
    end

    Service->>Service: buildProductContext(documents)<br/>(Tạo ngữ cảnh từ thông tin sản phẩm)
    
    Service->>Service: createEnhancedPrompt(query, context)<br/>(Ghép câu hỏi + thông tin sản phẩm vào Prompt)

    Service->>LLM: chat(prompt)
    activate LLM
    LLM-->>Service: Trả về câu trả lời tư vấn
    deactivate LLM

    Service-->>BE: String response
    deactivate Service

    BE-->>FE: JSON { "response": "...", "success": true }
    deactivate BE

    FE->>User: Hiển thị câu trả lời của AI
```

## Giải thích chi tiết

1.  **User Interaction**: Người dùng nhập câu hỏi vào khung chat trên giao diện Angular (`AiChatbotComponent`).
2.  **API Call**: Frontend gọi API `/product-assistant` đến Backend Spring Boot.
3.  **Vector Search**:
    *   Backend yêu cầu `VectorSearchService` tìm kiếm sản phẩm liên quan.
    *   `VectorSearchService` gọi sang **Python Service** (chạy model CLIP) để chuyển câu hỏi văn bản thành vector (embedding).
    *   Sử dụng vector này để truy vấn **ChromaDB** nhằm tìm ra các sản phẩm có đặc điểm tương đồng nhất về mặt ngữ nghĩa.
4.  **Context Building**:
    *   Nếu tìm thấy sản phẩm, hệ thống sẽ trích xuất thông tin (Tên, Giá, Mô tả, Tính năng...) để tạo thành một đoạn văn bản ngữ cảnh (Context).
    *   Nếu không tìm thấy qua Vector Search, hệ thống có cơ chế dự phòng (Fallback) tìm kiếm chính xác theo từ khóa trong Database SQL.
5.  **LLM Generation**:
    *   Backend gửi một Prompt bao gồm: "Vai trò chuyên gia tư vấn" + "Thông tin sản phẩm tìm được" + "Câu hỏi của người dùng" đến **Google Gemini**.
    *   Gemini phân tích và sinh ra câu trả lời dựa trên thông tin sản phẩm thực tế được cung cấp.
6.  **Response**: Câu trả lời được trả về Frontend và hiển thị cho người dùng.
