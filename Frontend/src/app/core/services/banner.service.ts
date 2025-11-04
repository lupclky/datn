import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment.development';
import { BannerDto, BannerResponse, BannerListResponse } from '../dtos/banner.dto';

@Injectable({
  providedIn: 'root'
})
export class BannerService {
  private readonly apiUrl = `${environment.apiUrl}/banners`;

  constructor(private http: HttpClient) { }

  /**
   * Get all banners
   */
  getAllBanners(): Observable<BannerListResponse> {
    return this.http.get<BannerListResponse>(this.apiUrl);
  }

  /**
   * Get active banners
   */
  getActiveBanners(): Observable<BannerListResponse> {
    return this.http.get<BannerListResponse>(`${this.apiUrl}/active`);
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
    
    return this.http.post<BannerResponse>(this.apiUrl, banner, { headers });
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
    
    return this.http.put<BannerResponse>(`${this.apiUrl}/${id}`, banner, { headers });
  }

  /**
   * Delete banner (admin only)
   */
  deleteBanner(id: number): Observable<BannerResponse> {
    const token = localStorage.getItem('token');
    const headers = new HttpHeaders({
      'Authorization': `Bearer ${token}`
    });
    
    return this.http.delete<BannerResponse>(`${this.apiUrl}/${id}`, { headers });
  }

  /**
   * Toggle banner status (admin only)
   */
  toggleBannerStatus(id: number): Observable<BannerResponse> {
    const token = localStorage.getItem('token');
    const headers = new HttpHeaders({
      'Authorization': `Bearer ${token}`
    });
    
    return this.http.patch<BannerResponse>(`${this.apiUrl}/${id}/toggle`, {}, { headers });
  }

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
}

