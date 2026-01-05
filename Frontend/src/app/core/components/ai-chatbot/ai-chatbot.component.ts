import { Component, OnInit, ViewChild, ElementRef, signal, computed, ChangeDetectorRef, PLATFORM_ID, Inject } from '@angular/core';
import { CommonModule, isPlatformBrowser } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AiService, ChatResponse } from '../../services/ai.service';
import { UserService } from '../../services/user.service';
import { finalize, catchError, tap, takeUntil } from 'rxjs/operators';
import { of } from 'rxjs';
import { environment } from '../../../../environments/environment.development';
import { BaseComponent } from '../../commonComponent/base.component';
import { ToastService } from '../../services/toast.service';

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
  styleUrls: ['./ai-chatbot.component.scss'],
  providers: [ToastService]
})
export class AiChatbotComponent extends BaseComponent implements OnInit {
  @ViewChild('scrollContainer') private scrollContainer!: ElementRef;
  @ViewChild('fileInput') fileInput!: ElementRef<HTMLInputElement>;

  isOpen = signal(false);
  showMenu = signal(false);
  messages = signal<ChatMessage[]>([]);
  userInput = signal('');
  isLoading = signal(false);
  selectedImage = signal<File | null>(null);
  imagePreview = signal<string | null>(null);
  currentUserId: number = 0;

  // Teaser properties
  teaserMessage = signal<string>('');
  showTeaser = signal<boolean>(false);
  private teaserTimeout: any;
  private teaserInterval: any;
  private readonly TEASER_MESSAGES = [
    'Bạn cần hỗ trợ? Chat ngay!',
    'Chúng tôi có thể giúp gì cho bạn?',
    'Đừng ngần ngại hỏi chúng tôi!',
    'Tư vấn miễn phí tại đây!',
    'Có thắc mắc về sản phẩm? Hỏi ngay!'
  ];

  // Computed properties
  hasMessages = computed(() => this.messages().length > 0);
  canSend = computed(() => {
    const hasText = this.userInput().trim().length > 0;
    const hasImage = this.selectedImage() !== null;
    return hasText || hasImage;
  });

  constructor(
    private aiService: AiService,
    private userService: UserService,
    private toastService: ToastService,
    @Inject(PLATFORM_ID) private platformId: Object,
    private cdr: ChangeDetectorRef
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
    
    // Start teaser loop
    if (isPlatformBrowser(this.platformId)) {
      this.startTeaserLoop();
    }
  }
  


  toggleChat(): void {
    this.isOpen.update(v => !v);
    if (this.isOpen()) {
      this.hideTeaser();
    }
  }

  toggleMenu(): void {
    this.showMenu.update(v => !v);
    if (this.showMenu()) {
      this.hideTeaser();
    }
  }

  override ngOnDestroy(): void {
    super.ngOnDestroy();
    this.clearTeaserTimers();
  }

  private startTeaserLoop(): void {
    // Show first teaser quickly (1s)
    setTimeout(() => {
      if (!this.isOpen() && !this.showMenu()) {
        this.showRandomTeaser();
      }
      this.scheduleNextTeaser();
    }, 1000);
  }

  private scheduleNextTeaser(): void {
    // Random interval between 15s and 45s
    const randomInterval = Math.floor(Math.random() * (45000 - 15000 + 1)) + 15000;
    
    this.teaserInterval = setTimeout(() => {
      if (!this.isOpen() && !this.showMenu()) {
        this.showRandomTeaser();
      }
      this.scheduleNextTeaser();
    }, randomInterval);
  }

  private showRandomTeaser(): void {
    const randomIndex = Math.floor(Math.random() * this.TEASER_MESSAGES.length);
    this.teaserMessage.set(this.TEASER_MESSAGES[randomIndex]);
    this.showTeaser.set(true);
    this.cdr.detectChanges();

    // Hide teaser after 10 seconds
    if (this.teaserTimeout) clearTimeout(this.teaserTimeout);
    this.teaserTimeout = setTimeout(() => {
      this.hideTeaser();
    }, 10000);
  }

  hideTeaser(): void {
    this.showTeaser.set(false);
    this.cdr.detectChanges();
    if (this.teaserTimeout) clearTimeout(this.teaserTimeout);
  }

  private clearTeaserTimers(): void {
    if (this.teaserInterval) clearTimeout(this.teaserInterval);
    if (this.teaserTimeout) clearTimeout(this.teaserTimeout);
  }

  openAssistant(): void {
    this.showMenu.set(false);
    this.isOpen.set(true);
  }

  openMessenger(): void {
    // Open Messenger link
    window.open('https://m.me/khoavantaykorea', '_blank');
    this.showMenu.set(false);
  }

  openZalo(): void {
    // Open Zalo link
    window.open('https://zalo.me/0854768836', '_blank');
    this.showMenu.set(false);
  }

  sendMessage(): void {
    if (!this.canSend() || this.isLoading()) return;

    const message = this.userInput().trim();
    const image = this.selectedImage();

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
        this.addMessageWithImage('Bạn có thể cho tôi biết về sản phẩm Locker Korea này không?', 'user', preview);
      }
      this.sendImageMessage(image, 'Bạn có thể cho tôi biết về sản phẩm Locker Korea này không?');
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
    // Process content to handle markdown bold syntax (**text**)
    const processedContent = content.replace(/\*\*(.*?)\*\*/g, '<b>$1</b>');
    
    this.messages.update(msgs => [...msgs, {
      content: processedContent,
      sender,
      timestamp: new Date(),
      isError
    }]);
    this.scrollToBottom();
  }

  private addMessageWithImage(content: string, sender: 'user' | 'bot', image: string, isError: boolean = false): void {
    // Process content to handle markdown bold syntax (**text**)
    const processedContent = content.replace(/\*\*(.*?)\*\*/g, '<b>$1</b>');

    this.messages.update(msgs => [...msgs, {
      content: processedContent,
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

  onFileInputChange(event: Event): void {
    this.onImageSelected(event);
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

  openImagePreview(imageUrl: string): void {
    window.open(imageUrl, '_blank');
  }

  handleImageError(event: Event): void {
    const img = event.target as HTMLImageElement;
    console.error('Failed to load image:', img.src);
    // Optionally show a placeholder or error message
    img.style.display = 'none';
  }
}
