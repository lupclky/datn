import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface ChatMessage {
  id?: number;
  senderId?: number | null;
  senderName?: string;
  receiverId?: number | null;
  receiverName?: string | null;
  message: string;
  messageType?: string;
  isRead?: boolean;
  isStaffMessage: boolean;
  isClosed?: boolean;
  guestSessionId?: string;
  createdAt?: string;
  updatedAt?: string;
  fileUrl?: string;
  fileName?: string;
}

export interface ChatMessageDTO {
  senderId?: number;
  guestSessionId?: string;
  receiverId?: number | null;
  message: string;
  messageType?: string;
  isStaffMessage: boolean;
}

@Injectable({
  providedIn: 'root'
})
export class ChatService {
  private apiUrl = `${environment.apiUrl}/chat`;

  constructor(private http: HttpClient) {}

  private getHeaders(includeAuth: boolean = true, includeGuestSession: boolean = true): HttpHeaders {
    const token = localStorage.getItem('token');
    const headers: any = {
      'Content-Type': 'application/json'
    };
    
    if (includeAuth && token) {
      headers['Authorization'] = `Bearer ${token}`;
    }
    
    // Add guest session ID if no token (guest user)
    if (includeGuestSession && !token && typeof localStorage !== 'undefined') {
      let guestSessionId = localStorage.getItem('guestSessionId');
      if (!guestSessionId) {
        // Generate a new guest session ID
        guestSessionId = this.generateGuestSessionId();
        localStorage.setItem('guestSessionId', guestSessionId);
      }
      headers['X-Guest-Session-Id'] = guestSessionId;
    }
    
    return new HttpHeaders(headers);
  }

  private generateGuestSessionId(): string {
    // Generate a unique session ID
    return 'guest_' + Date.now() + '_' + Math.random().toString(36).substring(2, 15);
  }

  sendMessage(message: ChatMessageDTO, includeAuth: boolean = true): Observable<ChatMessage> {
    return this.http.post<ChatMessage>(`${this.apiUrl}/send`, message, {
      headers: this.getHeaders(includeAuth)
    });
  }

  sendFileMessage(formData: FormData, headers: any): Observable<ChatMessage> {
    // Ensure guest session ID is included if no auth token
    if (!headers['Authorization'] && typeof localStorage !== 'undefined') {
      let guestSessionId = localStorage.getItem('guestSessionId');
      if (!guestSessionId) {
        guestSessionId = this.generateGuestSessionId();
        localStorage.setItem('guestSessionId', guestSessionId);
      }
      headers['X-Guest-Session-Id'] = guestSessionId;
    }
    
    return this.http.post<ChatMessage>(`${this.apiUrl}/send-file`, formData, {
      headers: new HttpHeaders(headers)
    });
  }

  getConversation(customerId: number, staffId: number): Observable<ChatMessage[]> {
    // IMPORTANT: For staff viewing customer conversation
    // customerId: ID of the customer whose messages we want to see
    // staffId: ID of the current staff (not used in URL, extracted from token on backend)
    // API endpoint: /conversation/{customerId} - backend extracts staffId from Authorization token
    console.log('ChatService.getConversation - customerId:', customerId, 'staffId:', staffId, '(staffId extracted from token on backend)');
    return this.http.get<ChatMessage[]>(`${this.apiUrl}/conversation/${customerId}`, {
      headers: this.getHeaders()
    });
  }

  getMessages(): Observable<ChatMessage[]> {
    const hasToken = typeof localStorage !== 'undefined' && localStorage.getItem('token') !== null;
    return this.http.get<ChatMessage[]>(`${this.apiUrl}/messages`, {
      headers: this.getHeaders(hasToken)
    });
  }

  getUnreadMessages(): Observable<ChatMessage[]> {
    return this.http.get<ChatMessage[]>(`${this.apiUrl}/unread`, {
      headers: this.getHeaders()
    });
  }

  getCustomerMessages(): Observable<ChatMessage[]> {
    return this.http.get<ChatMessage[]>(`${this.apiUrl}/staff/customers`, {
      headers: this.getHeaders()
    });
  }

  markAsRead(messageId: number): Observable<any> {
    return this.http.put(`${this.apiUrl}/read/${messageId}`, {}, {
      headers: this.getHeaders()
    });
  }

  markAllAsRead(): Observable<any> {
    return this.http.put(`${this.apiUrl}/read-all`, {}, {
      headers: this.getHeaders()
    });
  }

  closeConversation(customerId: number): Observable<any> {
    return this.http.put(`${this.apiUrl}/close/${customerId}`, {}, {
      headers: this.getHeaders()
    });
  }
}

