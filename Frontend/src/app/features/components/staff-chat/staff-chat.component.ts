import { Component, OnInit, OnDestroy, ViewChild, ElementRef, AfterViewChecked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ChatService, ChatMessage } from '../../../core/services/chat.service';
import { UserService } from '../../../core/services/user.service';
import { catchError, finalize, takeUntil, tap } from 'rxjs';
import { of } from 'rxjs';
import { BaseComponent } from '../../../core/commonComponent/base.component';
import { ToastModule } from 'primeng/toast';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { CardModule } from 'primeng/card';
import { ScrollPanelModule } from 'primeng/scrollpanel';
import { TooltipModule } from 'primeng/tooltip';
import { DialogModule } from 'primeng/dialog';
import { MessageService } from 'primeng/api';
import { ToastService } from '../../../core/services/toast.service';
import { environment } from '../../../../environments/environment.development';

@Component({
  selector: 'app-staff-chat',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ToastModule,
    ButtonModule,
    InputTextModule,
    CardModule,
    ScrollPanelModule,
    TooltipModule,
    DialogModule
  ],
  providers: [MessageService, ToastService],
  templateUrl: './staff-chat.component.html',
  styleUrls: ['./staff-chat.component.scss']
})
export class StaffChatComponent extends BaseComponent implements OnInit, OnDestroy, AfterViewChecked {
  @ViewChild('scrollContainer') private scrollContainer!: ElementRef;
  
  messages: ChatMessage[] = [];
  selectedCustomerId: number | null = null;
  selectedCustomerName: string = '';
  newMessage: string = '';
  isLoading: boolean = false;
  customers: { userId: number; userName: string; lastMessage: string; unreadCount: number }[] = [];
  private shouldScroll = false;
  selectedFile: File | null = null;
  filePreview: string | null = null;
  isConversationClosed: boolean = false;

  constructor(
    private chatService: ChatService,
    private userService: UserService,
    private toastService: ToastService
  ) {
    super();
  }

  ngOnInit(): void {
    this.loadCustomerMessages();
    // Auto refresh every 5 seconds
    setInterval(() => {
      if (this.selectedCustomerId) {
        this.loadConversation(this.selectedCustomerId);
      } else {
        this.loadCustomerMessages();
      }
    }, 5000);
  }

  ngAfterViewChecked(): void {
    if (this.shouldScroll) {
      this.scrollToBottom();
      this.shouldScroll = false;
    }
  }

