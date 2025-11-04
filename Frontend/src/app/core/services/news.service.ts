import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment.development';
import { NewsDto, NewsListResponse, NewsCreateRequest } from '../dtos/news.dto';

@Injectable({
  providedIn: 'root'
})
export class NewsService {
  private apiUrl: string = environment.apiUrl;

  constructor(private httpClient: HttpClient) {}

  private getAuthHeaders(): HttpHeaders {
    const token = localStorage.getItem('token');
    return new HttpHeaders({
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`
    });
  }

  // ==================== USER ENDPOINTS ====================

  /**
   * Get all published news (for users)
   */
  getPublishedNews(page: number = 0, limit: number = 10): Observable<NewsListResponse> {
    const params = new HttpParams()
      .set('page', page.toString())
      .set('limit', limit.toString());
    
    return this.httpClient.get<NewsListResponse>(`${this.apiUrl}/news/published`, { params });
  }

  /**
   * Get single published news by ID
   */
  getPublishedNewsById(id: number): Observable<NewsDto> {
    return this.httpClient.get<NewsDto>(`${this.apiUrl}/news/published/${id}`);
  }

  /**
   * Search published news by keyword
   */
  searchPublishedNews(keyword: string, page: number = 0, limit: number = 10): Observable<NewsListResponse> {
    const params = new HttpParams()
      .set('keyword', keyword)
      .set('page', page.toString())
      .set('limit', limit.toString());
    
    return this.httpClient.get<NewsListResponse>(`${this.apiUrl}/news/published/search`, { params });
  }

  /**
   * Get news by category
   */
  getNewsByCategory(category: string, page: number = 0, limit: number = 10): Observable<NewsListResponse> {
    const params = new HttpParams()
      .set('page', page.toString())
      .set('limit', limit.toString());
    
    return this.httpClient.get<NewsListResponse>(`${this.apiUrl}/news/published/category/${category}`, { params });
  }

  /**
   * Get all available categories
   */
  getCategories(): Observable<string[]> {
    return this.httpClient.get<string[]>(`${this.apiUrl}/news/categories`);
  }

  // ==================== ADMIN ENDPOINTS ====================

  /**
   * Get all news (admin only)
   */
  getAllNewsForAdmin(page: number = 0, limit: number = 10): Observable<NewsListResponse> {
    const params = new HttpParams()
      .set('page', page.toString())
      .set('limit', limit.toString());
    
    return this.httpClient.get<NewsListResponse>(`${this.apiUrl}/news/admin/all`, {
      params,
      headers: this.getAuthHeaders()
    });
  }

  /**
   * Get news by ID (admin)
   */
  getNewsById(id: number): Observable<NewsDto> {
    return this.httpClient.get<NewsDto>(`${this.apiUrl}/news/admin/${id}`, {
      headers: this.getAuthHeaders()
    });
  }

  /**
   * Create news (admin only)
   */
  createNews(news: NewsCreateRequest): Observable<any> {
    return this.httpClient.post(`${this.apiUrl}/news/admin`, news, {
      headers: this.getAuthHeaders()
    });
  }

  /**
   * Update news (admin only)
   */
  updateNews(id: number, news: NewsCreateRequest): Observable<any> {
    return this.httpClient.put(`${this.apiUrl}/news/admin/${id}`, news, {
      headers: this.getAuthHeaders()
    });
  }

  /**
   * Delete news (admin only)
   */
  deleteNews(id: number): Observable<any> {
    return this.httpClient.delete(`${this.apiUrl}/news/admin/${id}`, {
      headers: this.getAuthHeaders()
    });
  }

  /**
   * Publish news (admin only)
   */
  publishNews(id: number): Observable<any> {
    return this.httpClient.put(`${this.apiUrl}/news/admin/${id}/publish`, {}, {
      headers: this.getAuthHeaders()
    });
  }

  /**
   * Archive news (admin only)
   */
  archiveNews(id: number): Observable<any> {
    return this.httpClient.put(`${this.apiUrl}/news/admin/${id}/archive`, {}, {
      headers: this.getAuthHeaders()
    });
  }

  /**
   * Upload featured image (admin only)
   */
  uploadFeaturedImage(file: File): Observable<any> {
    const formData = new FormData();
    formData.append('file', file);
    
    const token = localStorage.getItem('token');
    const headers = new HttpHeaders({
      Authorization: `Bearer ${token}`
    });
    
    return this.httpClient.post(`${this.apiUrl}/news/admin/upload-image`, formData, {
      headers: headers
    });
  }
}

