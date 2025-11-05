import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface Review {
  id?: number;
  productId: number;
  userId?: number;
  userName?: string;
  rating: number;
  comment?: string;
  createdAt?: Date;
  updatedAt?: Date;
  staffReply?: string;
  staffReplyBy?: number;
  staffReplyByName?: string;
  staffReplyAt?: Date;
}

export interface ReviewReplyRequest {
  reviewId: number;
  reply: string;
}

export interface ReviewStats {
  averageRating: number;
  totalReviews: number;
}

export interface CreateReviewRequest {
  productId: number;
  rating: number;
  comment?: string;
}

@Injectable({
  providedIn: 'root'
})
export class ReviewService {
  private apiUrl = `${environment.apiUrl}/reviews`;

  constructor(private http: HttpClient) {}

  createReview(review: CreateReviewRequest): Observable<Review> {
    return this.http.post<Review>(this.apiUrl, review);
  }

  updateReview(id: number, review: CreateReviewRequest): Observable<Review> {
    return this.http.put<Review>(`${this.apiUrl}/${id}`, review);
  }

  deleteReview(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }

  getReviewsByProduct(productId: number): Observable<Review[]> {
    return this.http.get<Review[]>(`${this.apiUrl}/product/${productId}`);
  }

  getReviewsByProductPaginated(productId: number, page: number = 0, size: number = 10): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/product/${productId}/paginated?page=${page}&size=${size}`);
  }

  getProductRatingStats(productId: number): Observable<ReviewStats> {
    return this.http.get<ReviewStats>(`${this.apiUrl}/product/${productId}/stats`);
  }

  getReviewById(id: number): Observable<Review> {
    return this.http.get<Review>(`${this.apiUrl}/${id}`);
  }

  replyToReview(reply: ReviewReplyRequest): Observable<Review> {
    const token = localStorage.getItem('token');
    const headers = new HttpHeaders({
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    });
    return this.http.post<Review>(`${this.apiUrl}/reply`, reply, { headers });
  }

  getAllReviews(page: number = 0, size: number = 15, keyword?: string, productId?: number): Observable<any> {
    const token = localStorage.getItem('token');
    console.log('ReviewService.getAllReviews() - Token from localStorage:', token ? 'exists' : 'null');
    
    if (!token) {
      console.error('ReviewService.getAllReviews() - No token found!');
      throw new Error('No authentication token found');
    }
    
    const headers = new HttpHeaders({
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    });
    let url = `${this.apiUrl}/admin/all?page=${page}&size=${size}`;
    if (keyword) {
      url += `&keyword=${encodeURIComponent(keyword)}`;
    }
    if (productId) {
      url += `&productId=${productId}`;
    }
    console.log('ReviewService.getAllReviews() - Request URL:', url);
    console.log('ReviewService.getAllReviews() - Headers:', headers.keys());
    return this.http.get<any>(url, { headers });
  }
}