  loadCustomerMessages(): void {
    this.isLoading = true;
    // Get all active conversations
    this.chatService.getAllActiveConversations().pipe(
      tap((conversations) => {
        this.buildCustomersListFromConversations(conversations);
      }),
      catchError((err) => {
        this.toastService.fail('Không thể tải danh sách cuộc trò chuyện');
        return of([]);
      }),
      finalize(() => {
        this.isLoading = false;
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  buildCustomersListFromConversations(conversations: any[]): void {
    // Group conversations by customerId to avoid duplicates
    const customerMap = new Map<number, any>();
    
    conversations.forEach(conv => {
      const customerId = conv.customer_id || 0;
      
      // Only keep the most recent conversation for each customer
      if (!customerMap.has(customerId)) {
        const customerName = conv.customer_name || 
                            (customerId > 0 ? `Khách hàng #${customerId}` : 'Khách vãng lai');
        
        customerMap.set(customerId, {
          userId: customerId,
          userName: customerName,
          lastMessage: '',
          unreadCount: 0,
          isGuest: customerId === 0,
          lastMessageAt: conv.last_message_at
        });
      }
    });
    
    // Convert map to array and sort by last message time
    this.customers = Array.from(customerMap.values())
      .filter(c => c.userId !== undefined)
      .sort((a, b) => {
        const timeA = a.lastMessageAt ? new Date(a.lastMessageAt).getTime() : 0;
        const timeB = b.lastMessageAt ? new Date(b.lastMessageAt).getTime() : 0;
        return timeB - timeA; // Most recent first
      });
  }

  selectCustomer(customerId: number, customerName: string): void {
    this.selectedCustomerId = customerId;
    this.selectedCustomerName = customerName;
    this.loadConversation(customerId);
  }

  loadConversation(customerId: number): void {
    if (!customerId && customerId !== 0) {
      console.error('Invalid customerId:', customerId);
      return;
    }
    
    this.isLoading = true;
    
    // Get customer conversations and load messages from the first (most recent) one
    this.chatService.getCustomerConversations(customerId).pipe(
      tap((conversations) => {
        if (conversations && conversations.length > 0) {
          // Get the most recent active conversation, or the most recent one if none are active
          const activeConversation = conversations.find(c => !c.is_closed) || conversations[0];
          if (activeConversation && activeConversation.id) {
            this.chatService.getConversationMessages(activeConversation.id).pipe(
              tap((messages) => {
                this.messages = messages;
                this.isConversationClosed = activeConversation.is_closed || false;
                this.shouldScroll = true;
                
                // Mark conversation as read
                if (activeConversation.id) {
                  this.chatService.markConversationAsRead(activeConversation.id).pipe(
                    takeUntil(this.destroyed$)
                  ).subscribe();
                }
              }),
              catchError((err) => {
                console.error('Error loading conversation messages:', err);
                this.toastService.fail('Không thể tải cuộc trò chuyện');
                return of([]);
              }),
              finalize(() => {
                this.isLoading = false;
              }),
              takeUntil(this.destroyed$)
            ).subscribe();
          } else {
            this.messages = [];
            this.isLoading = false;
          }
        } else {
          this.messages = [];
          this.isLoading = false;
        }
      }),
      catchError((err) => {
        console.error('Error loading customer conversations:', err);
        this.toastService.fail('Không thể tải cuộc trò chuyện');
        this.isLoading = false;
        return of([]);
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  sendMessage(): void {
    if ((!this.newMessage.trim() && !this.selectedFile) || this.selectedCustomerId === null) {
      return;
    }

    // IMPORTANT: For registered users (customerId > 0), receiverId MUST be customerId
    // For guest users (customerId = 0), receiverId can be null (public message)
    // But we need to ensure registered users receive the message
    const receiverId = this.selectedCustomerId === 0 ? null : (this.selectedCustomerId || null);

    if (this.selectedFile) {
      this.sendFileMessage(receiverId);
    } else {
      this.chatService.sendMessage({
        receiverId: receiverId,
        message: this.newMessage.trim(),
        messageType: 'TEXT',
        isStaffMessage: true
      }).pipe(
        tap(() => {
          this.newMessage = '';
          this.loadConversation(this.selectedCustomerId!);
          this.loadCustomerMessages();
          this.shouldScroll = true;
        }),
        catchError((err) => {
          console.error('Error sending message:', err);
          this.toastService.fail('Không thể gửi tin nhắn');
          return of(null);
        }),
        takeUntil(this.destroyed$)
      ).subscribe();
    }
  }

  onFileSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files[0]) {
      const file = input.files[0];
      const maxSize = 10 * 1024 * 1024; // 10MB
      
      if (file.size > maxSize) {
        this.toastService.fail('Kích thước file quá lớn. Vui lòng chọn file nhỏ hơn 10MB');
        return;
      }
      
      this.selectedFile = file;
      
      // Create preview for images
      if (file.type.startsWith('image/')) {
        const reader = new FileReader();
        reader.onload = (e) => {
          this.filePreview = e.target?.result as string;
        };
        reader.readAsDataURL(file);
      } else {
        this.filePreview = null;
      }
    }
  }

  removeFile(): void {
    this.selectedFile = null;
    this.filePreview = null;
  }

  sendFileMessage(receiverId: number | null): void {
    if (!this.selectedFile) return;

    const formData = new FormData();
    formData.append('file', this.selectedFile);
    formData.append('receiverId', receiverId?.toString() || '');
    formData.append('message', this.newMessage.trim() || this.selectedFile.name);
    formData.append('messageType', this.selectedFile.type.startsWith('image/') ? 'IMAGE' : 'FILE');
    formData.append('isStaffMessage', 'true');

    const token = localStorage.getItem('token');
    const headers: any = {
      'Authorization': `Bearer ${token}`
    };

    this.chatService.sendFileMessage(formData, headers).pipe(
      tap(() => {
        this.newMessage = '';
        this.selectedFile = null;
        this.filePreview = null;
        this.loadConversation(this.selectedCustomerId!);
        this.loadCustomerMessages();
        this.shouldScroll = true;
      }),
      catchError((err) => {
        console.error('Error sending file:', err);
        this.toastService.fail('Không thể gửi file');
        return of(null);
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  scrollToBottom(): void {
    try {
      if (this.scrollContainer) {
        this.scrollContainer.nativeElement.scrollTop = 
          this.scrollContainer.nativeElement.scrollHeight;
      }
    } catch (err) {
      console.error('Error scrolling:', err);
    }
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

  closeConversation(): void {
    if (this.selectedCustomerId === null || this.selectedCustomerId === undefined) {
      return;
    }

    if (!confirm('Bạn có chắc chắn muốn kết thúc cuộc trò chuyện này? Khách hàng sẽ không thể gửi tin nhắn mới sau khi cuộc trò chuyện được đóng.')) {
      return;
    }

    // Get the current conversation ID
    this.chatService.getCustomerConversations(this.selectedCustomerId).pipe(
      tap((conversations) => {
        if (conversations && conversations.length > 0) {
          const activeConversation = conversations.find(c => !c.is_closed);
          if (activeConversation && activeConversation.id) {
            this.chatService.closeConversationById(activeConversation.id).pipe(
              tap(() => {
                this.toastService.success('Cuộc trò chuyện đã được đóng');
                this.isConversationClosed = true;
                // Reload conversation to show closed status
                this.loadConversation(this.selectedCustomerId!);
                // Reload customer list to update
                this.loadCustomerMessages();
              }),
              catchError((err) => {
                console.error('Error closing conversation:', err);
                this.toastService.fail('Không thể đóng cuộc trò chuyện');
                return of(null);
              }),
              takeUntil(this.destroyed$)
            ).subscribe();
          } else {
            this.toastService.fail('Không tìm thấy cuộc trò chuyện đang hoạt động');
          }
        }
      }),
      catchError((err) => {
        console.error('Error getting conversations:', err);
        this.toastService.fail('Không thể lấy thông tin cuộc trò chuyện');
        return of([]);
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }
}

