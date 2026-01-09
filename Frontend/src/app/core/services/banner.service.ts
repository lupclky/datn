import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, BehaviorSubject } from 'rxjs';
import { tap } from 'rxjs/operators';
import { environment } from '../../../environments/environment.development';
import { BannerDto, BannerResponse, BannerListResponse } from '../dtos/banner.dto';

@Injectable({
  providedIn: 'root'
})
export class BannerService {
  private readonly apiUrl = `${environment.apiUrl}/banners`;
  
  // BehaviorSubject để thông báo khi banner thay đổi
  private bannerChangedSubject = new BehaviorSubject<boolean>(false);
  public bannerChanged$ = this.bannerChangedSubject.asObservable();

  constructor(private http: HttpClient) { }
  
  /**
   * Trigger event khi banner thay đổi
   */
  private notifyBannerChanged(): void {
    this.bannerChangedSubject.next(true);
  }

  /**
   * Get all banners
   */
  getAllBanners(): Observable<BannerListResponse> {
    return this.http.get<BannerListResponse>(this.apiUrl);
  }

  /**
   * Get active banners
   * Add timestamp to prevent API response caching
   */
  getActiveBanners(): Observable<BannerListResponse> {
    const timestamp = new Date().getTime();
    return this.http.get<BannerListResponse>(`${this.apiUrl}/active?t=${timestamp}`);
  }

  /**
   * Get banner by ID
   */
  getBannerById(id: number): Observable<BannerResponse> {
    return this.http.get<BannerResponse>(`${this.apiUrl}/${id}`);
  }

  /**
   * Create new banner (admin only)
   */
  createBanner(banner: BannerDto): Observable<BannerResponse> {
    const token = localStorage.getItem('token');
    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    });
    
    return this.http.post<BannerResponse>(this.apiUrl, banner, { headers }).pipe(
      tap(() => this.notifyBannerChanged())
    );
  }

  /**
   * Update banner (admin only)
   */
  updateBanner(id: number, banner: BannerDto): Observable<BannerResponse> {
    const token = localStorage.getItem('token');
    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    });
    
    return this.http.put<BannerResponse>(`${this.apiUrl}/${id}`, banner, { headers }).pipe(
      tap(() => this.notifyBannerChanged())
    );
  }

  /**
   * Delete banner (admin only)
   */
  deleteBanner(id: number): Observable<BannerResponse> {
    const token = localStorage.getItem('token');
    const headers = new HttpHeaders({
      'Authorization': `Bearer ${token}`
    });
    
    return this.http.delete<BannerResponse>(`${this.apiUrl}/${id}`, { headers }).pipe(
      tap(() => this.notifyBannerChanged())
    );
  }

  /**
   * Toggle banner status (admin only)
   */
  toggleBannerStatus(id: number): Observable<BannerResponse> {
    const token = localStorage.getItem('token');
    const headers = new HttpHeaders({
      'Authorization': `Bearer ${token}`
    });
    
    return this.http.patch<BannerResponse>(`${this.apiUrl}/${id}/toggle`, {}, { headers }).pipe(
      tap(() => this.notifyBannerChanged())
    );
  }

  /**
   * Upload banner image (admin only)
   */
  /**
   * Upload banner image (admin only)
   */
  uploadBannerImage(formData: FormData): Observable<any> {
    const token = localStorage.getItem('token');
    const headers = new HttpHeaders({
      'Authorization': `Bearer ${token}`
    });
    
    return this.http.post(`${this.apiUrl}/upload`, formData, { headers });
  }

  /**
   * Get banner image URL (simple approach like product images)
   */
  getBannerImageUrl(imageUrl: string): string {
    if (!imageUrl) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    
    // Direct API path without cache-busting (browser handles caching naturally)
    return `${environment.apiUrl}/banners/images/${imageUrl}`;
  }
}















