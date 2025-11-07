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
  isClosed?: boolean; // Now refers to conversation.isClosed
  guestSessionId?: string;
  createdAt?: string;
  updatedAt?: string;
  fileUrl?: string;
  fileName?: string;
  conversationId?: number; // New field for conversation-based chat
}

export interface ChatMessageDTO {
  senderId?: number;
  guestSessionId?: string;
  receiverId?: number | null;
  message: string;
  messageType?: string;
  isStaffMessage: boolean;
}

export interface ChatConversation {
  id?: number;
  customer_id?: number | null;
  customer_name?: string | null;
  customer_email?: string | null;
  staff_id?: number | null;
  staff_name?: string | null;
  guest_session_id?: string | null;
  is_closed?: boolean;
  closed_by_id?: number | null;
  closed_by_name?: string | null;
  closed_at?: string | null;
  first_message_at?: string | null;
  last_message_at?: string | null;
  created_at?: string;
  updated_at?: string;
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

  // ===== NEW CONVERSATION-BASED METHODS =====
  
  /**
   * Get all active conversations (for staff dashboard)
   */
  getAllActiveConversations(): Observable<ChatConversation[]> {
    return this.http.get<ChatConversation[]>(`${this.apiUrl}/conversations/active`, {
      headers: this.getHeaders()
    });
  }

  /**
   * Get all conversations for a specific customer
   */
  getCustomerConversations(customerId: number): Observable<ChatConversation[]> {
    return this.http.get<ChatConversation[]>(`${this.apiUrl}/conversations/customer/${customerId}`, {
      headers: this.getHeaders()
    });
  }

  /**
   * Get all messages in a specific conversation
   */
  getConversationMessages(conversationId: number): Observable<ChatMessage[]> {
    return this.http.get<ChatMessage[]>(`${this.apiUrl}/conversations/${conversationId}/messages`, {
      headers: this.getHeaders()
    });
  }

  /**
   * Close a conversation by ID (staff action)
   */
  closeConversationById(conversationId: number): Observable<any> {
    return this.http.put(`${this.apiUrl}/conversations/${conversationId}/close`, {}, {
      headers: this.getHeaders()
    });
  }

  /**
   * Mark all messages in a conversation as read
   */
  markConversationAsRead(conversationId: number): Observable<any> {
    return this.http.put(`${this.apiUrl}/conversations/${conversationId}/mark-read`, {}, {
      headers: this.getHeaders()
    });
  }

  /**
   * Get unread message count for current user
   */
  getUnreadCount(): Observable<{ count: number }> {
    return this.http.get<{ count: number }>(`${this.apiUrl}/unread-count`, {
      headers: this.getHeaders()
    });
  }

  /**
   * Customer ends their current session and starts a new one
   */
  endCustomerSession(): Observable<any> {
    return this.http.post(`${this.apiUrl}/end-session`, {}, {
      headers: this.getHeaders()
    });
  }

  /**
   * Get conversation status for customer
   */
  getConversationStatus(): Observable<any> {
    return this.http.get(`${this.apiUrl}/conversation-status`, {
      headers: this.getHeaders()
    });
  }
}

