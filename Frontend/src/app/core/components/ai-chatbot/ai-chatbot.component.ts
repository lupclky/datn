import { Component, OnInit, ViewChild, ElementRef, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { AiService, ChatResponse } from '../../services/ai.service';
import { finalize } from 'rxjs/operators';
import { environment } from '../../../../environments/environment.development';
import { PLATFORM_ID, Inject } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';

interface ChatMessage {
  content: string;
  sender: 'user' | 'bot';
  timestamp: Date;
  isError?: boolean;
  image?: string; // Base64 image data
}

@Component({
  selector: 'app-ai-chatbot',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './ai-chatbot.component.html',
  styleUrls: ['./ai-chatbot.component.scss']
})
export class AiChatbotComponent implements OnInit {
  @ViewChild('scrollContainer') private scrollContainer!: ElementRef;
  @ViewChild('fileInput') fileInput!: ElementRef<HTMLInputElement>;

  isOpen = signal(false);
  messages = signal<ChatMessage[]>([]);
  userInput = signal('');
  isLoading = signal(false);
  selectedImage = signal<File | null>(null);
  imagePreview = signal<string | null>(null);

  // Computed properties
  hasMessages = computed(() => this.messages().length > 0);
  canSend = computed(() => this.userInput().trim().length > 0 || this.selectedImage() !== null);

  constructor(
    private aiService: AiService,
    private httpClient: HttpClient,
    @Inject(PLATFORM_ID) private platformId: Object
  ) {}

  ngOnInit(): void {
    // Add welcome message with examples
    const welcomeMessage = `Xin chào! 👋 Tôi là trợ lý AI tư vấn khóa điện tử của Locker Korea. Tôi có quyền truy cập vào toàn bộ database sản phẩm khóa vân tay, khóa điện tử của cửa hàng.

Bạn có thể hỏi tôi những câu như:
• "Cho tôi xem khóa vân tay cho cửa nhà dưới 5 triệu VND"
• "Khóa điện tử nào phù hợp cho căn hộ chung cư?"
• "So sánh khóa Samsung và Dessmann"
• "Tôi cần khóa cửa có tính năng mở từ xa"
• "Khóa vân tay nào bảo mật nhất?"
• "Gợi ý khóa điện tử cho cửa kính"

Tôi có thể giúp gì cho bạn hôm nay? 🔐😊`;
    
    this.addMessage(welcomeMessage, 'bot');
    
    // Check if AI is initialized
    this.checkAIStatus();
  }

  toggleChat(): void {
    this.isOpen.update(v => !v);
  }

  sendMessage(): void {
    if (!this.canSend() || this.isLoading()) return;

    const message = this.userInput().trim();
    const image = this.selectedImage();

    if (message && !image) {
      this.addMessage(message, 'user');
    }

    if (image && message) {
      // Send image with prompt
      const preview = this.imagePreview();
      if (preview) {
        this.addMessageWithImage(message, 'user', preview);
      }
      this.sendImageMessage(image, message);
    } else if (image) {
      // Send image with default prompt
      const preview = this.imagePreview();
      if (preview) {
        this.addMessageWithImage('What can you tell me about this sneaker?', 'user', preview);
      }
      this.sendImageMessage(image, 'What can you tell me about this sneaker?');
    } else if (message) {
      // Send text message
      this.sendTextMessage(message);
    }

    // Clear input
    this.userInput.set('');
    this.clearImage();
  }

  private sendTextMessage(message: string): void {
    this.isLoading.set(true);

    this.aiService.productAssistant(message)
      .pipe(finalize(() => this.isLoading.set(false)))
      .subscribe({
        next: (response: ChatResponse) => {
          if (response.success) {
            this.addMessage(response.response, 'bot');
          } else {
            this.addMessage('Xin lỗi, tôi không thể xử lý yêu cầu của bạn. Vui lòng thử lại hoặc đặt câu hỏi khác.', 'bot', true);
          }
        },
        error: (error) => {
          console.error('Chat error:', error);
          let errorMessage = 'Xin lỗi, đã có lỗi xảy ra. Vui lòng thử lại sau.';
          
          if (error.status === 0) {
            errorMessage = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
          } else if (error.status === 500) {
            errorMessage = 'Lỗi máy chủ. AI service có thể chưa được khởi tạo. Vui lòng liên hệ admin.';
          } else if (error.status === 503) {
            errorMessage = 'Dịch vụ AI tạm thời không khả dụng. Vui lòng thử lại sau.';
          } else if (error.error?.error) {
            errorMessage = error.error.error;
          }
          
          this.addMessage(errorMessage, 'bot', true);
        }
      });
  }

  private sendImageMessage(image: File, prompt: string): void {
    this.isLoading.set(true);

    // Validate image size (max 5MB)
    const maxSize = 5 * 1024 * 1024; // 5MB
    if (image.size > maxSize) {
      this.addMessage('Kích thước ảnh quá lớn. Vui lòng chọn ảnh nhỏ hơn 5MB.', 'bot', true);
      this.isLoading.set(false);
      return;
    }

    // Validate image type
    const validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
    if (!validTypes.includes(image.type)) {
      this.addMessage('Định dạng ảnh không hợp lệ. Vui lòng chọn ảnh JPEG, PNG, GIF hoặc WebP.', 'bot', true);
      this.isLoading.set(false);
      return;
    }

    console.log('Uploading image:', { name: image.name, size: image.size, type: image.type });

    this.aiService.chatWithImage(image, prompt)
      .pipe(finalize(() => this.isLoading.set(false)))
      .subscribe({
        next: (response: ChatResponse) => {
          if (response.success) {
            this.addMessage(response.response, 'bot');
          } else {
            this.addMessage('Xin lỗi, tôi không thể phân tích hình ảnh này. Vui lòng thử lại với hình ảnh khác.', 'bot', true);
          }
        },
        error: (error) => {
          console.error('Image chat error:', error);
          let errorMessage = 'Xin lỗi, đã có lỗi xảy ra khi phân tích hình ảnh.';
          
          if (error.status === 413) {
            errorMessage = 'Kích thước hình ảnh quá lớn. Vui lòng chọn ảnh nhỏ hơn 5MB.';
          } else if (error.status === 415) {
            errorMessage = 'Định dạng ảnh không được hỗ trợ. Vui lòng sử dụng JPEG, PNG, GIF hoặc WebP.';
          } else if (error.status === 400 && error.error?.error) {
            errorMessage = error.error.error;
          } else if (error.status === 0) {
            errorMessage = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
          } else if (error.status === 500) {
            errorMessage = 'Lỗi máy chủ khi xử lý ảnh. Vui lòng thử lại sau.';
          }
          
          this.addMessage(errorMessage, 'bot', true);
        }
      });
  }

  private addMessage(content: string, sender: 'user' | 'bot', isError: boolean = false): void {
    this.messages.update(msgs => [...msgs, {
      content,
      sender,
      timestamp: new Date(),
      isError
    }]);
    this.scrollToBottom();
  }

  private addMessageWithImage(content: string, sender: 'user' | 'bot', image: string, isError: boolean = false): void {
    this.messages.update(msgs => [...msgs, {
      content,
      sender,
      timestamp: new Date(),
      isError,
      image
    }]);
    this.scrollToBottom();
  }

  onImageSelected(event: Event): void {
    if (isPlatformBrowser(this.platformId)) {
      const input = event.target as HTMLInputElement;
      if (input.files && input.files[0]) {
        const file = input.files[0];
        this.selectedImage.set(file);

        // Create preview
        const reader = new FileReader();
        reader.onload = (e) => {
          this.imagePreview.set(e.target?.result as string);
        };
        reader.readAsDataURL(file);
      }
    }
  }

  clearImage(): void {
    this.selectedImage.set(null);
    this.imagePreview.set(null);
    if (this.fileInput) {
      this.fileInput.nativeElement.value = '';
    }
  }

  triggerFileInput(): void {
    this.fileInput.nativeElement.click();
  }

  onKeyPress(event: KeyboardEvent): void {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      this.sendMessage();
    }
  }

  private scrollToBottom(): void {
    if (isPlatformBrowser(this.platformId)) {
      setTimeout(() => {
        if (this.scrollContainer) {
          const element = this.scrollContainer.nativeElement;
          element.scrollTop = element.scrollHeight;
        }
      }, 100);
    }
  }

  clearChat(): void {
    this.messages.set([]);
    const welcomeMessage = `Xin chào! 👋 Tôi là trợ lý AI tư vấn khóa điện tử của Locker Korea. Tôi có quyền truy cập vào toàn bộ database sản phẩm khóa vân tay, khóa điện tử của cửa hàng.

Bạn có thể hỏi tôi những câu như:
• "Cho tôi xem khóa vân tay cho cửa nhà dưới 5 triệu VND"
• "Khóa điện tử nào phù hợp cho căn hộ chung cư?"
• "So sánh khóa Samsung và Dessmann"
• "Tôi cần khóa cửa có tính năng mở từ xa"
• "Khóa vân tay nào bảo mật nhất?"
• "Gợi ý khóa điện tử cho cửa kính"

Tôi có thể giúp gì cho bạn hôm nay? 🔐😊`;
    
    this.addMessage(welcomeMessage, 'bot');
  }

  private checkAIStatus(): void {
    // Check if AI index is initialized
    const apiUrl = environment.apiUrl;
    this.httpClient.get<{success: boolean; status: string; documentCount: number}>(`${apiUrl}/ai/initialize/status`)
      .subscribe({
        next: (response) => {
          if (response.success && response.status === 'initialized') {
            console.log(`AI database đã sẵn sàng với ${response.documentCount} sản phẩm`);
          } else if (response.success && response.status === 'not_initialized') {
            console.warn('AI database chưa được khởi tạo');
          }
        },
        error: (error: any) => {
          console.error('Failed to check AI status:', error);
          // Không hiển thị lỗi này cho user vì không quan trọng lắm
        }
      });
  }

  initializeAI(): void {
    if (!confirm('Bạn có chắc chắn muốn khởi tạo lại database AI? Quá trình này có thể mất vài phút.')) {
      return;
    }
    
    this.isLoading.set(true);
    this.addMessage('⏳ Đang khởi tạo database AI với toàn bộ sản phẩm... Vui lòng đợi trong giây lát.', 'bot');
    
    const apiUrl = environment.apiUrl;
    this.httpClient.post<{success: boolean; message: string}>(`${apiUrl}/ai/initialize/index-all`, {})
      .pipe(finalize(() => this.isLoading.set(false)))
      .subscribe({
        next: (response) => {
          if (response.success) {
            this.addMessage('✅ Khởi tạo database AI thành công! Tôi đã có quyền truy cập vào toàn bộ sản phẩm. Bạn có thể bắt đầu hỏi tôi về bất kỳ sản phẩm nào.', 'bot');
          } else {
            this.addMessage('❌ Không thể khởi tạo database AI. Vui lòng thử lại sau.', 'bot', true);
          }
        },
        error: (error: any) => {
          console.error('Failed to initialize AI:', error);
          let errorMessage = '❌ Lỗi khi khởi tạo database AI.';
          
          if (error.status === 0) {
            errorMessage += ' Không thể kết nối đến server.';
          } else if (error.status === 500) {
            errorMessage += ' Lỗi máy chủ. Kiểm tra Google Cloud credentials và ChromaDB.';
          } else if (error.error?.error) {
            errorMessage = `❌ ${error.error.error}`;
          }
          
          this.addMessage(errorMessage, 'bot', true);
        }
      });
  }
} 