import { Component, OnInit, ViewChild, ElementRef, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { AiService, ChatResponse } from '../../services/ai.service';
import { ChatService, ChatMessage as StaffChatMessage } from '../../services/chat.service';
import { UserService } from '../../services/user.service';
import { finalize, catchError, tap, takeUntil } from 'rxjs/operators';
import { of } from 'rxjs';
import { environment } from '../../../../environments/environment.development';
import { PLATFORM_ID, Inject } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';
import { BaseComponent } from '../../commonComponent/base.component';
import { ToastService } from '../../services/toast.service';

interface ChatMessage {
  content: string;
  sender: 'user' | 'bot' | 'staff';
  timestamp: Date;
  isError?: boolean;
  image?: string; // Base64 image data
}

@Component({
  selector: 'app-ai-chatbot',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './ai-chatbot.component.html',
  styleUrls: ['./ai-chatbot.component.scss'],
  providers: [ToastService]
})
export class AiChatbotComponent extends BaseComponent implements OnInit {
  @ViewChild('scrollContainer') private scrollContainer!: ElementRef;
  @ViewChild('fileInput') fileInput!: ElementRef<HTMLInputElement>;

  isOpen = signal(false);
  chatMode = signal<'ai' | 'staff'>('ai'); // 'ai' or 'staff'
  messages = signal<ChatMessage[]>([]);
  staffMessages = signal<StaffChatMessage[]>([]);
  userInput = signal('');
  isLoading = signal(false);
  selectedImage = signal<File | null>(null);
  imagePreview = signal<string | null>(null);
  selectedFile = signal<File | null>(null); // For staff chat file attachments
  filePreview = signal<string | null>(null); // For staff chat file preview
  currentUserId: number = 0;

  // Computed properties
  hasMessages = computed(() => this.messages().length > 0 || this.staffMessages().length > 0);
  canSend = computed(() => {
    const hasText = this.userInput().trim().length > 0;
    const hasImage = this.selectedImage() !== null;
    const hasFile = this.selectedFile() !== null;
    return hasText || hasImage || hasFile;
  });

  constructor(
    private aiService: AiService,
    private chatService: ChatService,
    private userService: UserService,
    private toastService: ToastService,
    private httpClient: HttpClient,
    @Inject(PLATFORM_ID) private platformId: Object
  ) {
    super();
    if (isPlatformBrowser(this.platformId) && typeof localStorage !== 'undefined') {
      const token = localStorage.getItem('token');
      if (token) {
        this.userService.getInforUser(token).pipe(
          tap(user => {
            this.currentUserId = user.id || 0;
          }),
          takeUntil(this.destroyed$)
        ).subscribe();
      }
    }
  }

  ngOnInit(): void {
    // Add welcome message with examples for AI mode
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
    
    // Load staff messages if in staff mode
    this.loadStaffMessages();
    
    // Auto refresh staff messages every 5 seconds
    if (isPlatformBrowser(this.platformId)) {
      setInterval(() => {
        if (this.chatMode() === 'staff') {
          this.loadStaffMessages();
        }
      }, 5000);
    }
  }
  
  switchMode(mode: 'ai' | 'staff'): void {
    this.chatMode.set(mode);
    if (mode === 'staff') {
      this.loadStaffMessages();
    }
  }
  
  loadStaffMessages(): void {
    // Load messages even if user is not logged in (guest user)
    const hasToken = typeof localStorage !== 'undefined' && localStorage.getItem('token') !== null;
    
    // Load messages (will return public messages for guest users)
    this.chatService.getMessages().pipe(
      catchError(err => {
        console.error('Failed to load staff messages:', err);
        return of([]);
      }),
      takeUntil(this.destroyed$)
    ).subscribe(messages => {
      // Messages from backend are sorted by createdAt ASC (oldest first)
      // Keep this order for display (oldest at top, newest at bottom)
      this.staffMessages.set(messages);
      this.scrollToBottom();
    });
  }

  toggleChat(): void {
    this.isOpen.update(v => !v);
  }

  sendMessage(): void {
    if (!this.canSend() || this.isLoading()) return;

    const message = this.userInput().trim();
    const image = this.selectedImage();
    const mode = this.chatMode();

    if (mode === 'staff') {
      // Send staff chat message
      if (!message.trim() && !this.selectedImage() && !this.selectedFile()) return;
      
      const hasToken = typeof localStorage !== 'undefined' && localStorage.getItem('token') !== null;
      
      // If file is selected, send as file
      if (this.selectedFile()) {
        const file = this.selectedFile();
        if (file) {
          const formData = new FormData();
          formData.append('file', file);
          formData.append('receiverId', '');
          formData.append('message', message.trim() || '');
          
          // Determine message type based on file type
          const messageType = file.type.startsWith('image/') ? 'IMAGE' : 'FILE';
          formData.append('messageType', messageType);
          formData.append('isStaffMessage', 'false');

          const headers: any = {};
          if (hasToken) {
            headers['Authorization'] = `Bearer ${localStorage.getItem('token')}`;
          } else {
            // Add guest session ID for guest users
            let guestSessionId = localStorage.getItem('guestSessionId');
            if (!guestSessionId) {
              guestSessionId = 'guest_' + Date.now() + '_' + Math.random().toString(36).substring(2, 15);
              localStorage.setItem('guestSessionId', guestSessionId);
            }
            headers['X-Guest-Session-Id'] = guestSessionId;
          }

          this.chatService.sendFileMessage(formData, headers).pipe(
            tap(() => {
              this.userInput.set('');
              this.clearImage();
              this.clearFile();
              this.loadStaffMessages();
            }),
            catchError(err => {
              this.toastService.fail('Không thể gửi file');
              return of(null);
            }),
            takeUntil(this.destroyed$)
          ).subscribe();
          return;
        }
      }
      
      // If image is selected (legacy support), send as image
      if (this.selectedImage()) {
        const imageFile = this.selectedImage();
        if (imageFile) {
          const formData = new FormData();
          formData.append('file', imageFile);
          formData.append('receiverId', '');
          formData.append('message', message.trim() || '');
          formData.append('messageType', 'IMAGE');
          formData.append('isStaffMessage', 'false');

          const headers: any = {};
          if (hasToken) {
            headers['Authorization'] = `Bearer ${localStorage.getItem('token')}`;
          } else {
            // Add guest session ID for guest users
            let guestSessionId = localStorage.getItem('guestSessionId');
            if (!guestSessionId) {
              guestSessionId = 'guest_' + Date.now() + '_' + Math.random().toString(36).substring(2, 15);
              localStorage.setItem('guestSessionId', guestSessionId);
            }
            headers['X-Guest-Session-Id'] = guestSessionId;
          }

          this.chatService.sendFileMessage(formData, headers).pipe(
            tap(() => {
              this.userInput.set('');
              this.clearImage();
              this.clearFile();
              this.loadStaffMessages();
            }),
            catchError(err => {
              this.toastService.fail('Không thể gửi hình ảnh');
              return of(null);
            }),
            takeUntil(this.destroyed$)
          ).subscribe();
          return;
        }
      }
      
      // Send text message only
      this.chatService.sendMessage({
        receiverId: null,
        message: message.trim(),
        messageType: 'TEXT',
        isStaffMessage: false
      }, hasToken).pipe(
        tap(() => {
          this.userInput.set('');
          this.loadStaffMessages();
        }),
        catchError(err => {
          this.toastService.fail('Không thể gửi tin nhắn');
          return of(null);
        }),
        takeUntil(this.destroyed$)
      ).subscribe();
      return;
    }

    // AI mode
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

  clearFile(): void {
    this.selectedFile.set(null);
    this.filePreview.set(null);
    if (this.fileInput) {
      this.fileInput.nativeElement.value = '';
    }
  }

  triggerFileInput(): void {
    this.fileInput.nativeElement.click();
  }

  onFileSelected(event: Event): void {
    if (isPlatformBrowser(this.platformId)) {
      const input = event.target as HTMLInputElement;
      if (input.files && input.files[0]) {
        const file = input.files[0];
        
        // Validate file size (max 10MB)
        const maxSize = 10 * 1024 * 1024; // 10MB
        if (file.size > maxSize) {
          this.toastService.fail('Kích thước file quá lớn. Vui lòng chọn file nhỏ hơn 10MB.');
          return;
        }

        this.selectedFile.set(file);

        // Create preview for images
        if (file.type.startsWith('image/')) {
          const reader = new FileReader();
          reader.onload = (e) => {
            this.filePreview.set(e.target?.result as string);
          };
          reader.readAsDataURL(file);
        } else {
          // For non-image files, just set the file name as preview
          this.filePreview.set(file.name);
        }
      }
    }
  }

  onFileInputChange(event: Event): void {
    if (this.chatMode() === 'staff') {
      this.onFileSelected(event);
    } else {
      this.onImageSelected(event);
    }
  }

  removeFile(): void {
    this.clearFile();
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
    if (this.chatMode() === 'staff') {
      this.staffMessages.set([]);
      this.loadStaffMessages();
    } else {
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

  openImagePreview(imageUrl: string): void {
    window.open(imageUrl, '_blank');
  }

  getFileUrl(fileUrl: string): string {
    if (!fileUrl) {
      return '';
    }
    if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
      return fileUrl;
    }
    
    // Remove duplicate /api/v1 if fileUrl already contains it
    // Backend returns: /api/v1/chat/files/...
    // environment.apiUrl: http://localhost:8089/api/v1
    // We need to avoid duplication
    let normalizedUrl = fileUrl.startsWith('/') ? fileUrl : `/${fileUrl}`;
    
    // If fileUrl already starts with /api/v1, remove it since apiUrl already contains it
    if (normalizedUrl.startsWith('/api/v1/')) {
      normalizedUrl = normalizedUrl.substring('/api/v1'.length);
    }
    
    // Ensure apiUrl doesn't have trailing slash and normalizedUrl starts with /
    const baseUrl = environment.apiUrl.endsWith('/') 
      ? environment.apiUrl.slice(0, -1) 
      : environment.apiUrl;
    
    return `${baseUrl}${normalizedUrl}`;
  }

  handleImageError(event: Event): void {
    const img = event.target as HTMLImageElement;
    console.error('Failed to load image:', img.src);
    // Optionally show a placeholder or error message
    img.style.display = 'none';
  }
} 