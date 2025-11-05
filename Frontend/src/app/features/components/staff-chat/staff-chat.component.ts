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
  customerMessages: ChatMessage[] = [];
  selectedCustomerId: number | null = null;
  selectedCustomerName: string = '';
  newMessage: string = '';
  isLoading: boolean = false;
  customers: { userId: number; userName: string; lastMessage: string; unreadCount: number }[] = [];
  private shouldScroll = false;
  selectedFile: File | null = null;
  filePreview: string | null = null;
  isConversationClosed: boolean = false;
  selectedGuestSessionId: string | null = null; // Store guest session ID when selecting guest customer

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
    this.chatService.getCustomerMessages().pipe(
      tap((messages) => {
        this.customerMessages = messages;
        this.buildCustomersList();
      }),
      catchError((err) => {
        this.toastService.fail('Không thể tải tin nhắn từ khách hàng');
        return of([]);
      }),
      finalize(() => {
        this.isLoading = false;
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  buildCustomersList(): void {
    const customerMap = new Map<number | string, { userName: string; lastMessage: string; unreadCount: number; lastMessageTime: Date }>();
    
    this.customerMessages.forEach(msg => {
      if (!msg.isStaffMessage) {
        // Use senderId if available, otherwise use a unique key for guest users
        const customerKey = msg.senderId ?? `guest_${msg.id}`;
        const existing = customerMap.get(customerKey);
        const msgTime = msg.createdAt ? new Date(msg.createdAt) : new Date(0);
        
        if (!existing || msgTime > existing.lastMessageTime) {
          customerMap.set(customerKey, {
            userName: msg.senderName || (msg.senderId ? `Khách hàng #${msg.senderId}` : 'Khách vãng lai'),
            lastMessage: msg.message,
            unreadCount: msg.isRead === false ? 1 : 0,
            lastMessageTime: msgTime
          });
        } else if (msg.isRead === false) {
          existing.unreadCount++;
        }
      }
    });
    
    this.customers = Array.from(customerMap.entries())
      .map(([key, data]) => {
        // Extract userId from key (if it's a number, use it; if it's guest_, use 0)
        const userId = typeof key === 'number' ? key : 0;
        return {
          userId,
          userName: data.userName,
          lastMessage: data.lastMessage,
          unreadCount: data.unreadCount,
          isGuest: typeof key === 'string'
        };
      })
      .sort((a, b) => {
        const aMsg = this.customerMessages.find(m => 
          a.isGuest ? (m.senderId === null || m.senderId === undefined) : m.senderId === a.userId
        );
        const bMsg = this.customerMessages.find(m => 
          b.isGuest ? (m.senderId === null || m.senderId === undefined) : m.senderId === b.userId
        );
        const aTime = aMsg?.createdAt ? new Date(aMsg.createdAt).getTime() : 0;
        const bTime = bMsg?.createdAt ? new Date(bMsg.createdAt).getTime() : 0;
        return bTime - aTime;
      });
  }

  selectCustomer(customerId: number, customerName: string): void {
    this.selectedCustomerId = customerId;
    this.selectedCustomerName = customerName;
    this.loadConversation(customerId);
    if (customerId !== 0) {
      this.markAsRead(customerId);
    }
  }

  loadConversation(customerId: number): void {
    this.isLoading = true;
    // Get current user ID (staff)
    const token = localStorage.getItem('token');
    if (!token) {
      this.toastService.fail('Vui lòng đăng nhập');
      this.isLoading = false;
      return;
    }
    
    this.userService.getInforUser(token).pipe(
      tap(user => {
        const staffId = user.id || 0;
        
        // If customerId is 0, it's a guest user - load public messages
        if (customerId === 0) {
          // Load all customer messages (including guest users) and filter for this conversation
          this.chatService.getCustomerMessages().pipe(
            tap((messages) => {
              // Filter messages from guest users (senderId is null) and replies from staff
              // Get all messages where receiver is null (public) or receiver is null and sender is staff
              const filteredMessages = messages.filter(m => 
                (m.senderId === null || m.senderId === undefined || m.senderId === customerId) || 
                (m.isStaffMessage && (m.receiverId === null || m.receiverId === customerId))
              );
              
              // Extract guest session ID from first guest message if available
              if (customerId === 0 && filteredMessages.length > 0) {
                const guestMessage = filteredMessages.find(m => m.senderId === null || m.senderId === undefined);
                if (guestMessage && (guestMessage as any).guestSessionId) {
                  this.selectedGuestSessionId = (guestMessage as any).guestSessionId;
                }
              }
              
              this.messages = filteredMessages.sort((a, b) => {
                const timeA = a.createdAt ? new Date(a.createdAt).getTime() : 0;
                const timeB = b.createdAt ? new Date(b.createdAt).getTime() : 0;
                return timeA - timeB;
              });
              // Check if conversation is closed
              this.isConversationClosed = this.messages.some(m => m.isClosed === true);
              this.shouldScroll = true;
            }),
            catchError((err) => {
              console.error('Error loading guest messages:', err);
              this.toastService.fail('Không thể tải cuộc trò chuyện');
              return of([]);
            }),
            finalize(() => {
              this.isLoading = false;
            }),
            takeUntil(this.destroyed$)
          ).subscribe();
        } else {
          // Normal conversation with registered user
          console.log('Loading conversation - customerId:', customerId, 'staffId:', staffId);
          // IMPORTANT: customerId should be the customer's ID, staffId should be the current staff's ID
          // API endpoint: /conversation/{customerId} - backend will extract staffId from token
          this.chatService.getConversation(customerId, staffId).pipe(
            tap((messages) => {
              console.log('Loaded conversation messages:', messages);
              console.log('Customer messages:', messages.filter(m => !m.isStaffMessage));
              console.log('Staff messages:', messages.filter(m => m.isStaffMessage));
              this.messages = messages;
              // Clear guest session ID for registered users
              this.selectedGuestSessionId = null;
              // Check if conversation is closed
              this.isConversationClosed = messages.some(m => m.isClosed === true);
              this.shouldScroll = true;
            }),
            catchError((err) => {
              console.error('Error loading conversation:', err);
              this.toastService.fail('Không thể tải cuộc trò chuyện');
              return of([]);
            }),
            finalize(() => {
              this.isLoading = false;
            }),
            takeUntil(this.destroyed$)
          ).subscribe();
        }
      }),
      catchError((err) => {
        console.error('Error getting user info:', err);
        this.isLoading = false;
        this.toastService.fail('Không thể lấy thông tin người dùng');
        return of(null);
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

  markAsRead(customerId: number): void {
    const unreadMessages = this.customerMessages.filter(
      m => m.senderId === customerId && !m.isRead
    );
    
    unreadMessages.forEach(msg => {
      if (msg.id) {
        this.chatService.markAsRead(msg.id).pipe(
          takeUntil(this.destroyed$)
        ).subscribe();
      }
    });
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

  getUnreadCountForCustomer(customerId: number): number {
    return this.customerMessages.filter(
      m => m.senderId === customerId && !m.isRead
    ).length;
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

    // Use 0 for guest users (null/undefined), otherwise use the customerId
    const customerIdToClose = this.selectedCustomerId || 0;
    
    this.chatService.closeConversation(customerIdToClose).pipe(
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
  }
}

