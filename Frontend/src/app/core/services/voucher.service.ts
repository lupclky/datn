import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { environment } from '../../../environments/environment.development';
import { VoucherDto } from '../dtos/voucher.dto';
import { VoucherListDto } from '../dtos/voucherList.dto';
import { ApplyVoucherDto, VoucherApplicationResponseDto } from '../dtos/voucherApplication.dto';
import { HomepageVoucherListDto } from '../dtos/homepageVoucher.dto';
import { Observable, BehaviorSubject } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class VoucherService {
  private apiUrl: string = environment.apiUrl;
  private token!: string | null;
  
  // BehaviorSubject để thông báo khi voucher thay đổi
  private voucherChangedSubject = new BehaviorSubject<boolean>(false);
  public voucherChanged$ = this.voucherChangedSubject.asObservable();

  constructor(private httpClient: HttpClient) {
    if (typeof localStorage !== 'undefined') {
      this.token = localStorage.getItem('token');
    }
  }
  
  /**
   * Trigger event khi voucher thay đổi
   */
  private notifyVoucherChanged(): void {
    this.voucherChangedSubject.next(true);
  }

  private getHeaders(): HttpHeaders {
    // Get fresh token on each call
    if (typeof localStorage !== 'undefined') {
      this.token = localStorage.getItem('token');
    }
    return new HttpHeaders({
      'Content-Type': 'application/json',
      Authorization: `Bearer ${this.token}`
    });
  }

  // Get all vouchers with pagination
  // Add timestamp to prevent API response caching
  getAllVouchers(page: number = 0, limit: number = 10, filter: string = 'active'): Observable<VoucherListDto | any> {
    const timestamp = new Date().getTime();
    return this.httpClient.get<VoucherListDto | any>(
      `${this.apiUrl}/vouchers?page=${page}&limit=${limit}&filter=${filter}&t=${timestamp}`,
      { headers: this.getHeaders() }
    );
  }

  // Get voucher by ID
  getVoucherById(id: number): Observable<VoucherDto> {
    return this.httpClient.get<VoucherDto>(
      `${this.apiUrl}/vouchers/${id}`,
      { headers: this.getHeaders() }
    );
  }

  // Get voucher by code
  getVoucherByCode(code: string): Observable<VoucherDto> {
    return this.httpClient.get<VoucherDto>(
      `${this.apiUrl}/vouchers/code/${code}`,
      { headers: this.getHeaders() }
    );
  }

  // Search vouchers
  searchVouchers(keyword: string, page: number = 0, limit: number = 10): Observable<VoucherListDto | any> {
    return this.httpClient.get<VoucherListDto | any>(
      `${this.apiUrl}/vouchers/search?keyword=${keyword}&page=${page}&limit=${limit}`,
      { headers: this.getHeaders() }
    );
  }

  // Create new voucher (Admin only)
  createVoucher(voucher: VoucherDto): Observable<VoucherDto> {
    return this.httpClient.post<VoucherDto>(
      `${this.apiUrl}/vouchers`,
      voucher,
      { headers: this.getHeaders() }
    ).pipe(
      tap(() => this.notifyVoucherChanged())
    );
  }

  // Update voucher (Admin only)
  updateVoucher(id: number, voucher: VoucherDto): Observable<VoucherDto> {
    return this.httpClient.put<VoucherDto>(
      `${this.apiUrl}/vouchers/${id}`,
      voucher,
      { headers: this.getHeaders() }
    ).pipe(
      tap(() => this.notifyVoucherChanged())
    );
  }

  // Delete voucher (Admin only)
  deleteVoucher(id: number): Observable<any> {
    return this.httpClient.delete(
      `${this.apiUrl}/vouchers/${id}`,
      { headers: this.getHeaders() }
    ).pipe(
      tap(() => this.notifyVoucherChanged())
    );
  }

  // Apply voucher to check discount
  applyVoucher(applyDto: ApplyVoucherDto): Observable<VoucherApplicationResponseDto> {
    return this.httpClient.post<VoucherApplicationResponseDto>(
      `${this.apiUrl}/vouchers/apply`,
      applyDto,
      { headers: this.getHeaders() }
    );
  }

  // Get vouchers for homepage with expiration date information
  // Add timestamp to prevent API response caching
  getHomepageVouchers(page: number = 0, limit: number = 5): Observable<HomepageVoucherListDto> {
    const timestamp = new Date().getTime();
    return this.httpClient.get<HomepageVoucherListDto>(
      `${this.apiUrl}/vouchers/homepage?page=${page}&limit=${limit}&t=${timestamp}`
    );
  }
} 