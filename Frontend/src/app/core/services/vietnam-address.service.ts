import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, map, of, shareReplay } from 'rxjs';

export interface Province {
  code: number;
  name: string;
  name_en: string;
  full_name: string;
  full_name_en: string;
  code_name: string;
}

export interface District {
  code: number;
  name: string;
  name_en: string;
  full_name: string;
  full_name_en: string;
  code_name: string;
  province_code: number;
}

export interface Ward {
  code: number;
  name: string;
  name_en: string;
  full_name: string;
  full_name_en: string;
  code_name: string;
  district_code: number;
}

export interface AddressDropdownOption {
  label: string;
  value: number;
}

@Injectable({
  providedIn: 'root'
})
export class VietnamAddressService {
  // Sử dụng proxy để tránh CORS trong development
  // Trong production, cần cấu hình reverse proxy trên server
  private apiUrl = '/api/provinces';
  
  // Cache để tránh gọi API nhiều lần
  private provincesCache$?: Observable<AddressDropdownOption[]>;
  private districtsCache = new Map<number, Observable<AddressDropdownOption[]>>();
  private wardsCache = new Map<number, Observable<AddressDropdownOption[]>>();
  private provinceDataCache = new Map<number, Province>();
  private districtDataCache = new Map<number, District>();
  private wardDataCache = new Map<number, Ward>();

  constructor(private http: HttpClient) { }

  /**
   * Lấy danh sách tất cả tỉnh/thành phố (có cache)
   */
  getProvinces(): Observable<AddressDropdownOption[]> {
    if (!this.provincesCache$) {
      this.provincesCache$ = this.http.get<Province[]>(`${this.apiUrl}/p/?depth=1`).pipe(
        map(provinces => {
          // Lưu vào cache để sử dụng sau
          provinces.forEach(p => this.provinceDataCache.set(p.code, p));
          
          return provinces.map(p => ({
            label: p.name,
            value: p.code
          })).sort((a, b) => a.label.localeCompare(b.label, 'vi'));
        }),
        shareReplay(1) // Cache kết quả, chỉ gọi API 1 lần
      );
    }
    return this.provincesCache$;
  }

  /**
   * Lấy danh sách quận/huyện theo mã tỉnh/thành phố (có cache)
   */
  getDistricts(provinceCode: number): Observable<AddressDropdownOption[]> {
    if (!this.districtsCache.has(provinceCode)) {
      const districts$ = this.http.get<{ districts: District[] }>(`${this.apiUrl}/p/${provinceCode}?depth=2`).pipe(
        map(response => {
          // Lưu vào cache để sử dụng sau
          response.districts.forEach(d => this.districtDataCache.set(d.code, d));
          
          return response.districts.map(d => ({
            label: d.name,
            value: d.code
          })).sort((a, b) => a.label.localeCompare(b.label, 'vi'));
        }),
        shareReplay(1) // Cache kết quả
      );
      this.districtsCache.set(provinceCode, districts$);
    }
    return this.districtsCache.get(provinceCode)!;
  }

  /**
   * Lấy danh sách phường/xã theo mã quận/huyện (có cache)
   */
  getWards(districtCode: number): Observable<AddressDropdownOption[]> {
    if (!this.wardsCache.has(districtCode)) {
      const wards$ = this.http.get<{ wards: Ward[] }>(`${this.apiUrl}/d/${districtCode}?depth=2`).pipe(
        map(response => {
          // Lưu vào cache để sử dụng sau
          response.wards.forEach(w => this.wardDataCache.set(w.code, w));
          
          return response.wards.map(w => ({
            label: w.name,
            value: w.code
          })).sort((a, b) => a.label.localeCompare(b.label, 'vi'));
        }),
        shareReplay(1) // Cache kết quả
      );
      this.wardsCache.set(districtCode, wards$);
    }
    return this.wardsCache.get(districtCode)!;
  }

  /**
   * Lấy tên tỉnh/thành phố theo code (sử dụng cache nếu có)
   */
  getProvinceName(provinceCode: number): Observable<string> {
    // Kiểm tra cache trước
    if (this.provinceDataCache.has(provinceCode)) {
      return of(this.provinceDataCache.get(provinceCode)!.name);
    }
    
    return this.http.get<Province>(`${this.apiUrl}/p/${provinceCode}`).pipe(
      map(province => {
        this.provinceDataCache.set(provinceCode, province);
        return province.name;
      })
    );
  }

  /**
   * Lấy tên quận/huyện theo code (sử dụng cache nếu có)
   */
  getDistrictName(districtCode: number): Observable<string> {
    // Kiểm tra cache trước
    if (this.districtDataCache.has(districtCode)) {
      return of(this.districtDataCache.get(districtCode)!.name);
    }
    
    return this.http.get<District>(`${this.apiUrl}/d/${districtCode}`).pipe(
      map(district => {
        this.districtDataCache.set(districtCode, district);
        return district.name;
      })
    );
  }

  /**
   * Lấy tên phường/xã theo code (sử dụng cache nếu có)
   */
  getWardName(wardCode: number): Observable<string> {
    // Kiểm tra cache trước
    if (this.wardDataCache.has(wardCode)) {
      return of(this.wardDataCache.get(wardCode)!.name);
    }
    
    return this.http.get<Ward>(`${this.apiUrl}/w/${wardCode}`).pipe(
      map(ward => {
        this.wardDataCache.set(wardCode, ward);
        return ward.name;
      })
    );
  }

  /**
   * Xóa cache (sử dụng khi cần refresh dữ liệu)
   */
  clearCache(): void {
    this.provincesCache$ = undefined;
    this.districtsCache.clear();
    this.wardsCache.clear();
    this.provinceDataCache.clear();
    this.districtDataCache.clear();
    this.wardDataCache.clear();
  }
}

