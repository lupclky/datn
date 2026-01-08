# Các chỉ số đo lường độ chính xác AI (AI Evaluation Metrics)

Đối với hệ thống RAG (Retrieval Augmented Generation) kết hợp tìm kiếm hình ảnh như của bạn, việc đánh giá cần chia làm 2 giai đoạn:

## 1. Đo lường khả năng Tìm kiếm (Retrieval Metrics)
Đánh giá xem hệ thống có tìm đúng sản phẩm trong `ChromaDB` từ ảnh user gửi hay không.

*   **Precision@k (Độ chính xác tại top k):**
    *   Ví dụ: Nếu search ra 3 kết quả đầu tiên (k=3), có bao nhiêu kết quả là *đúng* sản phẩm đó hoặc *rất giống*?
    *   *Công thức:* `(Số ảnh đúng trong top k) / k`.
*   **Recall (Độ phủ):**
    *   Hệ thống có tìm ra được sản phẩm đúng không, hay bỏ sót nó hoàn toàn?
*   **MRR (Mean Reciprocal Rank):**
    *   Đánh giá thứ hạng của kết quả đúng đầu tiên. Nếu kết quả đúng nằm ở vị trí số 1 thì điểm cao nhất, nằm ở vị trí số 5 thì điểm thấp hơn.

## 2. Đo lường khả năng Trả lời (Generation Metrics)
Đánh giá xem LLM (Gemini/GPT) trả lời có tốt không sau khi đã có thông tin sản phẩm.

*   **Faithfulness (Độ trung thực):**
    *   Câu trả lời có dựa hoàn toàn vào thông tin (Context) được cung cấp không? Hay AI đang "chém gió" (Hallucination)?
    *   *Ví dụ:* Context nói "Còn 3 bộ", AI trả lời "Còn 10 bộ" -> Low Faithfulness.
*   **Answer Relevance (Độ liên quan):**
    *   Câu trả lời có đúng trọng tâm câu hỏi của người dùng không?
*   **Context Precision:**
    *   Những thông tin được đưa vào Prompt có thực sự hữu ích để trả lời câu hỏi không, hay chứa nhiều rác?

## 3. Cách thực hiện đánh giá (Evaluation Methods)

### a. Đánh giá thủ công (Human Evaluation) (Dễ nhất cho đồ án)
*   Chuẩn bị bộ Test Set gồm 20-50 ảnh + câu hỏi.
*   Chạy hệ thống và ghi lại kết quả.
*   Con người chấm điểm:
    *   Tìm đúng sản phẩm: ✅/❌
    *   Câu trả lời đúng ý: ✅/❌
*   Tính % thành công.

### b. LLM-as-a-Judge (Dùng AI chấm AI)
*   Sử dụng một model mạnh hơn (ví dụ GPT-4) để chấm điểm câu trả lời của model hiện tại dựa trên bộ tiêu chí đã đề ra.
