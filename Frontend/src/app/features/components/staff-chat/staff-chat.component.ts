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

interface CustomerSummary {
  userId: number;
  userName: string;
  lastMessage: string;
  unreadCount: number;
  isGuest: boolean;
  lastMessageAt?: string | null;
}

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
  customers: CustomerSummary[] = [];
  private shouldScroll = false;
  private messageSignature: string | null = null;
  private customersSignature: string | null = null;
  private refreshIntervalId: ReturnType<typeof setInterval> | null = null;
  private selectedConversationMarker: string | null = null;
  private isFetchingConversation: boolean = false;
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
    this.refreshIntervalId = setInterval(() => {
      this.pollUpdates();
    }, 5000);
  }

  override ngOnDestroy(): void {
    if (this.refreshIntervalId) {
      clearInterval(this.refreshIntervalId);
      this.refreshIntervalId = null;
    }
    super.ngOnDestroy();
  }

  private pollUpdates(): void {
    this.chatService.getAllActiveConversations().pipe(
      tap((conversations) => {
        const customerSummaries = this.buildCustomersListFromConversations(conversations);
        const selectedSummary = this.selectedCustomerId !== null
          ? customerSummaries.find(summary => summary.userId === this.selectedCustomerId)
          : undefined;
        const newMarker = selectedSummary ? this.computeConversationMarker(selectedSummary) : null;
        const shouldRefreshConversation = this.selectedCustomerId !== null &&
          newMarker !== null &&
          newMarker !== this.selectedConversationMarker;

        if (this.selectedCustomerId !== null && !selectedSummary) {
          this.selectedConversationMarker = null;
        }

        this.updateCustomersIfChanged(customerSummaries);

        if (shouldRefreshConversation && this.selectedCustomerId !== null) {
          this.loadConversation(this.selectedCustomerId, { silent: true });
        }
      }),
      catchError((err) => {
        console.error('Error polling chat conversations:', err);
        return of([]);
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
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
        const customerSummaries = this.buildCustomersListFromConversations(conversations);
        this.updateCustomersIfChanged(customerSummaries);
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

  private buildCustomersListFromConversations(conversations: any[]): CustomerSummary[] {
    // Group conversations by customerId to avoid duplicates
    const customerMap = new Map<number, CustomerSummary>();
    
    conversations.forEach(conv => {
      const customerId = conv.customer_id || 0;
      
      if (!customerMap.has(customerId)) {
        const customerName = conv.customer_name ||
          (customerId > 0 ? `Khách hàng #${customerId}` : 'Khách vãng lai');
        const lastMessageText = conv.last_message_preview || conv.last_message || '';
        const unreadCount = typeof conv.unread_count === 'number' ? conv.unread_count : 0;
        
        customerMap.set(customerId, {
          userId: customerId,
          userName: customerName,
          lastMessage: lastMessageText,
          unreadCount: unreadCount,
          isGuest: customerId === 0,
          lastMessageAt: conv.last_message_at
        });
      }
    });
    
    return Array.from(customerMap.values())
      .filter(c => c.userId !== undefined)
      .sort((a, b) => {
        const timeA = a.lastMessageAt ? new Date(a.lastMessageAt).getTime() : 0;
        const timeB = b.lastMessageAt ? new Date(b.lastMessageAt).getTime() : 0;
        return timeB - timeA;
      });
  }

  private updateCustomersIfChanged(customers: CustomerSummary[]): void {
    const signature = this.computeCustomersSignature(customers);
    if (signature !== this.customersSignature) {
      this.customers = customers;
      this.customersSignature = signature;
    }
  }

  private computeCustomersSignature(customers: CustomerSummary[]): string {
    if (!customers.length) {
      return '0';
    }

    return customers.map(c =>
      `${c.userId}:${c.lastMessageAt ?? 'no-time'}:${c.unreadCount ?? 0}`
    ).join('|');
  }

  private computeConversationMarker(summary: CustomerSummary): string {
    return this.buildConversationMarker(summary.userId, summary.lastMessageAt);
  }

  private buildConversationMarker(customerId: number, timestamp?: string | null): string {
    return `${customerId}:${timestamp ?? 'no-time'}`;
  }

  selectCustomer(customerId: number, customerName: string): void {
    this.selectedCustomerId = customerId;
    this.selectedCustomerName = customerName;
    this.messageSignature = null;
    this.messages = [];
    const summary = this.customers.find(c => c.userId === customerId);
    this.selectedConversationMarker = summary ? this.computeConversationMarker(summary) : null;
    this.loadConversation(customerId);
  }

  loadConversation(customerId: number, options?: { silent?: boolean }): void {
    if (!customerId && customerId !== 0) {
      console.error('Invalid customerId:', customerId);
      return;
    }
    const silent = options?.silent ?? false;
    if (silent && this.isFetchingConversation) {
      return;
    }
    this.isFetchingConversation = true;
    if (!silent) {
      this.isLoading = true;
    }

    const endLoading = () => {
      if (!silent) {
        this.isLoading = false;
      }
      this.isFetchingConversation = false;
    };
    
    // Get customer conversations and load messages from the first (most recent) one
    this.chatService.getCustomerConversations(customerId).pipe(
      tap((conversations) => {
        if (conversations && conversations.length > 0) {
          // Get the most recent active conversation, or the most recent one if none are active
          const activeConversation = conversations.find(c => !c.is_closed) || conversations[0];
          if (activeConversation && activeConversation.id) {
            this.chatService.getConversationMessages(activeConversation.id).pipe(
              tap((messages) => {
                this.isConversationClosed = activeConversation.is_closed || false;
                this.updateMessagesIfChanged(messages);

                 const lastTimestamp = messages.length
                   ? (messages[messages.length - 1].updatedAt || messages[messages.length - 1].createdAt || activeConversation.last_message_at)
                   : (activeConversation.last_message_at || null);
                 this.selectedConversationMarker = this.buildConversationMarker(customerId, lastTimestamp);
                
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
                endLoading();
              }),
              takeUntil(this.destroyed$)
            ).subscribe();
          } else {
            this.updateMessagesIfChanged([]);
            this.selectedConversationMarker = this.buildConversationMarker(customerId, null);
            endLoading();
          }
        } else {
          this.updateMessagesIfChanged([]);
          this.selectedConversationMarker = this.buildConversationMarker(customerId, null);
          endLoading();
        }
      }),
      catchError((err) => {
        console.error('Error loading customer conversations:', err);
        this.toastService.fail('Không thể tải cuộc trò chuyện');
        endLoading();
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
      }),
      catchError((err) => {
        console.error('Error sending file:', err);
        this.toastService.fail('Không thể gửi file');
        return of(null);
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  private updateMessagesIfChanged(newMessages: ChatMessage[]): void {
    const sortedMessages = [...newMessages].sort((a, b) => {
      const timeA = a.createdAt ? new Date(a.createdAt).getTime() : 0;
      const timeB = b.createdAt ? new Date(b.createdAt).getTime() : 0;
      return timeA - timeB;
    });

    const signature = this.computeMessageSignature(sortedMessages);
    if (signature !== this.messageSignature) {
      this.messages = sortedMessages;
      this.messageSignature = signature;
      this.shouldScroll = true;
    }
  }

  private computeMessageSignature(messages: ChatMessage[]): string {
    if (!messages.length) {
      return '0';
    }

    const last = messages[messages.length - 1];
    const lastIdentifier = `${last.id ?? 'no-id'}:${last.updatedAt ?? last.createdAt ?? 'no-date'}`;
    return `${messages.length}:${lastIdentifier}`;
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

