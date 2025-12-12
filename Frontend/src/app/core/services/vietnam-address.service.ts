import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, map, of, shareReplay } from 'rxjs';
import { environment } from '../../../environments/environment.development';

export interface AddressDropdownOption {
  label: string;
  value: number | string;
}

@Injectable({
  providedIn: 'root'
})
export class VietnamAddressService {
  private apiUrl = `${environment.apiUrl}/ghn`;
  
  // Cache to avoid calling API multiple times
  private provincesCache$?: Observable<AddressDropdownOption[]>;
  private districtsCache = new Map<number, Observable<AddressDropdownOption[]>>();
  private wardsCache = new Map<number, Observable<AddressDropdownOption[]>>();
  
  // Name lookups
  private provinceNameCache = new Map<number, string>();
  private districtNameCache = new Map<number, string>();
  private wardNameCache = new Map<string, string>();

  constructor(private http: HttpClient) { }

  /**
   * Get all provinces
   */
  getProvinces(): Observable<AddressDropdownOption[]> {
    if (!this.provincesCache$) {
      this.provincesCache$ = this.http.get<any[]>(`${this.apiUrl}/provinces`).pipe(
        map(response => {
          if (!Array.isArray(response)) return [];
          
          return response.map(p => {
            this.provinceNameCache.set(p.ProvinceID, p.ProvinceName);
            return {
              label: p.ProvinceName,
              value: p.ProvinceID
            };
          }).sort((a, b) => a.label.localeCompare(b.label, 'vi'));
        }),
        shareReplay(1)
      );
    }
    return this.provincesCache$;
  }

  /**
   * Get districts by province ID
   */
  getDistricts(provinceId: number): Observable<AddressDropdownOption[]> {
    if (!this.districtsCache.has(provinceId)) {
      const districts$ = this.http.get<any[]>(`${this.apiUrl}/districts?province_id=${provinceId}`).pipe(
        map(response => {
          if (!Array.isArray(response)) return [];
          
          return response.map(d => {
            this.districtNameCache.set(d.DistrictID, d.DistrictName);
            return {
              label: d.DistrictName,
              value: d.DistrictID
            };
          }).sort((a, b) => a.label.localeCompare(b.label, 'vi'));
        }),
        shareReplay(1)
      );
      this.districtsCache.set(provinceId, districts$);
    }
    return this.districtsCache.get(provinceId)!;
  }

  /**
   * Get wards by district ID
   */
  getWards(districtId: number): Observable<AddressDropdownOption[]> {
    if (!this.wardsCache.has(districtId)) {
      const wards$ = this.http.get<any[]>(`${this.apiUrl}/wards?district_id=${districtId}`).pipe(
        map(response => {
          if (!Array.isArray(response)) return [];
          
          return response.map(w => {
            this.wardNameCache.set(w.WardCode, w.WardName);
            return {
              label: w.WardName,
              value: w.WardCode
            };
          }).sort((a, b) => a.label.localeCompare(b.label, 'vi'));
        }),
        shareReplay(1)
      );
      this.wardsCache.set(districtId, wards$);
    }
    return this.wardsCache.get(districtId)!;
  }

  /**
   * Get province name by ID
   */
  getProvinceName(provinceId: number): Observable<string> {
    if (this.provinceNameCache.has(provinceId)) {
      return of(this.provinceNameCache.get(provinceId)!);
    }
    // Fallback if cache missed (re-fetch provinces or just return empty/ID)
    return this.getProvinces().pipe(
      map(() => this.provinceNameCache.get(provinceId) || '')
    );
  }

  /**
   * Get district name by ID
   */
  getDistrictName(districtId: number): Observable<string> {
    if (this.districtNameCache.has(districtId)) {
      return of(this.districtNameCache.get(districtId)!);
    }
    // We can't easily fetch just one district name without province ID.
    // Assuming the flow is always Province -> District selection, cache should be populated.
    return of(''); 
  }

  /**
   * Get ward name by Code
   */
  getWardName(wardCode: string): Observable<string> {
    if (this.wardNameCache.has(wardCode)) {
      return of(this.wardNameCache.get(wardCode)!);
    }
    return of('');
  }

  /**
   * Clear cache
   */
  clearCache(): void {
    this.provincesCache$ = undefined;
    this.districtsCache.clear();
    this.wardsCache.clear();
    this.provinceNameCache.clear();
    this.districtNameCache.clear();
    this.wardNameCache.clear();
  }
}

