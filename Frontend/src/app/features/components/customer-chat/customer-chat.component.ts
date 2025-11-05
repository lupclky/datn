import { Component, OnInit, OnDestroy, ViewChild, ElementRef, AfterViewChecked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ChatService, ChatMessage } from '../../../core/services/chat.service';
import { catchError, finalize, takeUntil, tap } from 'rxjs';
import { of } from 'rxjs';
import { BaseComponent } from '../../../core/commonComponent/base.component';
import { ToastModule } from 'primeng/toast';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { CardModule } from 'primeng/card';
import { TooltipModule } from 'primeng/tooltip';
import { MessageService } from 'primeng/api';
import { ToastService } from '../../../core/services/toast.service';
import { UserService } from '../../../core/services/user.service';
import { environment } from '../../../../environments/environment.development';

@Component({
  selector: 'app-customer-chat',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ToastModule,
    ButtonModule,
    InputTextModule,
    CardModule,
    TooltipModule
  ],
  providers: [MessageService, ToastService],
  templateUrl: './customer-chat.component.html',
  styleUrls: ['./customer-chat.component.scss']
})
export class CustomerChatComponent extends BaseComponent implements OnInit, OnDestroy, AfterViewChecked {
  @ViewChild('scrollContainer') private scrollContainer!: ElementRef;
  
  messages: ChatMessage[] = [];
  newMessage: string = '';
  isLoading: boolean = false;
  isOpen: boolean = false;
  currentUserId: number = 0;
  private shouldScroll = false;
  selectedFile: File | null = null;
  filePreview: string | null = null;

  constructor(
    private chatService: ChatService,
    private userService: UserService,
    private toastService: ToastService
  ) {
    super();
    if (typeof localStorage !== 'undefined') {
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
    this.loadMessages();
  }

  ngAfterViewChecked(): void {
    if (this.shouldScroll) {
      this.scrollToBottom();
      this.shouldScroll = false;
    }
  }

  toggleChat(): void {
    this.isOpen = !this.isOpen;
    if (this.isOpen) {
      this.loadMessages();
    }
  }

  loadMessages(): void {
    if (!this.currentUserId) {
      const token = localStorage.getItem('token');
      if (!token) return;
      
      this.userService.getInforUser(token).pipe(
        tap(user => {
          this.currentUserId = user.id || 0;
          this.loadMessagesInternal();
        }),
        takeUntil(this.destroyed$)
      ).subscribe();
      return;
    }
    
    this.loadMessagesInternal();
  }

  private loadMessagesInternal(): void {
    this.isLoading = true;
    // Get messages where customer is sender or receiver
    this.chatService.getMessages().pipe(
      tap((messages) => {
        // Filter messages: customer's own messages or messages from staff to this customer
        this.messages = messages.filter(m => 
          m.senderId === this.currentUserId || 
          (m.isStaffMessage && m.receiverId === this.currentUserId)
        );
        this.shouldScroll = true;
      }),
      catchError((err) => {
        this.toastService.fail('Không thể tải tin nhắn');
        return of([]);
      }),
      finalize(() => {
        this.isLoading = false;
      }),
      takeUntil(this.destroyed$)
    ).subscribe();
  }

  sendMessage(): void {
    if ((!this.newMessage.trim() && !this.selectedFile)) {
      return;
    }

    if (this.selectedFile) {
      this.sendFileMessage();
    } else {
      this.chatService.sendMessage({
        receiverId: null, // Public message to staff
        message: this.newMessage.trim(),
        messageType: 'TEXT',
        isStaffMessage: false
      }, false).pipe(
        tap(() => {
          this.newMessage = '';
          this.loadMessages();
          this.shouldScroll = true;
        }),
        catchError((err) => {
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

  sendFileMessage(): void {
    if (!this.selectedFile) return;

    const formData = new FormData();
    formData.append('file', this.selectedFile);
    formData.append('receiverId', '');
    formData.append('message', this.newMessage.trim() || this.selectedFile.name);
    formData.append('messageType', this.selectedFile.type.startsWith('image/') ? 'IMAGE' : 'FILE');
    formData.append('isStaffMessage', 'false');

    const headers: any = {};

    this.chatService.sendFileMessage(formData, headers).pipe(
      tap(() => {
        this.newMessage = '';
        this.selectedFile = null;
        this.filePreview = null;
        this.loadMessages();
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

  openImagePreview(imageUrl: string): void {
    window.open(imageUrl, '_blank');
  }

  scrollToBottom(): void {
    try {
      if (this.scrollContainer) {
        setTimeout(() => {
          this.scrollContainer.nativeElement.scrollTop = 
            this.scrollContainer.nativeElement.scrollHeight;
        }, 100);
      }
    } catch (err) {
      console.error('Error scrolling:', err);
    }
  }
}

